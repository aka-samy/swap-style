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

@WebSocketGateway({ cors: { origin: '*' }, namespace: '/chat' })
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer() server: Server;

  constructor(private readonly chatService: ChatService) {}

  afterInit(server: Server) {
    this.chatService.setServer(server);
  }

  handleConnection(client: Socket) {
    // userId injected by auth middleware on socket.data
    const userId = client.data?.userId;
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
    await client.join(`match:${data.matchId}`);
    client.emit('joined', { matchId: data.matchId });
  }

  @SubscribeMessage('send_message')
  async handleSendMessage(
    @MessageBody() data: { matchId: string; text: string },
    @ConnectedSocket() client: Socket,
  ) {
    const senderId: string = client.data.userId;
    const message = await this.chatService.createMessage(
      data.matchId,
      senderId,
      data.text,
    );
    this.server.to(`match:${data.matchId}`).emit('new_message', message);
  }

  @SubscribeMessage('typing')
  handleTyping(
    @MessageBody() data: { matchId: string; isTyping: boolean },
    @ConnectedSocket() client: Socket,
  ) {
    client.to(`match:${data.matchId}`).emit('typing', {
      userId: client.data.userId,
      isTyping: data.isTyping,
    });
  }
}
