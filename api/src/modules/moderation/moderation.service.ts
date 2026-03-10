import {
  Injectable,
  ForbiddenException,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { ReportUserDto, ReportItemDto } from './dto';

@Injectable()
export class ModerationService {
  constructor(private prisma: PrismaService) {}

  // ─── Reports ────────────────────────────────────────────

  async reportUser(
    reporterId: string,
    dto: ReportUserDto,
  ): Promise<{ id: string }> {
    if (reporterId === dto.targetUserId) {
      throw new ForbiddenException('Cannot report yourself');
    }

    const target = await this.prisma.user.findUnique({
      where: { id: dto.targetUserId },
    });
    if (!target) throw new NotFoundException('User not found');

    const existing = await this.prisma.report.findFirst({
      where: {
        reporterId,
        reportedUserId: dto.targetUserId,
      },
    });
    if (existing) {
      throw new ForbiddenException('You have already reported this user');
    }

    const report = await this.prisma.report.create({
      data: {
        reporterId,
        reportedUserId: dto.targetUserId,
        reason: dto.reason,
        details: dto.details,
      },
    });

    return { id: report.id };
  }

  async reportItem(
    reporterId: string,
    dto: ReportItemDto,
  ): Promise<{ id: string }> {
    const report = await this.prisma.report.create({
      data: {
        reporterId,
        reportedItemId: dto.targetItemId,
        reason: dto.reason,
        details: dto.details,
      },
    });

    return { id: report.id };
  }

  // ─── Blocks ─────────────────────────────────────────────

  async blockUser(blockerId: string, blockedId: string): Promise<void> {
    if (blockerId === blockedId) {
      throw new ForbiddenException('Cannot block yourself');
    }

    const target = await this.prisma.user.findUnique({
      where: { id: blockedId },
    });
    if (!target) throw new NotFoundException('User not found');

    const existing = await this.prisma.block.findFirst({
      where: { blockerId, blockedId },
    });
    if (existing) {
      throw new ConflictException('User is already blocked');
    }

    await this.prisma.block.create({
      data: { blockerId, blockedId },
    });
  }

  async unblockUser(blockerId: string, blockedId: string): Promise<void> {
    await this.prisma.block.deleteMany({
      where: { blockerId, blockedId },
    });
  }

  async getBlocks(userId: string): Promise<{ blockedId: string }[]> {
    const blocks = await this.prisma.block.findMany({
      where: { blockerId: userId },
      select: { blockedId: true },
    });
    return blocks;
  }
}
