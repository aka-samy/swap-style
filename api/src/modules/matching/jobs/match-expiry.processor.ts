import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Injectable, Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import { PrismaService } from '../../../common/prisma/prisma.service';
import { NotificationsService } from '../../notifications/notifications.service';
import { MatchStatus } from '@prisma/client';

@Processor('match-expiry')
@Injectable()
export class MatchExpiryProcessor extends WorkerHost {
  private readonly logger = new Logger(MatchExpiryProcessor.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly notifications: NotificationsService,
  ) {
    super();
  }

  async process(job: Job): Promise<void> {
    switch (job.name) {
      case 'check-expiry':
        await this.checkExpiringMatches();
        break;
      case 'expire-match':
        await this.expireMatch(job.data.matchId);
        break;
      default:
        this.logger.warn(`Unknown job: ${job.name}`);
    }
  }

  private async checkExpiringMatches() {
    const now = new Date();
    const warningThreshold = new Date(now.getTime() - 13 * 24 * 60 * 60 * 1000); // 13 days ago
    const expiryThreshold = new Date(now.getTime() - 14 * 24 * 60 * 60 * 1000); // 14 days ago

    // Expire matches older than 14 days
    const expiredMatches = await this.prisma.match.findMany({
      where: {
        status: { in: [MatchStatus.pending, MatchStatus.negotiating] },
        lastActivityAt: { lt: expiryThreshold },
      },
    });

    for (const match of expiredMatches) {
      await this.expireMatch(match.id);
    }

    // Send 24h warnings for matches about to expire
    const warningMatches = await this.prisma.match.findMany({
      where: {
        status: { in: [MatchStatus.pending, MatchStatus.negotiating] },
        lastActivityAt: { gte: expiryThreshold, lt: warningThreshold },
      },
    });

    for (const match of warningMatches) {
      await this.notifications.sendPush(match.userAId, {
        type: 'match_expiry_warning',
        title: 'Match Expiring Soon',
        body: 'Your match will expire in 24 hours. Take action now!',
        data: { matchId: match.id },
      });
      await this.notifications.sendPush(match.userBId, {
        type: 'match_expiry_warning',
        title: 'Match Expiring Soon',
        body: 'Your match will expire in 24 hours. Take action now!',
        data: { matchId: match.id },
      });
    }

    this.logger.log(
      `Processed ${expiredMatches.length} expired, ${warningMatches.length} warnings`,
    );
  }

  private async expireMatch(matchId: string) {
    const match = await this.prisma.match.update({
      where: { id: matchId },
      data: { status: MatchStatus.expired },
    });

    await this.notifications.sendPush(match.userAId, {
      type: 'match_expired',
      title: 'Match Expired',
      body: 'A match has expired due to inactivity.',
      data: { matchId },
    });
    await this.notifications.sendPush(match.userBId, {
      type: 'match_expired',
      title: 'Match Expired',
      body: 'A match has expired due to inactivity.',
      data: { matchId },
    });
  }
}
