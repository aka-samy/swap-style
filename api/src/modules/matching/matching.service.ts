import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { GamificationService } from '../gamification/gamification.service';
import { MatchStatus } from '@prisma/client';

const MATCH_INCLUDE = {
  userA: { select: { id: true, displayName: true, profilePhotoUrl: true, emailVerified: true } },
  userB: { select: { id: true, displayName: true, profilePhotoUrl: true, emailVerified: true } },
  itemA: { include: { photos: { take: 1, orderBy: { sortOrder: 'asc' as const } } } },
  itemB: { include: { photos: { take: 1, orderBy: { sortOrder: 'asc' as const } } } },
};

@Injectable()
export class MatchingService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly gamification: GamificationService,
  ) {}

  async findAll(
    userId: string,
    query: { page: number; limit: number; status?: string },
  ) {
    const { page = 1, limit = 20, status } = query;
    const where: any = {
      OR: [{ userAId: userId }, { userBId: userId }],
    };

    if (status) {
      const statuses = status.split(',').map((s) => s.trim());
      where.status = { in: statuses };
    }

    const [data, total] = await Promise.all([
      this.prisma.match.findMany({
        where,
        include: MATCH_INCLUDE,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.match.count({ where }),
    ]);

    return { data, meta: { page, limit, total } };
  }

  async findOne(matchId: string, userId: string) {
    const match = await this.prisma.match.findUnique({
      where: { id: matchId },
      include: {
        ...MATCH_INCLUDE,
        counterOffers: {
          orderBy: { createdAt: 'desc' },
          take: 10,
        },
      },
    });

    if (!match) throw new NotFoundException('Match not found');
    if (match.userAId !== userId && match.userBId !== userId) {
      throw new ForbiddenException('You are not part of this match');
    }

    return match;
  }

  async confirmMatch(matchId: string, userId: string) {
    const match = await this.findOne(matchId, userId);

    const validStatuses: MatchStatus[] = [
      MatchStatus.agreed,
      MatchStatus.awaiting_confirmation,
    ];
    if (!validStatuses.includes(match.status)) {
      throw new BadRequestException(
        `Cannot confirm match with status "${match.status}"`,
      );
    }

    const isUserA = match.userAId === userId;
    const otherConfirmed = isUserA ? match.userBConfirmed : match.userAConfirmed;
    const bothConfirmed = otherConfirmed;

    return this.prisma.match.update({
      where: { id: matchId },
      data: {
        ...(isUserA ? { userAConfirmed: true } : { userBConfirmed: true }),
        status: bothConfirmed ? MatchStatus.completed : MatchStatus.awaiting_confirmation,
        ...(bothConfirmed ? { completedAt: new Date() } : {}),
      },
      include: MATCH_INCLUDE,
    }).then(async (result) => {
      if (bothConfirmed) {
        await Promise.all([
          this.gamification.recordActivity(match.userAId),
          this.gamification.recordActivity(match.userBId),
        ]);
      }
      return result;
    });
  }

  async cancelMatch(matchId: string, userId: string) {
    const match = await this.findOne(matchId, userId);

    const cancellableStatuses: MatchStatus[] = [
      MatchStatus.pending,
      MatchStatus.negotiating,
      MatchStatus.agreed,
      MatchStatus.awaiting_confirmation,
    ];
    if (!cancellableStatuses.includes(match.status)) {
      throw new BadRequestException(
        `Cannot cancel match with status "${match.status}"`,
      );
    }

    return this.prisma.match.update({
      where: { id: matchId },
      data: { status: MatchStatus.canceled },
      include: MATCH_INCLUDE,
    });
  }
}
