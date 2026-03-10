import {
  Controller,
  Post,
  Delete,
  Get,
  Param,
  Body,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
} from '@nestjs/swagger';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { ModerationService } from './moderation.service';
import { ReportUserDto, ReportItemDto } from './dto';

@ApiTags('moderation')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller()
export class ModerationController {
  constructor(private readonly moderationService: ModerationService) {}

  @Post('users/:userId/report')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Report a user' })
  reportUser(
    @Request() req: any,
    @Param('userId') targetUserId: string,
    @Body() dto: ReportUserDto,
  ) {
    return this.moderationService.reportUser(req.user.userId, {
      ...dto,
      targetUserId,
    });
  }

  @Post('items/:itemId/report')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Report an item' })
  reportItem(
    @Request() req: any,
    @Param('itemId') targetItemId: string,
    @Body() dto: ReportItemDto,
  ) {
    return this.moderationService.reportItem(req.user.userId, {
      ...dto,
      targetItemId,
    });
  }

  @Post('users/:userId/block')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Block a user' })
  blockUser(@Request() req: any, @Param('userId') blockedId: string) {
    return this.moderationService.blockUser(req.user.userId, blockedId);
  }

  @Delete('users/:userId/block')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Unblock a user' })
  unblockUser(@Request() req: any, @Param('userId') blockedId: string) {
    return this.moderationService.unblockUser(req.user.userId, blockedId);
  }

  @Get('users/blocks')
  @ApiOperation({ summary: 'List blocked users' })
  getBlocks(@Request() req: any) {
    return this.moderationService.getBlocks(req.user.userId);
  }
}
