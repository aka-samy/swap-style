import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { ChatService } from './chat.service';
import * as admin from 'firebase-admin';
import { PrismaService } from '../../common/prisma/prisma.service';

@WebSocketGateway({ cors: { origin: '*' }, namespace: '/chat' })
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer() server: Server;

  constructor(
    private readonly chatService: ChatService,
    private readonly prisma: PrismaService,
  ) {}

  afterInit(server: Server) {
    this.chatService.setServer(server);
  }

  private extractToken(client: Socket): string | null {
    const authToken = client.handshake.auth?.token;
    if (typeof authToken === 'string' && authToken.trim().length > 0) {
      return authToken.startsWith('Bearer ')
        ? authToken.substring(7).trim()
        : authToken.trim();
    }

    const headerAuth = client.handshake.headers.authorization;
    if (typeof headerAuth === 'string' && headerAuth.startsWith('Bearer ')) {
      return headerAuth.substring(7).trim();
    }

    return null;
  }

  private async resolveUserId(client: Socket): Promise<string | null> {
    const existing = client.data?.userId;
    if (typeof existing === 'string' && existing.length > 0) {
      return existing;
    }

    const token = this.extractToken(client);
    if (!token) {
      return null;
    }

    try {
      const decoded = await admin.auth().verifyIdToken(token);
      const user = await this.prisma.user.findUnique({
        where: { firebaseUid: decoded.uid },
        select: { id: true },
      });

      if (!user) {
        return null;
      }

      client.data.userId = user.id;
      return user.id;
    } catch {
      return null;
    }
  }

  async handleConnection(client: Socket) {
    const userId = await this.resolveUserId(client);
    if (!userId) {
      client.disconnect();
    }
  }

  handleDisconnect(client: Socket) {
    // cleanup if needed
  }

  @SubscribeMessage('join_match')
  async handleJoinMatch(
    @MessageBody() data: { matchId: string },
    @ConnectedSocket() client: Socket,
  ) {
    const userId = await this.resolveUserId(client);
    if (!userId) {
      client.disconnect();
      return;
    }

    await this.chatService.ensureParticipant(data.matchId, userId);
    await client.join(`match:${data.matchId}`);
    client.emit('joined', { matchId: data.matchId });
  }

  @SubscribeMessage('send_message')
  async handleSendMessage(
    @MessageBody() data: { matchId: string; text: string },
    @ConnectedSocket() client: Socket,
  ) {
    const senderId = await this.resolveUserId(client);
    if (!senderId) {
      client.disconnect();
      return;
    }

    await this.chatService.createMessage(
      data.matchId,
      senderId,
      data.text,
    );
  }

  @SubscribeMessage('typing')
  handleTyping(
    @MessageBody() data: { matchId: string; isTyping: boolean },
    @ConnectedSocket() client: Socket,
  ) {
    const senderId: string | undefined = client.data?.userId;
    if (!senderId) {
      client.disconnect();
      return;
    }

    client.to(`match:${data.matchId}`).emit('typing', {
      userId: senderId,
      isTyping: data.isTyping,
    });
  }
}
