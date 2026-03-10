import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { BadgeCriteriaType, NotificationType } from '@prisma/client';

@Injectable()
export class GamificationService {
  private readonly logger = new Logger(GamificationService.name);

  constructor(
    private prisma: PrismaService,
    private notifications: NotificationsService,
  ) {}

  /**
   * Record user activity — bumps the streak and checks for badge awards.
   * Call this after a swap is confirmed, a rating is submitted, etc.
   */
  async recordActivity(userId: string): Promise<void> {
    const now = new Date();

    const streak = await this.prisma.streak.upsert({
      where: { userId },
      create: {
        userId,
        currentStreak: 1,
        longestStreak: 1,
        lastActivityAt: now,
      },
      update: {
        currentStreak: { increment: 1 },
        lastActivityAt: now,
      },
    });

    // Ensure longestStreak stays accurate
    if (streak.currentStreak > streak.longestStreak) {
      await this.prisma.streak.update({
        where: { userId },
        data: { longestStreak: streak.currentStreak },
      });
    }

    await this.checkAndAwardBadges(userId, streak.currentStreak);
  }

  /**
   * Returns the streak and earned badges for a user.
   */
  async getUserStats(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        streak: true,
        userBadges: {
          include: { badge: true },
          orderBy: { awardedAt: 'desc' },
        },
      },
    });

    return {
      streak: user?.streak ?? null,
      badges: (user?.userBadges ?? []).map((ub) => ({
        ...ub.badge,
        awardedAt: ub.awardedAt,
      })),
    };
  }

  /**
   * Resets streaks that have not had activity in the last 25 hours.
   * Called by the daily BullMQ job (streak-reset.processor.ts).
   */
  async resetExpiredStreaks(): Promise<void> {
    const cutoff = new Date(Date.now() - 25 * 60 * 60 * 1000);

    const result = await this.prisma.streak.updateMany({
      where: { lastActivityAt: { lt: cutoff } },
      data: { currentStreak: 0 },
    });

    this.logger.log(`Reset ${result.count} expired streaks`);
  }

  // ─── private ──────────────────────────────────────────

  private async checkAndAwardBadges(
    userId: string,
    currentStreak: number,
  ): Promise<void> {
    const eligibleBadges = await this.prisma.badge.findMany({
      where: {
        criteriaType: BadgeCriteriaType.streak_days,
        criteriaValue: { lte: currentStreak },
      },
    });

    for (const badge of eligibleBadges) {
      const alreadyHas = await this.prisma.userBadge.findFirst({
        where: { userId, badgeId: badge.id },
      });

      if (!alreadyHas) {
        await this.prisma.userBadge.create({
          data: { userId, badgeId: badge.id },
        });

        this.logger.log(`Awarded badge ${badge.slug} to user ${userId}`);

        await this.notifications.sendToUser(userId, {
          type: NotificationType.swap_completed,
          title: `Badge Earned: ${badge.name}`,
          body: badge.description,
        });
      }
    }
  }
}
