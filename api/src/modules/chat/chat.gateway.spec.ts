/* eslint-env jest */
import { Test, TestingModule } from '@nestjs/testing';
import { ChatGateway } from './chat.gateway';
import { ChatService } from './chat.service';
import { Socket, Server } from 'socket.io';

const mockChatService = {
  createMessage: jest.fn(),
  markRead: jest.fn(),
};

const mockSocket = {
  id: 'socket-1',
  data: { userId: 'user-a' },
  join: jest.fn(),
  to: jest.fn().mockReturnThis(),
  emit: jest.fn(),
  handshake: { auth: { token: 'test-token' } },
} as unknown as Socket;

const mockServer = {
  to: jest.fn().mockReturnThis(),
  emit: jest.fn(),
} as unknown as Server;

describe('ChatGateway', () => {
  let gateway: ChatGateway;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ChatGateway,
        { provide: ChatService, useValue: mockChatService },
      ],
    }).compile();
    gateway = module.get<ChatGateway>(ChatGateway);
    (gateway as any).server = mockServer;
    jest.clearAllMocks();
  });

  describe('handleJoinMatch', () => {
    it('joins client to match room', async () => {
      await gateway.handleJoinMatch({ matchId: 'match-1' }, mockSocket);
      expect(mockSocket.join).toHaveBeenCalledWith('match:match-1');
    });
  });

  describe('handleSendMessage', () => {
    it('persists message and broadcasts to match room', async () => {
      const msg = { id: 'msg-1', text: 'Hi!', senderId: 'user-a' };
      mockChatService.createMessage.mockResolvedValue(msg);

      await gateway.handleSendMessage(
        { matchId: 'match-1', text: 'Hi!' },
        mockSocket,
      );

      expect(mockChatService.createMessage).toHaveBeenCalledWith(
        'match-1',
        'user-a',
        'Hi!',
      );
      expect(mockServer.to).toHaveBeenCalledWith('match:match-1');
    });
  });
});
