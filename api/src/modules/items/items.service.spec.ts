import { Test, TestingModule } from '@nestjs/testing';
import { ItemsService } from './items.service';
import { PrismaService } from '../../common/prisma/prisma.service';
import { StorageService } from '../../common/storage/storage.service';
import { NotFoundException, ForbiddenException } from '@nestjs/common';

describe('ItemsService', () => {
  let service: ItemsService;
  let prisma: PrismaService;
  let storage: StorageService;

  const mockPrisma: any = {
    item: {
      create: jest.fn(),
      findUnique: jest.fn(),
      findMany: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
      count: jest.fn(),
    },
    itemPhoto: {
      createMany: jest.fn(),
      deleteMany: jest.fn(),
    },
    itemVerification: {
      create: jest.fn(),
      update: jest.fn(),
    },
    match: {
      updateMany: jest.fn(),
    },
    $transaction: jest.fn((fn: any) => fn(mockPrisma)),
  };

  const mockStorage = {
    getPresignedUploadUrl: jest.fn(),
    deleteObject: jest.fn(),
    getPublicUrl: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ItemsService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: StorageService, useValue: mockStorage },
      ],
    }).compile();

    service = module.get<ItemsService>(ItemsService);
    prisma = module.get<PrismaService>(PrismaService);
    storage = module.get<StorageService>(StorageService);

    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create an item with photos', async () => {
      const userId = 'user-1';
      const dto = {
        category: 'Shirt' as const,
        brand: 'Nike',
        size: 'M' as const,
        condition: 'Good' as const,
        notes: 'Test notes',
        latitude: 30.0,
        longitude: 31.0,
      };

      const createdItem = { id: 'item-1', ownerId: userId, ...dto, status: 'available' };
      mockPrisma.item.create.mockResolvedValue(createdItem);

      const result = await service.create(userId, dto);
      expect(result).toEqual(createdItem);
      expect(mockPrisma.item.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          ownerId: userId,
          category: dto.category,
          brand: dto.brand,
        }),
        include: expect.any(Object),
      });
    });
  });

  describe('findOne', () => {
    it('should return an item by id', async () => {
      const item = { id: 'item-1', ownerId: 'user-1', brand: 'Nike' };
      mockPrisma.item.findUnique.mockResolvedValue(item);

      const result = await service.findOne('item-1');
      expect(result).toEqual(item);
    });

    it('should throw NotFoundException if item not found', async () => {
      mockPrisma.item.findUnique.mockResolvedValue(null);
      await expect(service.findOne('missing')).rejects.toThrow(NotFoundException);
    });
  });

  describe('update', () => {
    it('should update an item owned by the user', async () => {
      const existingItem = { id: 'item-1', ownerId: 'user-1' };
      mockPrisma.item.findUnique.mockResolvedValue(existingItem);
      mockPrisma.item.update.mockResolvedValue({ ...existingItem, brand: 'Adidas' });

      const result = await service.update('item-1', 'user-1', { brand: 'Adidas' });
      expect(result.brand).toBe('Adidas');
    });

    it('should throw ForbiddenException if user does not own the item', async () => {
      const existingItem = { id: 'item-1', ownerId: 'user-2' };
      mockPrisma.item.findUnique.mockResolvedValue(existingItem);

      await expect(service.update('item-1', 'user-1', { brand: 'Adidas' })).rejects.toThrow(
        ForbiddenException,
      );
    });
  });

  describe('remove', () => {
    it('should remove an item and cancel pending matches', async () => {
      const existingItem = { id: 'item-1', ownerId: 'user-1' };
      mockPrisma.item.findUnique.mockResolvedValue(existingItem);
      mockPrisma.item.update.mockResolvedValue({ ...existingItem, status: 'removed' });
      mockPrisma.match.updateMany.mockResolvedValue({ count: 0 });

      await service.remove('item-1', 'user-1');
      expect(mockPrisma.item.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: 'item-1' },
          data: expect.objectContaining({ status: 'removed' }),
        }),
      );
    });

    it('should throw ForbiddenException if user does not own the item', async () => {
      const existingItem = { id: 'item-1', ownerId: 'user-2' };
      mockPrisma.item.findUnique.mockResolvedValue(existingItem);

      await expect(service.remove('item-1', 'user-1')).rejects.toThrow(ForbiddenException);
    });
  });

  describe('findByOwner', () => {
    it('should return paginated items for a user', async () => {
      const items = [{ id: 'item-1' }, { id: 'item-2' }];
      mockPrisma.item.findMany.mockResolvedValue(items);
      mockPrisma.item.count.mockResolvedValue(2);

      const result = await service.findByOwner('user-1', { page: 1, limit: 20 });
      expect(result.data).toEqual(items);
      expect(result.meta.total).toBe(2);
    });
  });

  describe('verifyItem', () => {
    it('should create or update verification record for item owner', async () => {
      const existingItem = { id: 'item-1', ownerId: 'user-1' };
      mockPrisma.item.findUnique.mockResolvedValue(existingItem);
      const verification = {
        id: 'ver-1',
        itemId: 'item-1',
        washed: true,
        noStains: true,
        noTears: true,
        noDefects: true,
        photosAccurate: true,
      };
      mockPrisma.itemVerification.create.mockResolvedValue(verification);

      const result = await service.verifyItem('item-1', 'user-1', {
        washed: true,
        noStains: true,
        noTears: true,
        noDefects: true,
        photosAccurate: true,
      });
      expect(result).toEqual(verification);
    });

    it('should throw ForbiddenException if user does not own the item', async () => {
      mockPrisma.item.findUnique.mockResolvedValue({ id: 'item-1', ownerId: 'user-2' });

      await expect(
        service.verifyItem('item-1', 'user-1', {
          washed: true,
          noStains: true,
          noTears: true,
          noDefects: true,
          photosAccurate: true,
        }),
      ).rejects.toThrow(ForbiddenException);
    });
  });
});
