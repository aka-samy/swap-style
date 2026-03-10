import {
  Injectable,
  BadRequestException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { GamificationService } from '../gamification/gamification.service';
import { CreateRatingDto } from './dto';
import { MatchStatus } from '@prisma/client';

@Injectable()
export class RatingsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly gamification: GamificationService,
  ) {}

  async createRating(matchId: string, raterId: string, dto: CreateRatingDto) {
    const match = await this.prisma.match.findUnique({ where: { id: matchId } });
    if (!match) throw new NotFoundException('Match not found');
    if (match.status !== MatchStatus.completed) {
      throw new BadRequestException('Can only rate completed swaps');
    }
    if (match.userAId !== raterId && match.userBId !== raterId) {
      throw new ForbiddenException('Not a match participant');
    }

    const existing = await this.prisma.rating.findFirst({
      where: { matchId, raterId },
    });
    if (existing) throw new ForbiddenException('Already rated this swap');

    const rateeId = match.userAId === raterId ? match.userBId : match.userAId;

    const rating = await this.prisma.rating.create({
      data: {
        matchId,
        raterId,
        rateeId,
        score: dto.score,
        comment: dto.comment,
      },
    });

    await this.gamification.recordActivity(raterId).catch(() => {/* non-critical */});

    return rating;
  }

  async getUserRatings(userId: string) {
    const [ratings, agg] = await Promise.all([
      this.prisma.rating.findMany({
        where: { rateeId: userId },
        include: { rater: { select: { id: true, displayName: true, profilePhotoUrl: true } } },
        orderBy: { createdAt: 'desc' },
        take: 50,
      }),
      this.prisma.rating.aggregate({
        where: { rateeId: userId },
        _avg: { score: true },
      }),
    ]);

    return { ratings, average: agg._avg.score ?? 0 };
  }
}
