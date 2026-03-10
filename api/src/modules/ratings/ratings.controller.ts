import {
  Controller,
  Get,
  Post,
  Param,
  Body,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { RatingsService } from './ratings.service';
import { CreateRatingDto } from './dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';

@ApiTags('Ratings')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller()
export class RatingsController {
  constructor(private readonly ratingsService: RatingsService) {}

  @Post('matches/:matchId/rating')
  @ApiOperation({ summary: 'Submit a rating for a completed swap' })
  async createRating(
    @Param('matchId') matchId: string,
    @Req() req: any,
    @Body() dto: CreateRatingDto,
  ) {
    return this.ratingsService.createRating(matchId, req.user.userId, dto);
  }

  @Get('users/:userId/ratings')
  @ApiOperation({ summary: "List a user's received ratings" })
  async getUserRatings(@Param('userId') userId: string) {
    return this.ratingsService.getUserRatings(userId);
  }
}
