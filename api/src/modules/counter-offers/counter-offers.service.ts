import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { MatchStatus, CounterOfferStatus } from '@prisma/client';
import { ProposeCounterOfferDto } from './dto';

const MAX_OFFERS_PER_SIDE = 5;

@Injectable()
export class CounterOffersService {
  constructor(private readonly prisma: PrismaService) {}

  async propose(matchId: string, userId: string, dto: ProposeCounterOfferDto) {
    const match = await this.prisma.match.findUnique({
      where: { id: matchId },
    });
    if (!match) throw new NotFoundException('Match not found');
    if (match.userAId !== userId && match.userBId !== userId) {
      throw new ForbiddenException('Not a participant');
    }

    // Check round limit
    const userOfferCount = await this.prisma.counterOffer.count({
      where: { matchId, proposerId: userId },
    });
    if (userOfferCount >= MAX_OFFERS_PER_SIDE) {
      throw new BadRequestException(
        `Maximum ${MAX_OFFERS_PER_SIDE} counter-offers per side reached`,
      );
    }

    // Supersede any pending offers
    await this.prisma.counterOffer.updateMany({
      where: { matchId, status: CounterOfferStatus.pending },
      data: { status: CounterOfferStatus.superseded },
    });

    const counterOffer = await this.prisma.counterOffer.create({
      data: {
        matchId,
        proposerId: userId,
        monetaryAmount: dto.monetaryAmount || 0,
        message: dto.message,
        status: CounterOfferStatus.pending,
        round: userOfferCount + 1,
        items: dto.items?.length
          ? {
              create: dto.items.map((item) => ({
                itemId: item.itemId,
              })),
            }
          : undefined,
      },
      include: { items: { include: { item: true } } },
    });

    // Update match status to negotiating
    if (match.status === MatchStatus.pending) {
      await this.prisma.match.update({
        where: { id: matchId },
        data: { status: MatchStatus.negotiating },
      });
    }

    return counterOffer;
  }

  async accept(counterOfferId: string, userId: string) {
    const offer = await this.prisma.counterOffer.findUnique({
      where: { id: counterOfferId },
      include: { match: true },
    });
    if (!offer) throw new NotFoundException('Counter-offer not found');

    // Only the other party can accept
    if (offer.proposerId === userId) {
      throw new ForbiddenException('Cannot accept your own counter-offer');
    }

    const match = offer.match;
    if (match.userAId !== userId && match.userBId !== userId) {
      throw new ForbiddenException('Not a participant');
    }

    await this.prisma.counterOffer.update({
      where: { id: counterOfferId },
      data: { status: CounterOfferStatus.accepted },
    });

    await this.prisma.match.update({
      where: { id: match.id },
      data: { status: MatchStatus.agreed },
    });

    return { accepted: true };
  }

  async decline(counterOfferId: string, userId: string) {
    const offer = await this.prisma.counterOffer.findUnique({
      where: { id: counterOfferId },
      include: { match: true },
    });
    if (!offer) throw new NotFoundException('Counter-offer not found');

    const match = offer.match;
    if (match.userAId !== userId && match.userBId !== userId) {
      throw new ForbiddenException('Not a participant');
    }

    return this.prisma.counterOffer.update({
      where: { id: counterOfferId },
      data: { status: CounterOfferStatus.declined },
    });
  }

  async getByMatch(matchId: string, userId: string) {
    const match = await this.prisma.match.findUnique({
      where: { id: matchId },
    });
    if (!match) throw new NotFoundException('Match not found');
    if (match.userAId !== userId && match.userBId !== userId) {
      throw new ForbiddenException('Not a participant');
    }

    return this.prisma.counterOffer.findMany({
      where: { matchId },
      include: { items: { include: { item: true } } },
      orderBy: { createdAt: 'desc' },
    });
  }
}
