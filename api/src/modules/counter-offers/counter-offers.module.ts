import { Module } from '@nestjs/common';
import { CounterOffersController } from './counter-offers.controller';
import { CounterOffersService } from './counter-offers.service';

@Module({
  controllers: [CounterOffersController],
  providers: [CounterOffersService],
  exports: [CounterOffersService],
})
export class CounterOffersModule {}
