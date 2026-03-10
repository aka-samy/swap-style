import {
  Controller,
  Get,
  Post,
  Body,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { DiscoveryService } from './discovery.service';
import { FeedQueryDto, SwipeDto } from './dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';

@ApiTags('Discovery')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller('discovery')
export class DiscoveryController {
  constructor(private readonly discoveryService: DiscoveryService) {}

  @Get('feed')
  @ApiOperation({ summary: 'Get swipe feed of nearby items' })
  @ApiResponse({ status: 200, description: 'Paginated feed of items' })
  async getFeed(@Req() req: any, @Query() query: FeedQueryDto) {
    return this.discoveryService.getFeed(req.user.userId, query);
  }

  @Post('swipe')
  @ApiOperation({ summary: 'Record a like or pass on an item' })
  @ApiResponse({ status: 200, description: 'Swipe result, possibly with match' })
  @ApiResponse({ status: 400, description: 'Already swiped' })
  @ApiResponse({ status: 404, description: 'Item not found' })
  async swipe(@Req() req: any, @Body() dto: SwipeDto) {
    return this.discoveryService.recordSwipe(req.user.userId, dto);
  }
}
