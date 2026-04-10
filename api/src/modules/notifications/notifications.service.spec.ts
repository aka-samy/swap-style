import { Test, TestingModule } from '@nestjs/testing';
import { NotificationsService } from './notifications.service';
import { PrismaService } from '../../common/prisma/prisma.service';

describe('NotificationsService', () => {
  let service: NotificationsService;

  const mockPrisma = {
    notification: {
      create: jest.fn(),
      findMany: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
      updateMany: jest.fn(),
      count: jest.fn(),
    },
    user: { findUnique: jest.fn() },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        NotificationsService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<NotificationsService>(NotificationsService);
    jest.clearAllMocks();
  });

  describe('sendPush', () => {
    it('should create notification record and send FCM push', async () => {
      mockPrisma.user.findUnique.mockResolvedValue({
        id: 'user-1',
        fcmToken: 'test-token',
      });
      mockPrisma.notification.create.mockResolvedValue({
        id: 'notif-1',
        userId: 'user-1',
        type: 'new_match',
      });

      await service.sendPush('user-1', {
        type: 'new_match',
        title: 'New Match!',
        body: 'You matched with Jane',
        data: { matchId: 'match-1' },
      });

      expect(mockPrisma.notification.create).toHaveBeenCalled();
    });

    it('should not send FCM if user has no token', async () => {
      mockPrisma.user.findUnique.mockResolvedValue({
        id: 'user-1',
        fcmToken: null,
      });
      mockPrisma.notification.create.mockResolvedValue({
        id: 'notif-1',
      });

      await service.sendPush('user-1', {
        type: 'new_match',
        title: 'New Match!',
        body: 'You matched',
        data: {},
      });

      expect(mockPrisma.notification.create).toHaveBeenCalled();
    });
  });

  describe('findAll', () => {
    it('should return paginated notifications', async () => {
      mockPrisma.notification.findMany.mockResolvedValue([
        { id: 'n1', type: 'new_match', read: false },
      ]);
      mockPrisma.notification.count.mockResolvedValue(1);

      const result = await service.findAll('user-1', { page: 1, limit: 20 });

      expect(result.data).toHaveLength(1);
    });
  });

  describe('markRead', () => {
    it('should mark notification as read', async () => {
      mockPrisma.notification.findUnique.mockResolvedValue({
        id: 'n1',
        userId: 'user-1',
      });
      mockPrisma.notification.update.mockResolvedValue({
        id: 'n1',
        readAt: expect.any(Date),
      });

      await service.markRead('n1', 'user-1');

      expect(mockPrisma.notification.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: 'n1' },
          data: { readAt: expect.any(Date) },
        }),
      );
    });
  });
});
