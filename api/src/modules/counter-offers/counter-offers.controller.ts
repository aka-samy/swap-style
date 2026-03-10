import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { CounterOffersService } from './counter-offers.service';
import { ProposeCounterOfferDto } from './dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';

@ApiTags('Counter Offers')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller('matches/:matchId/counter-offers')
export class CounterOffersController {
  constructor(private readonly counterOffersService: CounterOffersService) {}

  @Get()
  @ApiOperation({ summary: 'List counter-offers for a match' })
  async list(@Param('matchId') matchId: string, @Req() req: any) {
    return this.counterOffersService.getByMatch(matchId, req.user.userId);
  }

  @Post()
  @ApiOperation({ summary: 'Propose a counter-offer' })
  async propose(
    @Param('matchId') matchId: string,
    @Req() req: any,
    @Body() dto: ProposeCounterOfferDto,
  ) {
    return this.counterOffersService.propose(matchId, req.user.userId, dto);
  }

  @Post(':id/accept')
  @ApiOperation({ summary: 'Accept a counter-offer' })
  async accept(@Param('id') id: string, @Req() req: any) {
    return this.counterOffersService.accept(id, req.user.userId);
  }

  @Post(':id/decline')
  @ApiOperation({ summary: 'Decline a counter-offer' })
  async decline(@Param('id') id: string, @Req() req: any) {
    return this.counterOffersService.decline(id, req.user.userId);
  }
}
