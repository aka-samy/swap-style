import {
  Body,
  Controller,
  Get,
  Post,
  Param,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { MatchingService } from './matching.service';
import { MatchQueryDto, OpenChatMatchDto } from './dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';

@ApiTags('Matches')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller('matches')
export class MatchingController {
  constructor(private readonly matchingService: MatchingService) {}

  @Get()
  @ApiOperation({ summary: 'List user matches' })
  async findAll(@Req() req: any, @Query() query: MatchQueryDto) {
    return this.matchingService.findAll(req.user.userId, {
      page: query.page ?? 1,
      limit: query.limit ?? 20,
      status: query.status,
    });
  }

  @Post('open-chat')
  @ApiOperation({ summary: 'Create or open a chat for a specific item' })
  async openChat(@Req() req: any, @Body() dto: OpenChatMatchDto) {
    return this.matchingService.openChatForItem(
      req.user.userId,
      dto.itemId,
      dto.initialMessage,
    );
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get match details' })
  @ApiResponse({ status: 404, description: 'Match not found' })
  @ApiResponse({ status: 403, description: 'Not a participant' })
  async findOne(@Param('id') id: string, @Req() req: any) {
    return this.matchingService.findOne(id, req.user.userId);
  }

  @Post(':id/confirm')
  @ApiOperation({ summary: 'Confirm swap completion' })
  async confirm(@Param('id') id: string, @Req() req: any) {
    return this.matchingService.confirmMatch(id, req.user.userId);
  }

  @Post(':id/cancel')
  @ApiOperation({ summary: 'Cancel a match' })
  async cancel(@Param('id') id: string, @Req() req: any) {
    return this.matchingService.cancelMatch(id, req.user.userId);
  }
}
