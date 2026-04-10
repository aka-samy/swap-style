import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { StorageService } from '../../common/storage/storage.service';
import { CreateItemDto, UpdateItemDto } from './dto';
import { MatchStatus } from '@prisma/client';

const ITEM_INCLUDE = {
  photos: { orderBy: { sortOrder: 'asc' as const } },
  verification: true,
};

@Injectable()
export class ItemsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: StorageService,
  ) {}

  async create(userId: string, dto: CreateItemDto) {
    if (dto.category === 'Shoes' && dto.shoeSizeEu == null) {
      throw new BadRequestException('shoeSizeEu is required for shoes');
    }

    return this.prisma.item.create({
      data: {
        ownerId: userId,
        category: dto.category,
        brand: dto.brand,
        size: dto.size,
        shoeSizeEu: dto.category === 'Shoes' ? dto.shoeSizeEu ?? null : null,
        condition: dto.condition,
        notes: dto.notes,
        latitude: dto.latitude,
        longitude: dto.longitude,
      },
      include: ITEM_INCLUDE,
    });
  }

  async findOne(id: string) {
    const item = await this.prisma.item.findUnique({
      where: { id },
      include: ITEM_INCLUDE,
    });
    if (!item) throw new NotFoundException('Item not found');
    return item;
  }

  async findByOwner(
    userId: string,
    query: { page: number; limit: number; status?: string },
  ) {
    const { page = 1, limit = 20, status } = query;
    const where: any = { ownerId: userId };
    if (status) where.status = status;

    const [data, total] = await Promise.all([
      this.prisma.item.findMany({
        where,
        include: ITEM_INCLUDE,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.item.count({ where }),
    ]);

    return { data, meta: { page, limit, total } };
  }

  async update(id: string, userId: string, dto: UpdateItemDto) {
    const item = await this.findOne(id);
    if (item.ownerId !== userId) {
      throw new ForbiddenException('You can only edit your own items');
    }

    const nextCategory = dto.category ?? item.category;
    const nextShoeSize =
      dto.shoeSizeEu !== undefined ? dto.shoeSizeEu : (item as any).shoeSizeEu;
    if (nextCategory === 'Shoes' && nextShoeSize == null) {
      throw new BadRequestException('shoeSizeEu is required for shoes');
    }

    return this.prisma.item.update({
      where: { id },
      data: {
        ...dto,
        shoeSizeEu: nextCategory === 'Shoes' ? nextShoeSize : null,
      },
      include: ITEM_INCLUDE,
    });
  }

  async remove(id: string, userId: string) {
    const item = await this.findOne(id);
    if (item.ownerId !== userId) {
      throw new ForbiddenException('You can only remove your own items');
    }

    await this.prisma.$transaction(async (tx) => {
      // Mark item as removed
      await tx.item.update({
        where: { id },
        data: { status: 'removed' },
      });

      // Cancel any pending matches involving this item
      await tx.match.updateMany({
        where: {
          OR: [{ itemAId: id }, { itemBId: id }],
          status: {
            in: [
              MatchStatus.pending,
              MatchStatus.negotiating,
              MatchStatus.agreed,
              MatchStatus.awaiting_confirmation,
            ],
          },
        },
        data: { status: MatchStatus.canceled },
      });
    });
  }

  async getPresignedUploadUrl(itemId: string, userId: string, contentType: string) {
    const item = await this.findOne(itemId);
    if (item.ownerId !== userId) {
      throw new ForbiddenException('You can only upload photos to your own items');
    }

    const key = `items/${itemId}/${Date.now()}.jpg`;
    const uploadUrl = await this.storage.getPresignedUploadUrl(key, contentType);
    const publicUrl = this.storage.getPublicUrl(key);

    return { uploadUrl, publicUrl, key };
  }

  async verifyItem(
    itemId: string,
    userId: string,
    data: {
      washed: boolean;
      noStains: boolean;
      noTears: boolean;
      noDefects: boolean;
      photosAccurate: boolean;
    },
  ) {
    const item = await this.findOne(itemId);
    if (item.ownerId !== userId) {
      throw new ForbiddenException('You can only verify your own items');
    }

    return this.prisma.itemVerification.create({
      data: { itemId, ...data },
    });
  }
}
