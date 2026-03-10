import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { MatchingController } from './matching.controller';
import { MatchingService } from './matching.service';
import { MatchExpiryProcessor } from './jobs/match-expiry.processor';
import { NotificationsModule } from '../notifications/notifications.module';
import { GamificationModule } from '../gamification/gamification.module';

@Module({
  imports: [
    BullModule.registerQueue({ name: 'match-expiry' }),
    NotificationsModule,
    GamificationModule,
  ],
  controllers: [MatchingController],
  providers: [MatchingService, MatchExpiryProcessor],
  exports: [MatchingService],
})
export class MatchingModule {}
