/* eslint-env jest */
import { Test, TestingModule } from '@nestjs/testing';
import { ChatService } from './chat.service';
import { PrismaService } from '../../common/prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { NotFoundException, ForbiddenException } from '@nestjs/common';

const mockPrisma = {
  message: {
    create: jest.fn(),
    findMany: jest.fn(),
    updateMany: jest.fn(),
  },
  match: { findUnique: jest.fn() },
};

const mockNotifications = { sendToUser: jest.fn().mockResolvedValue(undefined) };

describe('ChatService', () => {
  let service: ChatService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ChatService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: NotificationsService, useValue: mockNotifications },
      ],
    }).compile();
    service = module.get<ChatService>(ChatService);
    jest.clearAllMocks();
  });

  describe('createMessage', () => {
    it('persists a message for a valid match participant', async () => {
      mockPrisma.match.findUnique.mockResolvedValue({
        id: 'match-1',
        userAId: 'user-a',
        userBId: 'user-b',
      });
      const mockMsg = {
        id: 'msg-1',
        matchId: 'match-1',
        senderId: 'user-a',
        text: 'Hi!',
        readAt: null,
        createdAt: new Date(),
      };
      mockPrisma.message.create.mockResolvedValue(mockMsg);

      const result = await service.createMessage('match-1', 'user-a', 'Hi!');
      expect(result).toEqual(mockMsg);
      expect(mockPrisma.message.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ text: 'Hi!', senderId: 'user-a' }),
        }),
      );
    });

    it('throws ForbiddenException if user is not a match participant', async () => {
      mockPrisma.match.findUnique.mockResolvedValue({
        id: 'match-1',
        userAId: 'user-a',
        userBId: 'user-b',
      });

      await expect(
        service.createMessage('match-1', 'user-x', 'Hi!'),
      ).rejects.toThrow(ForbiddenException);
    });

    it('throws NotFoundException if match does not exist', async () => {
      mockPrisma.match.findUnique.mockResolvedValue(null);

      await expect(
        service.createMessage('match-x', 'user-a', 'Hi!'),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('listMessages', () => {
    it('returns paginated messages with cursor', async () => {
      mockPrisma.match.findUnique.mockResolvedValue({
        id: 'match-1',
        userAId: 'user-a',
        userBId: 'user-b',
      });
      mockPrisma.message.findMany.mockResolvedValue([
        { id: 'msg-1', text: 'Hello', createdAt: new Date() },
      ]);

      const result = await service.listMessages('match-1', 'user-a', {
        limit: 20,
        cursor: undefined,
      });
      expect(result).toHaveLength(1);
    });
  });

  describe('markRead', () => {
    it('marks all unread messages in a match as read', async () => {
      mockPrisma.match.findUnique.mockResolvedValue({
        id: 'match-1',
        userAId: 'user-a',
        userBId: 'user-b',
      });
      mockPrisma.message.updateMany.mockResolvedValue({ count: 3 });

      await service.markRead('match-1', 'user-b');
      expect(mockPrisma.message.updateMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            matchId: 'match-1',
            readAt: null,
          }),
        }),
      );
    });
  });
});
