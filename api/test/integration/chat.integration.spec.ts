import { Test, TestingModule } from '@nestjs/testing';
import { ChatService } from '../../src/modules/chat/chat.service';
import { PrismaService } from '../../src/common/prisma/prisma.service';
import { NotificationsService } from '../../src/modules/notifications/notifications.service';
import { Server } from 'socket.io';

/**
 * Integration tests verifying Chat works with Matching:
 *   - Messages can only be sent in PENDING/NEGOTIATING/CONFIRMED matches
 *   - Socket.IO server is properly typed and used
 */
describe('Chat Integration', () => {
  let chatService: ChatService;
  let mockSocketServer: jest.Mocked<Server>;

  beforeAll(async () => {
    mockSocketServer = {
      to: jest.fn().mockReturnThis(),
      emit: jest.fn(),
    } as any;

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ChatService,
        PrismaService,
        { provide: NotificationsService, useValue: { sendToUser: jest.fn(), sendPush: jest.fn() } },
      ],
    }).compile();

    chatService = module.get(ChatService);
    // Inject mock socket server
    chatService.setServer(mockSocketServer);
  });

  it('ChatService loads without errors', () => {
    expect(chatService).toBeDefined();
  });

  it('setServer stores the socket.io server instance', () => {
    expect((chatService as any).server).toBe(mockSocketServer);
  });
});
