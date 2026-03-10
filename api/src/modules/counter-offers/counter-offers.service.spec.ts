import { Test, TestingModule } from '@nestjs/testing';
import { CounterOffersService } from './counter-offers.service';
import { PrismaService } from '../../common/prisma/prisma.service';

describe('CounterOffersService', () => {
  let service: CounterOffersService;

  const mockPrisma = {
    match: { findUnique: jest.fn(), update: jest.fn() },
    counterOffer: {
      create: jest.fn(),
      findMany: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
      updateMany: jest.fn(),
      count: jest.fn(),
    },
    counterOfferItem: { createMany: jest.fn() },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CounterOffersService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<CounterOffersService>(CounterOffersService);
    jest.clearAllMocks();
  });

  describe('propose', () => {
    it('should create a counter-offer with items', async () => {
      mockPrisma.match.findUnique.mockResolvedValue({
        id: 'match-1',
        userAId: 'user-1',
        userBId: 'user-2',
        status: 'pending',
      });
      mockPrisma.counterOffer.count.mockResolvedValue(0);
      mockPrisma.counterOffer.create.mockResolvedValue({
        id: 'co-1',
        matchId: 'match-1',
        proposerId: 'user-1',
        status: 'pending',
      });
      mockPrisma.match.update.mockResolvedValue({ id: 'match-1', status: 'negotiating' });

      const result = await service.propose('match-1', 'user-1', {
        items: [{ itemId: 'item-extra' }],
        monetaryAmount: 10,
        message: 'How about adding this?',
      });

      expect(result.id).toBe('co-1');
    });

    it('should reject if user exceeds 5 offers per side', async () => {
      mockPrisma.match.findUnique.mockResolvedValue({
        id: 'match-1',
        userAId: 'user-1',
        userBId: 'user-2',
        status: 'negotiating',
      });
      mockPrisma.counterOffer.count.mockResolvedValue(5);

      await expect(
        service.propose('match-1', 'user-1', {
          items: [],
          monetaryAmount: 0,
        }),
      ).rejects.toThrow();
    });
  });

  describe('accept', () => {
    it('should accept a counter-offer and update match status', async () => {
      mockPrisma.counterOffer.findUnique.mockResolvedValue({
        id: 'co-1',
        matchId: 'match-1',
        proposerId: 'user-1',
        status: 'pending',
        match: { userAId: 'user-1', userBId: 'user-2' },
      });
      mockPrisma.counterOffer.update.mockResolvedValue({ id: 'co-1', status: 'accepted' });
      mockPrisma.match.update.mockResolvedValue({ id: 'match-1', status: 'agreed' });

      await service.accept('co-1', 'user-2');

      expect(mockPrisma.counterOffer.update).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ status: 'accepted' }),
        }),
      );
    });

    it('should reject if proposer tries to accept own offer', async () => {
      mockPrisma.counterOffer.findUnique.mockResolvedValue({
        id: 'co-1',
        matchId: 'match-1',
        proposerId: 'user-1',
        status: 'pending',
        match: { userAId: 'user-1', userBId: 'user-2' },
      });

      await expect(
        service.accept('co-1', 'user-1'),
      ).rejects.toThrow();
    });
  });

  describe('decline', () => {
    it('should decline a counter-offer', async () => {
      mockPrisma.counterOffer.findUnique.mockResolvedValue({
        id: 'co-1',
        matchId: 'match-1',
        proposerId: 'user-1',
        status: 'pending',
        match: { userAId: 'user-1', userBId: 'user-2' },
      });
      mockPrisma.counterOffer.update.mockResolvedValue({ id: 'co-1', status: 'declined' });

      await service.decline('co-1', 'user-2');

      expect(mockPrisma.counterOffer.update).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ status: 'declined' }),
        }),
      );
    });
  });
});
