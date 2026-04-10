import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import {
  AdminItemsQueryDto,
  AdminMatchesQueryDto,
  AdminReportsQueryDto,
  AdminUsersQueryDto,
  ModerateItemDto,
  ResolveReportDto,
  SuspendUserDto,
  UpdateUserRoleDto,
} from './dto/admin.dto';

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

  private normalizePagination(page?: number, limit?: number) {
    const safePage = Math.max(1, page ?? 1);
    const safeLimit = Math.min(100, Math.max(1, limit ?? 20));
    return {
      page: safePage,
      limit: safeLimit,
      skip: (safePage - 1) * safeLimit,
    };
  }

  async getDashboard() {
    const since24h = new Date(Date.now() - 24 * 60 * 60 * 1000);

    const [
      usersTotal,
      usersSuspended,
      pendingReports,
      itemsAvailable,
      activeMatches,
      notificationsUnread,
      notifications24h,
      messagesUnread,
      messages24h,
    ] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.user.count({ where: { suspendedUntil: { gt: new Date() } } }),
      this.prisma.report.count({ where: { status: 'pending' } }),
      this.prisma.item.count({ where: { status: 'available' } }),
      this.prisma.match.count({
        where: {
          status: {
            in: ['pending', 'negotiating', 'agreed', 'awaiting_confirmation'],
          },
        },
      }),
      this.prisma.notification.count({ where: { readAt: null } }),
      this.prisma.notification.count({ where: { createdAt: { gte: since24h } } }),
      this.prisma.message.count({ where: { readAt: null } }),
      this.prisma.message.count({ where: { createdAt: { gte: since24h } } }),
    ]);

    return {
      users: {
        total: usersTotal,
        suspended: usersSuspended,
      },
      moderation: {
        pendingReports,
      },
      swaps: {
        activeMatches,
        availableItems: itemsAvailable,
      },
      notifications: {
        unread: notificationsUnread,
        sentLast24h: notifications24h,
      },
      chat: {
        unreadMessages: messagesUnread,
        sentLast24h: messages24h,
      },
    };
  }

  async listUsers(query: AdminUsersQueryDto) {
    const { page, limit, skip } = this.normalizePagination(query.page, query.limit);
    const search = query.search?.trim();

    const where = search
      ? {
          OR: [
            { displayName: { contains: search, mode: 'insensitive' as const } },
            { email: { contains: search, mode: 'insensitive' as const } },
          ],
        }
      : {};

    const [data, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          displayName: true,
          email: true,
          role: true,
          suspendedUntil: true,
          createdAt: true,
          emailVerified: true,
          phoneVerified: true,
          _count: {
            select: {
              items: true,
              reportsAgainst: true,
              matchesAsA: true,
              matchesAsB: true,
            },
          },
        },
      }),
      this.prisma.user.count({ where }),
    ]);

    return { data, meta: { page, limit, total } };
  }

  async suspendUser(userId: string, dto: SuspendUserDto) {
    const existing = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!existing) {
      throw new NotFoundException('User not found');
    }

    let suspendedUntil: Date | null = null;
    if (!dto.clear) {
      if (dto.suspendedUntil) {
        suspendedUntil = new Date(dto.suspendedUntil);
        if (Number.isNaN(suspendedUntil.getTime())) {
          throw new BadRequestException('Invalid suspendedUntil value');
        }
      } else {
        const days = dto.days ?? 7;
        suspendedUntil = new Date(Date.now() + days * 24 * 60 * 60 * 1000);
      }
    }

    return this.prisma.user.update({
      where: { id: userId },
      data: { suspendedUntil },
      select: {
        id: true,
        displayName: true,
        email: true,
        suspendedUntil: true,
      },
    });
  }

  async updateUserRole(userId: string, dto: UpdateUserRoleDto) {
    const existing = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!existing) {
      throw new NotFoundException('User not found');
    }

    return this.prisma.user.update({
      where: { id: userId },
      data: { role: dto.role },
      select: {
        id: true,
        displayName: true,
        email: true,
        role: true,
      },
    });
  }

  async listReports(query: AdminReportsQueryDto) {
    const { page, limit, skip } = this.normalizePagination(query.page, query.limit);

    const where = query.status ? { status: query.status } : {};

    const [data, total] = await Promise.all([
      this.prisma.report.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          reporter: { select: { id: true, displayName: true, email: true } },
          reportedUser: { select: { id: true, displayName: true, email: true } },
          reportedItem: { select: { id: true, brand: true, category: true } },
        },
      }),
      this.prisma.report.count({ where }),
    ]);

    return { data, meta: { page, limit, total } };
  }

  async resolveReport(reportId: string, dto: ResolveReportDto) {
    const existing = await this.prisma.report.findUnique({ where: { id: reportId } });
    if (!existing) {
      throw new NotFoundException('Report not found');
    }

    return this.prisma.report.update({
      where: { id: reportId },
      data: {
        status: dto.status,
        resolvedAt: dto.status === 'pending' ? null : new Date(),
      },
    });
  }

  async listItems(query: AdminItemsQueryDto) {
    const { page, limit, skip } = this.normalizePagination(query.page, query.limit);
    const where: any = {};
    if (query.status) where.status = query.status;
    if (query.category) where.category = query.category;

    const [data, total] = await Promise.all([
      this.prisma.item.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          owner: {
            select: {
              id: true,
              displayName: true,
              email: true,
            },
          },
          photos: { take: 1, orderBy: { sortOrder: 'asc' } },
        },
      }),
      this.prisma.item.count({ where }),
    ]);

    return { data, meta: { page, limit, total } };
  }

  async moderateItemStatus(itemId: string, dto: ModerateItemDto) {
    const existing = await this.prisma.item.findUnique({ where: { id: itemId } });
    if (!existing) {
      throw new NotFoundException('Item not found');
    }

    return this.prisma.item.update({
      where: { id: itemId },
      data: { status: dto.status },
      select: {
        id: true,
        status: true,
        ownerId: true,
      },
    });
  }

  async listMatches(query: AdminMatchesQueryDto) {
    const { page, limit, skip } = this.normalizePagination(query.page, query.limit);
    const where = query.status ? { status: query.status } : {};

    const [data, total] = await Promise.all([
      this.prisma.match.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          userA: { select: { id: true, displayName: true } },
          userB: { select: { id: true, displayName: true } },
          itemA: { select: { id: true, brand: true } },
          itemB: { select: { id: true, brand: true } },
        },
      }),
      this.prisma.match.count({ where }),
    ]);

    return { data, meta: { page, limit, total } };
  }

  async notificationsHealth() {
    const since24h = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const [total, unread, sentLast24h] = await Promise.all([
      this.prisma.notification.count(),
      this.prisma.notification.count({ where: { readAt: null } }),
      this.prisma.notification.count({ where: { createdAt: { gte: since24h } } }),
    ]);

    return { total, unread, sentLast24h };
  }

  async chatHealth() {
    const since24h = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const [totalMessages, unreadMessages, messagesLast24h, activeMatchChatsLast24h] =
      await Promise.all([
        this.prisma.message.count(),
        this.prisma.message.count({ where: { readAt: null } }),
        this.prisma.message.count({ where: { createdAt: { gte: since24h } } }),
        this.prisma.match.count({
          where: {
            messages: {
              some: {
                createdAt: { gte: since24h },
              },
            },
          },
        }),
      ]);

    return {
      totalMessages,
      unreadMessages,
      messagesLast24h,
      activeMatchChatsLast24h,
    };
  }
}
