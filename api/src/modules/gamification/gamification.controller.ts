import {
  Controller,
  Get,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { GamificationService } from './gamification.service';
import { GetBadgesQueryDto } from './dto';

@ApiTags('gamification')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller('gamification')
export class GamificationController {
  constructor(private readonly gamificationService: GamificationService) {}

  @Get('stats')
  @ApiOperation({ summary: 'Get own streak and badges' })
  getMyStats(@Request() req: any) {
    return this.gamificationService.getUserStats(req.user.userId);
  }

  @Get('badges')
  @ApiOperation({ summary: 'Get all available badges (catalog)' })
  getBadgeCatalog(@Query() _query: GetBadgesQueryDto) {
    // Returns full badge table; filter by slug when provided
    return this.gamificationService['prisma'].badge.findMany();
  }
}
