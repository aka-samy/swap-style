import {
  Injectable,
  BadRequestException,
  NotFoundException,
  Inject,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { Prisma, MatchStatus } from '@prisma/client';
import { FeedQueryDto, SwipeDto } from './dto';
import Redis from 'ioredis';

const FEED_CACHE_TTL_SECONDS = 30;

@Injectable()
export class DiscoveryService {
  constructor(
    private readonly prisma: PrismaService,
    @Inject('REDIS_CLIENT') private readonly redis: Redis,
  ) {}

  async getFeed(
    userId: string,
    query: FeedQueryDto,
  ) {
    if (!userId) {
      throw new BadRequestException('User account is not fully set up');
    }

    const {
      page = 1,
      limit = 20,
      latitude,
      longitude,
      radiusKm = 50,
      size,
      category,
      shoeSizeEu,
    } = query;
    const offset = (page - 1) * limit;
    const radiusMeters = radiusKm * 1000;

    // Redis cache key based on user + query parameters
    const cacheKey = `feed:${userId}:${latitude}:${longitude}:${radiusKm}:${size ?? ''}:${category ?? ''}:${shoeSizeEu ?? ''}:${page}`;
    const cached = await this.redis.get(cacheKey);
    if (cached) {
      return JSON.parse(cached) as object;
    }

    // Build filter clauses
    const sizeFilter = size ? Prisma.sql`AND i."size"::text = ${size}` : Prisma.empty;
    const categoryFilter = category ? Prisma.sql`AND i."category"::text = ${category}` : Prisma.empty;
    const shoeSizeFilter = shoeSizeEu
      ? Prisma.sql`AND i."category" = 'Shoes' AND i."shoe_size_eu" = ${shoeSizeEu}`
      : Prisma.empty;

    // PostGIS distance-based feed query
    const items = await this.prisma.$queryRaw<any[]>`
      SELECT
        i.id, i."owner_id" AS "ownerId", i.category, i.brand, i.size, i.condition,
        i."shoe_size_eu" AS "shoeSizeEu",
        i.latitude, i.longitude, i.status,
        u."name" AS "ownerName",
        u."profile_photo_url" AS "ownerPhotoUrl",
        u."email_verified" AS "ownerVerified",
        (
          ST_Distance(
            ST_SetSRID(ST_MakePoint(i.longitude, i.latitude), 4326)::geography,
            ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)::geography
          ) / 1000.0
        ) AS "distanceKm"
      FROM "items" i
      JOIN "users" u ON u.id = i."owner_id"
      WHERE i."owner_id" != ${userId}
        AND i.status = 'available'
        AND ST_DWithin(
          ST_SetSRID(ST_MakePoint(i.longitude, i.latitude), 4326)::geography,
          ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)::geography,
          ${radiusMeters}
        )
        AND i.id NOT IN (
          SELECT l."item_id" FROM "likes" l WHERE l."liker_id" = ${userId}
        )
        AND i."owner_id" NOT IN (
          SELECT b."blocked_id" FROM "blocks" b WHERE b."blocker_id" = ${userId}
          UNION
          SELECT b."blocker_id" FROM "blocks" b WHERE b."blocked_id" = ${userId}
        )
        ${sizeFilter}
        ${categoryFilter}
        ${shoeSizeFilter}
      ORDER BY "distanceKm" ASC
      LIMIT ${limit} OFFSET ${offset}
    `;

    // Get photos for each item
    const itemIds = items.map((i) => i.id);
    const photos = itemIds.length
      ? await this.prisma.itemPhoto.findMany({
          where: { itemId: { in: itemIds } },
          orderBy: { sortOrder: 'asc' },
        })
      : [];

    const verifications = itemIds.length
      ? await this.prisma.itemVerification.findMany({
          where: { itemId: { in: itemIds } },
          select: {
            itemId: true,
            verifiedAt: true,
            washed: true,
            noStains: true,
            noTears: true,
            noDefects: true,
            photosAccurate: true,
          },
        })
      : [];

    const photosByItem = photos.reduce(
      (acc, p) => {
        (acc[p.itemId] ||= []).push({ url: p.url, thumbnailUrl: p.url });
        return acc;
      },
      {} as Record<string, any[]>,
    );

    const verifiedItemIds = new Set(
      verifications
        .filter(
          (v) =>
            !!v.verifiedAt &&
            v.washed &&
            v.noStains &&
            v.noTears &&
            v.noDefects &&
            v.photosAccurate,
        )
        .map((v) => v.itemId),
    );

    const result = {
      data: items.map((item) => ({
        id: item.id,
        ownerId: item.ownerId,
        ownerName: item.ownerName,
        ownerPhotoUrl: item.ownerPhotoUrl,
        ownerVerified: item.ownerVerified,
        category: item.category,
        brand: item.brand,
        size:
          item.category === 'Shoes' && item.shoeSizeEu != null
            ? `EU ${item.shoeSizeEu}`
            : item.size,
        condition: item.condition,
        shoeSizeEu: item.shoeSizeEu,
        isVerified: verifiedItemIds.has(item.id),
        distanceKm: Math.round(item.distanceKm * 10) / 10,
        photos: photosByItem[item.id] || [],
      })),
      meta: { page, limit, hasMore: items.length === limit },
    };

    await this.redis.set(cacheKey, JSON.stringify(result), 'EX', FEED_CACHE_TTL_SECONDS);
    return result;
  }

  async recordSwipe(userId: string, dto: SwipeDto) {
    const { itemId, action } = dto;

    // Verify item exists
    const item = await this.prisma.item.findUnique({
      where: { id: itemId },
      select: { id: true, ownerId: true },
    });
    if (!item) throw new NotFoundException('Item not found');

    // Check for duplicate swipe
    const existing = await this.prisma.like.findFirst({
      where: { likerId: userId, itemId },
    });
    if (existing) throw new BadRequestException('Already swiped on this item');

    if (action === 'pass') {
      // Record pass as a like with isLike=false for tracking
      await this.prisma.like.create({
        data: { likerId: userId, itemId, isLike: false },
      });
      return { matched: false };
    }

    // Record like
    await this.prisma.like.create({
      data: { likerId: userId, itemId, isLike: true },
    });

    // Check for reciprocal like: does the item owner like any of our items?
    const reciprocal = await this.prisma.like.findFirst({
      where: {
        likerId: item.ownerId,
        isLike: true,
        item: { ownerId: userId },
      },
      include: { item: true },
    });

    if (!reciprocal) return { matched: false };

    // Double match detected — create match
    const match = await this.prisma.match.create({
      data: {
        userAId: userId,
        userBId: item.ownerId,
        itemAId: reciprocal.itemId,
        itemBId: itemId,
        status: MatchStatus.pending,
      },
      include: {
        userA: { select: { id: true, displayName: true, profilePhotoUrl: true } },
        userB: { select: { id: true, displayName: true, profilePhotoUrl: true } },
        itemA: { select: { id: true, brand: true, photos: { take: 1, orderBy: { sortOrder: 'asc' } } } },
        itemB: { select: { id: true, brand: true, photos: { take: 1, orderBy: { sortOrder: 'asc' } } } },
      },
    });

    return {
      matched: true,
      match: {
        id: match.id,
        otherUser: {
          id: match.userB.id,
          name: match.userB.displayName,
          profilePhotoUrl: match.userB.profilePhotoUrl,
        },
        myItem: {
          id: match.itemA.id,
          brand: match.itemA.brand,
          thumbnailUrl: match.itemA.photos[0]?.url || null,
        },
        theirItem: {
          id: match.itemB.id,
          brand: match.itemB.brand,
          thumbnailUrl: match.itemB.photos[0]?.url || null,
        },
      },
    };
  }
}
