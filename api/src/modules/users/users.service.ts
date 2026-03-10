import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { StorageService } from '../../common/storage/storage.service';
import { UpdateProfileDto, CreateWishlistEntryDto } from './dto';

@Injectable()
export class UsersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: StorageService,
  ) {}

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });
    if (!user) throw new NotFoundException('User not found');

    const [itemCount, ratingAgg] = await Promise.all([
      this.prisma.item.count({ where: { ownerId: userId, status: 'available' } }),
      this.prisma.rating.aggregate({
        where: { rateeId: userId },
        _avg: { score: true },
        _count: true,
      }),
    ]);

    return {
      ...user,
      stats: {
        itemCount,
        averageRating: ratingAgg._avg.score,
        ratingCount: ratingAgg._count,
      },
    };
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    return this.prisma.user.update({
      where: { id: userId },
      data: dto,
    });
  }

  async getPublicProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        displayName: true,
        profilePhotoUrl: true,
        emailVerified: true,
        phoneVerified: true,
        createdAt: true,
      },
    });
    if (!user) throw new NotFoundException('User not found');

    const [itemCount, ratingAgg] = await Promise.all([
      this.prisma.item.count({ where: { ownerId: userId, status: 'available' } }),
      this.prisma.rating.aggregate({
        where: { rateeId: userId },
        _avg: { score: true },
        _count: true,
      }),
    ]);

    return {
      ...user,
      stats: {
        itemCount,
        averageRating: ratingAgg._avg.score,
        ratingCount: ratingAgg._count,
      },
    };
  }

  async getProfilePhotoUploadUrl(userId: string, contentType: string) {
    const key = `profiles/${userId}/${Date.now()}.jpg`;
    const uploadUrl = await this.storage.getPresignedUploadUrl(key, contentType);
    const publicUrl = this.storage.getPublicUrl(key);
    return { uploadUrl, publicUrl, key };
  }

  async updateProfilePhoto(userId: string, photoUrl: string) {
    return this.prisma.user.update({
      where: { id: userId },
      data: { profilePhotoUrl: photoUrl },
    });
  }

  async getUserCloset(userId: string, query: { page: number; limit: number }) {
    const { page = 1, limit = 20 } = query;
    const where = { ownerId: userId, status: 'available' as const };

    const [data, total] = await Promise.all([
      this.prisma.item.findMany({
        where,
        include: { photos: { take: 1, orderBy: { sortOrder: 'asc' } } },
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.item.count({ where }),
    ]);

    return { data, meta: { page, limit, total } };
  }

  // Wishlist
  async getWishlist(userId: string) {
    return this.prisma.wishlistEntry.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async addWishlistEntry(userId: string, dto: CreateWishlistEntryDto) {
    return this.prisma.wishlistEntry.create({
      data: { userId, ...dto },
    });
  }

  async removeWishlistEntry(entryId: string, userId: string) {
    return this.prisma.wishlistEntry.delete({
      where: { id: entryId },
    });
  }
}
