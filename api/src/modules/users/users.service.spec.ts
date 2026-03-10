import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { PrismaService } from '../../common/prisma/prisma.service';
import { StorageService } from '../../common/storage/storage.service';

describe('UsersService', () => {
  let service: UsersService;

  const mockPrisma = {
    user: { findUnique: jest.fn(), update: jest.fn() },
    item: { findMany: jest.fn(), count: jest.fn() },
    wishlistEntry: {
      findMany: jest.fn(),
      create: jest.fn(),
      delete: jest.fn(),
      count: jest.fn(),
    },
    rating: { aggregate: jest.fn() },
  };

  const mockStorage = {
    getPresignedUploadUrl: jest.fn(),
    getPublicUrl: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: StorageService, useValue: mockStorage },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    jest.clearAllMocks();
  });

  describe('getProfile', () => {
    it('should return user profile with stats', async () => {
      mockPrisma.user.findUnique.mockResolvedValue({
        id: 'user-1',
        displayName: 'John',
        email: 'john@example.com',
        profilePhotoUrl: null,
      });
      mockPrisma.item.count.mockResolvedValue(5);
      mockPrisma.rating.aggregate.mockResolvedValue({ _avg: { score: 4.5 } });

      const result = await service.getProfile('user-1');

      expect(result.displayName).toBe('John');
    });

    it('should throw NotFoundException for non-existent user', async () => {
      mockPrisma.user.findUnique.mockResolvedValue(null);

      await expect(service.getProfile('non-existent')).rejects.toThrow();
    });
  });

  describe('updateProfile', () => {
    it('should update user display name', async () => {
      mockPrisma.user.update.mockResolvedValue({
        id: 'user-1',
        displayName: 'New Name',
      });

      const result = await service.updateProfile('user-1', {
        displayName: 'New Name',
      });

      expect(result.displayName).toBe('New Name');
    });
  });

  describe('getPublicProfile', () => {
    it('should return public profile without sensitive data', async () => {
      mockPrisma.user.findUnique.mockResolvedValue({
        id: 'user-2',
        displayName: 'Jane',
        profilePhotoUrl: null,
        emailVerified: true,
        phoneVerified: false,
        createdAt: new Date(),
      });
      mockPrisma.item.count.mockResolvedValue(3);
      mockPrisma.rating.aggregate.mockResolvedValue({ _avg: { score: 4.0 } });

      const result = await service.getPublicProfile('user-2');

      expect(result.displayName).toBe('Jane');
      expect(result).not.toHaveProperty('email');
    });
  });

  describe('wishlist', () => {
    it('should add wishlist entry', async () => {
      mockPrisma.wishlistEntry.create.mockResolvedValue({
        id: 'wl-1',
        userId: 'user-1',
        category: 'tops',
        size: 'm',
      });

      const result = await service.addWishlistEntry('user-1', {
        category: 'Shirt' as any,
        size: 'M' as any,
      });

      expect(result.category).toBe('tops');
    });

    it('should list wishlist entries', async () => {
      mockPrisma.wishlistEntry.findMany.mockResolvedValue([
        { id: 'wl-1', category: 'tops', size: 'm' },
      ]);

      const result = await service.getWishlist('user-1');

      expect(result).toHaveLength(1);
    });

    it('should delete wishlist entry', async () => {
      mockPrisma.wishlistEntry.delete.mockResolvedValue({
        id: 'wl-1',
      });

      await expect(
        service.removeWishlistEntry('wl-1', 'user-1'),
      ).resolves.not.toThrow();
    });
  });
});
