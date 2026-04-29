/* eslint-env jest */
import { Test, TestingModule } from '@nestjs/testing';
import { ItemsController } from './items.controller';
import { ItemsService } from './items.service';
import { PrismaService } from '../../common/prisma/prisma.service';

describe('ItemsController', () => {
  let controller: ItemsController;
  let service: ItemsService;

  const mockService = {
    create: jest.fn(),
    findOne: jest.fn(),
    findByOwner: jest.fn(),
    update: jest.fn(),
    remove: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ItemsController],
      providers: [
        { provide: ItemsService, useValue: mockService },
        { provide: PrismaService, useValue: {} },
      ],
    }).compile();

    controller = module.get<ItemsController>(ItemsController);
    service = module.get<ItemsService>(ItemsService);

    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('POST /items', () => {
    it('should create an item', async () => {
      const dto = {
        category: 'Shirt' as const,
        brand: 'Nike',
        size: 'M' as const,
        condition: 'Good' as const,
      };
      const req = { user: { userId: 'user-1' } };
      const expected = { id: 'item-1', ...dto };

      mockService.create.mockResolvedValue(expected);
      const result = await controller.create(req as any, dto as any);
      expect(result).toEqual(expected);
      expect(mockService.create).toHaveBeenCalledWith('user-1', dto);
    });
  });

  describe('GET /items/me', () => {
    it('should return user closet items', async () => {
      const req = { user: { userId: 'user-1' } };
      const expected = { data: [], meta: { page: 1, limit: 20, total: 0 } };

      mockService.findByOwner.mockResolvedValue(expected);
      const result = await controller.findMyItems(req as any, { page: 1, limit: 20 });
      expect(result).toEqual(expected);
    });
  });

  describe('GET /items/:id', () => {
    it('should return a single item', async () => {
      const expected = { id: 'item-1', brand: 'Nike' };
      mockService.findOne.mockResolvedValue(expected);

      const result = await controller.findOne('item-1');
      expect(result).toEqual(expected);
    });
  });

  describe('PATCH /items/:id', () => {
    it('should update an item', async () => {
      const req = { user: { userId: 'user-1' } };
      const dto = { brand: 'Adidas' };
      const expected = { id: 'item-1', brand: 'Adidas' };

      mockService.update.mockResolvedValue(expected);
      const result = await controller.update('item-1', req as any, dto as any);
      expect(result).toEqual(expected);
    });
  });

  describe('DELETE /items/:id', () => {
    it('should remove an item', async () => {
      const req = { user: { userId: 'user-1' } };
      mockService.remove.mockResolvedValue(undefined);

      await controller.remove('item-1', req as any);
      expect(mockService.remove).toHaveBeenCalledWith('item-1', 'user-1');
    });
  });
});
