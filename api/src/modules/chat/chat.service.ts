import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { NotificationType } from '@prisma/client';
import { Server } from 'socket.io';

@Injectable()
export class ChatService {
  private server?: Server;

  constructor(
    private readonly prisma: PrismaService,
    private readonly notifications: NotificationsService,
  ) {}

  setServer(server: Server) {
    this.server = server;
  }

  private async validateParticipant(matchId: string, userId: string) {
    const match = await this.prisma.match.findUnique({ where: { id: matchId } });
    if (!match) throw new NotFoundException('Match not found');
    if (match.userAId !== userId && match.userBId !== userId) {
      throw new ForbiddenException('Not a match participant');
    }
    return match;
  }

  async createMessage(matchId: string, senderId: string, text: string) {
    const match = await this.validateParticipant(matchId, senderId);

    const message = await this.prisma.message.create({
      data: { matchId, senderId, text },
      include: { sender: { select: { id: true, displayName: true, profilePhotoUrl: true } } },
    });

    // Push notification to the other party
    const recipientId = match.userAId === senderId ? match.userBId : match.userAId;
    await this.notifications.sendToUser(recipientId, {
      type: NotificationType.message,
      title: 'New message',
      body: text.slice(0, 80),
      data: { matchId },
    }).catch(() => {/* non-critical */});

    return message;
  }

  async listMessages(
    matchId: string,
    userId: string,
    query: { limit: number; cursor?: string },
  ) {
    await this.validateParticipant(matchId, userId);
    const { limit = 20, cursor } = query;

    return this.prisma.message.findMany({
      where: { matchId },
      take: limit,
      ...(cursor ? { skip: 1, cursor: { id: cursor } } : {}),
      orderBy: { createdAt: 'desc' },
      include: { sender: { select: { id: true, displayName: true, profilePhotoUrl: true } } },
    });
  }

  async markRead(matchId: string, userId: string) {
    await this.validateParticipant(matchId, userId);

    await this.prisma.message.updateMany({
      where: {
        matchId,
        senderId: { not: userId },
        readAt: null,
      },
      data: { readAt: new Date() },
    });
  }
}
