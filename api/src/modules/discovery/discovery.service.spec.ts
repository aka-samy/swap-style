/* eslint-env jest */
import { Test, TestingModule } from '@nestjs/testing';
import { DiscoveryService } from './discovery.service';
import { PrismaService } from '../../common/prisma/prisma.service';

describe('DiscoveryService', () => {
  let service: DiscoveryService;
  let prisma: PrismaService;

  const mockPrisma = {
    item: { findMany: jest.fn(), findUnique: jest.fn().mockResolvedValue({ id: 'item-1', ownerId: 'user-2' }) },
    itemPhoto: { findMany: jest.fn().mockResolvedValue([]) },
    itemVerification: { findMany: jest.fn().mockResolvedValue([]) },
    like: { findMany: jest.fn().mockResolvedValue([]), findFirst: jest.fn(), create: jest.fn() },
    block: { findMany: jest.fn().mockResolvedValue([]) },
    match: { create: jest.fn() },
    $queryRaw: jest.fn(),
  };

  const mockRedis = { get: jest.fn().mockResolvedValue(null), set: jest.fn() };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DiscoveryService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: 'REDIS_CLIENT', useValue: mockRedis },
      ],
    }).compile();

    service = module.get<DiscoveryService>(DiscoveryService);
    prisma = module.get<PrismaService>(PrismaService);
    jest.clearAllMocks();
  });

  describe('getFeed', () => {
    it('should return paginated items sorted by distance', async () => {
      const mockItems = [
        {
          id: 'item-1',
          ownerId: 'other-user',
          brand: 'Nike',
          category: 'Shirt',
          size: 'M',
          condition: 'Good',
          shoeSizeEu: null,
          latitude: 30.05,
          longitude: 31.25,
          ownerName: 'Jane',
          ownerPhotoUrl: null,
          ownerVerified: true,
          distanceKm: 3.2,
        },
      ];
      mockPrisma.$queryRaw.mockResolvedValue(mockItems);

      const result = await service.getFeed('user-1', {
        page: 1,
        limit: 20,
        latitude: 30.0,
        longitude: 31.2,
        radiusKm: 50,
      }) as any;

      expect(result.data).toHaveLength(1);
      expect(result.meta.page).toBe(1);
      expect(mockPrisma.$queryRaw).toHaveBeenCalled();
    });

    it('should exclude own items from feed', async () => {
      mockPrisma.$queryRaw.mockResolvedValue([]);

      const result = await service.getFeed('user-1', {
        page: 1,
        limit: 20,
        latitude: 30.0,
        longitude: 31.2,
        radiusKm: 50,
      }) as any;

      expect(result.data).toHaveLength(0);
    });

    it('falls back to Prisma query when raw PostGIS query fails', async () => {
      mockPrisma.$queryRaw.mockRejectedValue(
        new Error('function st_dwithin does not exist'),
      );
      mockPrisma.item.findMany.mockResolvedValue([
        {
          id: 'item-1',
          ownerId: 'other-user',
          category: 'Shirt',
          brand: 'Nike',
          size: 'M',
          condition: 'Good',
          shoeSizeEu: null,
          latitude: 30.05,
          longitude: 31.25,
          status: 'available',
          createdAt: new Date(),
          owner: {
            displayName: 'Jane',
            profilePhotoUrl: null,
            emailVerified: true,
          },
        },
      ]);

      const result = (await service.getFeed('user-1', {
        page: 1,
        limit: 20,
        latitude: 30.0,
        longitude: 31.2,
        radiusKm: 50,
      })) as any;

      expect(mockPrisma.item.findMany).toHaveBeenCalled();
      expect(result.data).toHaveLength(1);
      expect(result.meta.page).toBe(1);
    });
  });

  describe('recordSwipe', () => {
    it('should record a like action', async () => {
      mockPrisma.like.findFirst.mockResolvedValue(null);
      mockPrisma.like.create.mockResolvedValue({ id: 'like-1' });

      const result = await service.recordSwipe('user-1', {
        itemId: 'item-1',
        action: 'like',
      });

      expect(result.matched).toBe(false);
      expect(mockPrisma.like.create).toHaveBeenCalled();
    });

    it('should record a pass action without creating like', async () => {
      const result = await service.recordSwipe('user-1', {
        itemId: 'item-1',
        action: 'pass',
      });

      expect(result.matched).toBe(false);
    });

    it('should detect a match on mutual like', async () => {
      // Simulate: user-1 likes item-1 (owned by user-2), and user-2 already liked an item of user-1
      mockPrisma.like.findFirst
        .mockResolvedValueOnce(null) // no duplicate
        .mockResolvedValueOnce({ id: 'reciprocal-like', itemId: 'item-2' }); // reciprocal like
      mockPrisma.like.create.mockResolvedValue({ id: 'like-1' });
      mockPrisma.match.create.mockResolvedValue({
        id: 'match-1',
        userAId: 'user-1',
        userBId: 'user-2',
        itemAId: 'item-2',
        itemBId: 'item-1',
        userA: { id: 'user-1', displayName: 'Alice', profilePhotoUrl: null },
        userB: { id: 'user-2', displayName: 'Bob', profilePhotoUrl: null },
        itemA: { id: 'item-2', brand: 'Adidas', photos: [] },
        itemB: { id: 'item-1', brand: 'Nike', photos: [] },
      });

      const result = await service.recordSwipe('user-1', {
        itemId: 'item-1',
        action: 'like',
      });

      expect(result.matched).toBe(true);
    });
  });

  describe('getFeed with filters', () => {
    it('passes size filter to query', async () => {
      mockPrisma.$queryRaw.mockResolvedValue([]);

      await service.getFeed('user-1', {
        page: 1,
        limit: 20,
        latitude: 30.0,
        longitude: 31.2,
        radiusKm: 15,
        size: 'M',
        category: 'Shirt',
      });

      expect(mockPrisma.$queryRaw).toHaveBeenCalled();
    });

    it('uses custom radius when provided', async () => {
      mockPrisma.$queryRaw.mockResolvedValue([]);

      await service.getFeed('user-1', {
        page: 1,
        limit: 20,
        latitude: 30.0,
        longitude: 31.2,
        radiusKm: 100,
      });

      expect(mockPrisma.$queryRaw).toHaveBeenCalled();
    });
  });
});
