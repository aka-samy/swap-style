import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Roles } from '../../common/decorators/roles.decorator';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { AdminService } from './admin.service';
import {
  AdminItemsQueryDto,
  AdminMatchesQueryDto,
  AdminReportsQueryDto,
  AdminUsersQueryDto,
  ModerateItemDto,
  ResolveReportDto,
  SuspendUserDto,
  UpdateUserRoleDto,
} from './dto/admin.dto';

@ApiTags('Admin')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard, RolesGuard)
@Roles('ADMIN')
@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Admin analytics dashboard summary' })
  getDashboard() {
    return this.adminService.getDashboard();
  }

  @Get('users')
  @ApiOperation({ summary: 'List users for moderation' })
  listUsers(@Query() query: AdminUsersQueryDto) {
    return this.adminService.listUsers(query);
  }

  @Patch('users/:id/suspend')
  @ApiOperation({ summary: 'Suspend or unsuspend a user account' })
  suspendUser(@Param('id') id: string, @Body() dto: SuspendUserDto) {
    return this.adminService.suspendUser(id, dto);
  }

  @Patch('users/:id/role')
  @ApiOperation({ summary: 'Update user role' })
  updateUserRole(@Param('id') id: string, @Body() dto: UpdateUserRoleDto) {
    return this.adminService.updateUserRole(id, dto);
  }

  @Get('reports')
  @ApiOperation({ summary: 'List reports queue' })
  listReports(@Query() query: AdminReportsQueryDto) {
    return this.adminService.listReports(query);
  }

  @Patch('reports/:id')
  @ApiOperation({ summary: 'Resolve or review a report' })
  resolveReport(@Param('id') id: string, @Body() dto: ResolveReportDto) {
    return this.adminService.resolveReport(id, dto);
  }

  @Get('items')
  @ApiOperation({ summary: 'List items for moderation' })
  listItems(@Query() query: AdminItemsQueryDto) {
    return this.adminService.listItems(query);
  }

  @Patch('items/:id/status')
  @ApiOperation({ summary: 'Moderate item status' })
  moderateItemStatus(@Param('id') id: string, @Body() dto: ModerateItemDto) {
    return this.adminService.moderateItemStatus(id, dto);
  }

  @Get('matches')
  @ApiOperation({ summary: 'List swaps/matches for monitoring' })
  listMatches(@Query() query: AdminMatchesQueryDto) {
    return this.adminService.listMatches(query);
  }

  @Get('notifications/health')
  @ApiOperation({ summary: 'Notification delivery health overview' })
  notificationsHealth() {
    return this.adminService.notificationsHealth();
  }

  @Get('chat/health')
  @ApiOperation({ summary: 'Chat activity and unread metrics overview' })
  chatHealth() {
    return this.adminService.chatHealth();
  }
}
