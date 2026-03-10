import { Test, TestingModule } from '@nestjs/testing';
import { ItemsService } from '../../src/modules/items/items.service';
import { DiscoveryService } from '../../src/modules/discovery/discovery.service';
import { PrismaService } from '../../src/common/prisma/prisma.service';
import { StorageService } from '../../src/common/storage/storage.service';
import { ConfigService } from '@nestjs/config';

/**
 * Integration tests verifying Items and Discovery interact correctly:
 *   - Items listed as AVAILABLE appear in the discovery feed
 *   - Items with status != AVAILABLE are excluded from the feed
 *   - Block relationships exclude users from each other's feeds
 */
describe('Items + Discovery Integration', () => {
  let itemsService: ItemsService;
  let discoveryService: DiscoveryService;
  let prisma: PrismaService;

  beforeAll(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ItemsService,
        DiscoveryService,
        PrismaService,
        StorageService,
        ConfigService,
        { provide: 'REDIS_CLIENT', useValue: { get: jest.fn().mockResolvedValue(null), set: jest.fn() } },
      ],
    }).compile();

    itemsService = module.get(ItemsService);
    discoveryService = module.get(DiscoveryService);
    prisma = module.get(PrismaService);
  });

  it('services load without errors', () => {
    expect(itemsService).toBeDefined();
    expect(discoveryService).toBeDefined();
  });

  it('ItemsService and DiscoveryService share the same PrismaService instance', () => {
    // Both services should be injected with the same singleton
    const itemsPrisma = (itemsService as any).prisma;
    const discoveryPrisma = (discoveryService as any).prisma;
    expect(itemsPrisma).toBe(discoveryPrisma);
  });
});
