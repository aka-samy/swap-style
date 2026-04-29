/* eslint-env jest */
import { Test, TestingModule } from '@nestjs/testing';
import { RatingsService } from './ratings.service';
import { PrismaService } from '../../common/prisma/prisma.service';
import { GamificationService } from '../gamification/gamification.service';
import { BadRequestException, ForbiddenException } from '@nestjs/common';

const mockPrisma = {
  rating: {
    create: jest.fn(),
    findMany: jest.fn(),
    findFirst: jest.fn(),
    aggregate: jest.fn(),
  },
  match: { findUnique: jest.fn() },
};

const mockGamification = { recordActivity: jest.fn().mockResolvedValue(undefined) };

describe('RatingsService', () => {
  let service: RatingsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RatingsService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: GamificationService, useValue: mockGamification },
      ],
    }).compile();
    service = module.get<RatingsService>(RatingsService);
    jest.clearAllMocks();
  });

  describe('createRating', () => {
    it('creates a rating for a completed match participant', async () => {
      mockPrisma.match.findUnique.mockResolvedValue({
        id: 'match-1',
        userAId: 'user-a',
        userBId: 'user-b',
        status: 'completed',
      });
      mockPrisma.rating.findFirst.mockResolvedValue(null);
      mockPrisma.rating.create.mockResolvedValue({
        id: 'rating-1',
        matchId: 'match-1',
        raterId: 'user-a',
        rateeId: 'user-b',
        score: 5,
      });

      const result = await service.createRating('match-1', 'user-a', {
        score: 5,
        comment: 'Great swap!',
      });
      expect(result.score).toBe(5);
    });

    it('throws BadRequestException if match is not completed', async () => {
      mockPrisma.match.findUnique.mockResolvedValue({
        id: 'match-1',
        userAId: 'user-a',
        userBId: 'user-b',
        status: 'pending',
      });

      await expect(
        service.createRating('match-1', 'user-a', { score: 5 }),
      ).rejects.toThrow(BadRequestException);
    });

    it('throws ForbiddenException if already rated this match', async () => {
      mockPrisma.match.findUnique.mockResolvedValue({
        id: 'match-1',
        userAId: 'user-a',
        userBId: 'user-b',
        status: 'completed',
      });
      mockPrisma.rating.findFirst.mockResolvedValue({ id: 'existing-rating' });

      await expect(
        service.createRating('match-1', 'user-a', { score: 4 }),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('getUserRatings', () => {
    it('returns ratings list and average for a user', async () => {
      mockPrisma.rating.findMany.mockResolvedValue([
        { id: 'r1', score: 5, comment: 'Great!' },
      ]);
      mockPrisma.rating.aggregate.mockResolvedValue({ _avg: { score: 5 } });

      const result = await service.getUserRatings('user-b');
      expect(result.ratings).toHaveLength(1);
      expect(result.average).toBe(5);
    });
  });
});
