import { Test, TestingModule } from '@nestjs/testing';
import { GamificationService } from './gamification.service';
import { PrismaService } from '../../common/prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';

describe('GamificationService', () => {
  let service: GamificationService;
  let prisma: jest.Mocked<PrismaService>;
  let notifications: jest.Mocked<NotificationsService>;

  const mockUser = {
    id: 'user1',
    displayName: 'Alice',
    streak: {
      id: 'streak1',
      userId: 'user1',
      currentStreak: 3,
      longestStreak: 7,
      lastActivityAt: new Date(),
      updatedAt: new Date(),
    },
    userBadges: [],
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        GamificationService,
        {
          provide: PrismaService,
          useValue: {
            streak: {
              upsert: jest.fn(),
              findUnique: jest.fn(),
              updateMany: jest.fn(),
            },
            badge: { findMany: jest.fn() },
            userBadge: { findFirst: jest.fn(), create: jest.fn() },
            user: {
              findUnique: jest.fn().mockResolvedValue(mockUser),
            },
          },
        },
        {
          provide: NotificationsService,
          useValue: { sendToUser: jest.fn() },
        },
      ],
    }).compile();

    service = module.get<GamificationService>(GamificationService);
    prisma = module.get(PrismaService);
    notifications = module.get(NotificationsService);
  });

  describe('recordActivity', () => {
    it('increments streak when activity happens same calendar day', async () => {
      const today = new Date();
      (prisma.streak.upsert as jest.Mock).mockResolvedValue({
        ...mockUser.streak,
        currentStreak: 4,
        lastActivityAt: today,
      });
      (prisma.badge.findMany as jest.Mock).mockResolvedValue([]);

      await service.recordActivity('user1');

      expect(prisma.streak.upsert).toHaveBeenCalled();
    });

    it('checks for badge award after activity', async () => {
      (prisma.streak.upsert as jest.Mock).mockResolvedValue({
        ...mockUser.streak,
        currentStreak: 7,
      });
      (prisma.badge.findMany as jest.Mock).mockResolvedValue([
        {
          id: 'b1',
          slug: 'streak_7',
          name: '7-Day Streak',
          criteriaType: 'streak_days',
          criteriaValue: 7,
        },
      ]);
      (prisma.userBadge.findFirst as jest.Mock).mockResolvedValue(null);
      (prisma.userBadge.create as jest.Mock).mockResolvedValue({});

      await service.recordActivity('user1');

      expect(prisma.userBadge.create).toHaveBeenCalled();
      expect(notifications.sendToUser).toHaveBeenCalledWith(
        'user1',
        expect.objectContaining({ type: 'swap_completed' }),
      );
    });
  });

  describe('getUserStats', () => {
    it('returns streak and badges for user', async () => {
      (prisma.user.findUnique as jest.Mock).mockResolvedValue(mockUser);

      const stats = await service.getUserStats('user1');

      expect(stats).toHaveProperty('streak');
      expect(stats).toHaveProperty('badges');
    });
  });

  describe('resetExpiredStreaks', () => {
    it('resets streaks where lastActivityAt is more than 25h ago', async () => {
      (prisma.streak.updateMany as jest.Mock).mockResolvedValue({ count: 3 });

      await service.resetExpiredStreaks();

      expect(prisma.streak.updateMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            lastActivityAt: expect.any(Object),
          }),
        }),
      );
    });
  });
});
