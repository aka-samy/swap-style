import {
  Injectable,
  Logger,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { NotificationType } from '@prisma/client';
import * as admin from 'firebase-admin';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(private readonly prisma: PrismaService) {}

  async sendPush(
    userId: string,
    payload: {
      type: string;
      title: string;
      body: string;
      data?: Record<string, string>;
    },
  ) {
    // Persist notification in DB
    const notification = await this.prisma.notification.create({
      data: {
        userId,
        type: payload.type as NotificationType,
        title: payload.title,
        body: payload.body,
        matchId: payload.data?.matchId ?? null,
      },
    });

    // Send FCM push if user has token
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { fcmToken: true },
    });

    if (user?.fcmToken) {
      try {
        await admin.messaging().send({
          token: user.fcmToken,
          notification: {
            title: payload.title,
            body: payload.body,
          },
          data: payload.data,
        });
      } catch (error) {
        this.logger.warn(`FCM send failed for user ${userId}: ${error}`);
      }
    }

    return notification;
  }

  /** Alias kept for convenience — delegates to sendPush. */
  async sendToUser(
    userId: string,
    payload: {
      type: string;
      title: string;
      body: string;
      data?: Record<string, string>;
    },
  ) {
    return this.sendPush(userId, payload);
  }

  async findAll(userId: string, query: { page: number; limit: number }) {
    const { page = 1, limit = 20 } = query;

    const [data, total] = await Promise.all([
      this.prisma.notification.findMany({
        where: { userId },
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.notification.count({ where: { userId } }),
    ]);

    return { data, meta: { page, limit, total } };
  }

  async markRead(notificationId: string, userId: string) {
    const notification = await this.prisma.notification.findUnique({
      where: { id: notificationId },
      select: { id: true, userId: true },
    });

    if (!notification) {
      throw new NotFoundException('Notification not found');
    }
    if (notification.userId !== userId) {
      throw new ForbiddenException(
        'You cannot mark another user notifications as read',
      );
    }

    return this.prisma.notification.update({
      where: { id: notificationId },
      data: { readAt: new Date() },
    });
  }

  async markAllRead(userId: string) {
    const updated = await this.prisma.notification.updateMany({
      where: { userId, readAt: null },
      data: { readAt: new Date() },
    });

    return { updated: updated.count };
  }
}
