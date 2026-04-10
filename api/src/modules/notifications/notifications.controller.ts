import {
  Controller,
  Get,
  Patch,
  Param,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';

@ApiTags('Notifications')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get()
  @ApiOperation({ summary: 'List user notifications' })
  async findAll(
    @Req() req: any,
    @Query('page') page = 1,
    @Query('limit') limit = 20,
  ) {
    return this.notificationsService.findAll(req.user.userId, {
      page: +page,
      limit: +limit,
    });
  }

  @Patch(':id/read')
  @ApiOperation({ summary: 'Mark notification as read' })
  async markRead(@Param('id') id: string, @Req() req: any) {
    return this.notificationsService.markRead(id, req.user.userId);
  }

  @Patch('read-all')
  @ApiOperation({ summary: 'Mark all notifications as read' })
  async markAllRead(@Req() req: any) {
    return this.notificationsService.markAllRead(req.user.userId);
  }
}
