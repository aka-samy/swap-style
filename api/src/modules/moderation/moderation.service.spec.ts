import { Test, TestingModule } from '@nestjs/testing';
import { ModerationService } from './moderation.service';
import { PrismaService } from '../../common/prisma/prisma.service';
import { ForbiddenException, NotFoundException } from '@nestjs/common';

describe('ModerationService', () => {
  let service: ModerationService;
  let prisma: jest.Mocked<PrismaService>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ModerationService,
        {
          provide: PrismaService,
          useValue: {
            report: {
              findFirst: jest.fn(),
              create: jest.fn(),
              findMany: jest.fn(),
              update: jest.fn(),
            },
            block: {
              findFirst: jest.fn(),
              create: jest.fn(),
              deleteMany: jest.fn(),
            },
            user: { findUnique: jest.fn() },
          },
        },
      ],
    }).compile();

    service = module.get<ModerationService>(ModerationService);
    prisma = module.get(PrismaService);
  });

  describe('reportUser', () => {
    it('creates a report for a valid target user', async () => {
      (prisma.user.findUnique as jest.Mock).mockResolvedValue({ id: 'u2' });
      (prisma.report.findFirst as jest.Mock).mockResolvedValue(null);
      (prisma.report.create as jest.Mock).mockResolvedValue({ id: 'rep1' });

      await service.reportUser('u1', {
        targetUserId: 'u2',
        reason: 'Spam',
      });

      expect(prisma.report.create).toHaveBeenCalled();
    });

    it('throws ForbiddenException when reporting self', async () => {
      await expect(
        service.reportUser('u1', { targetUserId: 'u1', reason: 'Test' }),
      ).rejects.toThrow(ForbiddenException);
    });

    it('throws NotFoundException when target user not found', async () => {
      (prisma.user.findUnique as jest.Mock).mockResolvedValue(null);

      await expect(
        service.reportUser('u1', { targetUserId: 'u2', reason: 'Test' }),
      ).rejects.toThrow(NotFoundException);
    });

    it('throws ForbiddenException for duplicate report', async () => {
      (prisma.user.findUnique as jest.Mock).mockResolvedValue({ id: 'u2' });
      (prisma.report.findFirst as jest.Mock).mockResolvedValue({ id: 'rep1' });

      await expect(
        service.reportUser('u1', { targetUserId: 'u2', reason: 'Spam' }),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('blockUser / unblockUser', () => {
    it('creates a block record', async () => {
      (prisma.user.findUnique as jest.Mock).mockResolvedValue({ id: 'u2' });
      (prisma.block.findFirst as jest.Mock).mockResolvedValue(null);
      (prisma.block.create as jest.Mock).mockResolvedValue({ id: 'blk1' });

      await service.blockUser('u1', 'u2');

      expect(prisma.block.create).toHaveBeenCalled();
    });

    it('unblocks a previously blocked user', async () => {
      (prisma.block.deleteMany as jest.Mock).mockResolvedValue({ count: 1 });

      await service.unblockUser('u1', 'u2');

      expect(prisma.block.deleteMany).toHaveBeenCalledWith({
        where: { blockerId: 'u1', blockedId: 'u2' },
      });
    });
  });
});
