import {
  Controller,
  Get,
  Post,
  Patch,
  Param,
  Body,
  Query,
  Req,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { ChatService } from './chat.service';
import { SendMessageDto, MessageCursorQueryDto } from './dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';

@ApiTags('Chat')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller('matches/:matchId/messages')
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Get()
  @ApiOperation({ summary: 'List messages with cursor pagination' })
  async list(
    @Param('matchId') matchId: string,
    @Req() req: any,
    @Query() query: MessageCursorQueryDto,
  ) {
    return this.chatService.listMessages(matchId, req.user.userId, {
      limit: query.limit ?? 20,
      cursor: query.cursor,
    });
  }

  @Post()
  @ApiOperation({ summary: 'Send a message' })
  async send(
    @Param('matchId') matchId: string,
    @Req() req: any,
    @Body() dto: SendMessageDto,
  ) {
    return this.chatService.createMessage(matchId, req.user.userId, dto.text);
  }

  @Patch('read')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Mark messages in match as read' })
  async markRead(@Param('matchId') matchId: string, @Req() req: any) {
    await this.chatService.markRead(matchId, req.user.userId);
  }
}
