import { Test, TestingModule } from '@nestjs/testing';
import { MatchingService } from './matching.service';
import { PrismaService } from '../../common/prisma/prisma.service';
import { GamificationService } from '../gamification/gamification.service';

describe('MatchingService', () => {
  let service: MatchingService;

  const mockPrisma = {
    match: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
      count: jest.fn(),
    },
    like: { findFirst: jest.fn() },
  };

  const mockGamification = { recordActivity: jest.fn() };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MatchingService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: GamificationService, useValue: mockGamification },
      ],
    }).compile();

    service = module.get<MatchingService>(MatchingService);
    jest.clearAllMocks();
  });

  describe('findAll', () => {
    it('should return paginated matches for user', async () => {
      const mockMatches = [
        {
          id: 'match-1',
          userAId: 'user-1',
          userBId: 'user-2',
          status: 'pending',
          createdAt: new Date(),
        },
      ];
      mockPrisma.match.findMany.mockResolvedValue(mockMatches);
      mockPrisma.match.count.mockResolvedValue(1);

      const result = await service.findAll('user-1', { page: 1, limit: 20 });

      expect(result.data).toHaveLength(1);
      expect(result.meta.total).toBe(1);
    });

    it('should filter by status', async () => {
      mockPrisma.match.findMany.mockResolvedValue([]);
      mockPrisma.match.count.mockResolvedValue(0);

      await service.findAll('user-1', {
        page: 1,
        limit: 20,
        status: 'pending',
      });

      expect(mockPrisma.match.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            status: { in: ['pending'] },
          }),
        }),
      );
    });
  });

  describe('findOne', () => {
    it('should return match by id', async () => {
      const mockMatch = {
        id: 'match-1',
        userAId: 'user-1',
        userBId: 'user-2',
        status: 'pending',
      };
      mockPrisma.match.findUnique.mockResolvedValue(mockMatch);

      const result = await service.findOne('match-1', 'user-1');
      expect(result.id).toBe('match-1');
    });

    it('should throw NotFoundException for non-existent match', async () => {
      mockPrisma.match.findUnique.mockResolvedValue(null);

      await expect(
        service.findOne('non-existent', 'user-1'),
      ).rejects.toThrow();
    });

    it('should throw ForbiddenException if user is not part of match', async () => {
      mockPrisma.match.findUnique.mockResolvedValue({
        id: 'match-1',
        userAId: 'other-1',
        userBId: 'other-2',
      });

      await expect(
        service.findOne('match-1', 'user-1'),
      ).rejects.toThrow();
    });
  });

  describe('confirmMatch', () => {
    it('should update match status to awaiting_confirmation on first confirm', async () => {
      mockPrisma.match.findUnique.mockResolvedValue({
        id: 'match-1',
        userAId: 'user-1',
        userBId: 'user-2',
        status: 'agreed',
        userAConfirmed: false,
        userBConfirmed: false,
      });
      mockPrisma.match.update.mockResolvedValue({
        id: 'match-1',
        status: 'awaiting_confirmation',
        userAConfirmed: true,
      });

      const result = await service.confirmMatch('match-1', 'user-1');

      expect(mockPrisma.match.update).toHaveBeenCalled();
    });

    it('should complete match when both users confirm', async () => {
      mockPrisma.match.findUnique.mockResolvedValue({
        id: 'match-1',
        userAId: 'user-1',
        userBId: 'user-2',
        status: 'awaiting_confirmation',
        userAConfirmed: false,
        userBConfirmed: true,
      });
      mockPrisma.match.update.mockResolvedValue({
        id: 'match-1',
        status: 'completed',
        userAConfirmed: true,
        userBConfirmed: true,
      });

      const result = await service.confirmMatch('match-1', 'user-1');

      expect(mockPrisma.match.update).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            status: 'completed',
          }),
        }),
      );
    });
  });

  describe('cancelMatch', () => {
    it('should cancel a pending match', async () => {
      mockPrisma.match.findUnique.mockResolvedValue({
        id: 'match-1',
        userAId: 'user-1',
        userBId: 'user-2',
        status: 'pending',
      });
      mockPrisma.match.update.mockResolvedValue({
        id: 'match-1',
        status: 'canceled',
      });

      await service.cancelMatch('match-1', 'user-1');

      expect(mockPrisma.match.update).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ status: 'canceled' }),
        }),
      );
    });
  });
});
