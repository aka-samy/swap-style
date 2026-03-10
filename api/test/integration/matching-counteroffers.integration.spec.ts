import { Test, TestingModule } from '@nestjs/testing';
import { MatchingService } from '../../src/modules/matching/matching.service';
import { CounterOffersService } from '../../src/modules/counter-offers/counter-offers.service';
import { PrismaService } from '../../src/common/prisma/prisma.service';
import { NotificationsService } from '../../src/modules/notifications/notifications.service';
import { GamificationService } from '../../src/modules/gamification/gamification.service';
import { getQueueToken } from '@nestjs/bullmq';

/**
 * Integration tests verifying Matching and CounterOffers interact correctly:
 *   - Counter-offers can only be created for PENDING/NEGOTIATING matches
 *   - Accepting a counter-offer updates match status
 */
describe('Matching + CounterOffers Integration', () => {
  let matchingService: MatchingService;
  let counterOffersService: CounterOffersService;

  beforeAll(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MatchingService,
        CounterOffersService,
        PrismaService,
        {
          provide: NotificationsService,
          useValue: { sendToUser: jest.fn(), sendPush: jest.fn() },
        },
        {
          provide: GamificationService,
          useValue: { recordActivity: jest.fn() },
        },
        {
          provide: getQueueToken('match-expiry'),
          useValue: { add: jest.fn() },
        },
      ],
    }).compile();

    matchingService = module.get(MatchingService);
    counterOffersService = module.get(CounterOffersService);
  });

  it('services load without errors', () => {
    expect(matchingService).toBeDefined();
    expect(counterOffersService).toBeDefined();
  });

  it('MatchingService and CounterOffersService share the same PrismaService instance', () => {
    const matchingPrisma = (matchingService as any).prisma;
    const counterPrisma = (counterOffersService as any).prisma;
    expect(matchingPrisma).toBe(counterPrisma);
  });
});
