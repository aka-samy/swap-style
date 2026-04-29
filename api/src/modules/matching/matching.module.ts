import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { MatchingController } from './matching.controller';
import { MatchingService } from './matching.service';
import { MatchExpiryProcessor } from './jobs/match-expiry.processor';
import { NotificationsModule } from '../notifications/notifications.module';
import { GamificationModule } from '../gamification/gamification.module';
import { ChatModule } from '../chat/chat.module';

const enableBullWorkers = process.env.ENABLE_BULLMQ_WORKERS !== 'false';

@Module({
  imports: [
    ...(enableBullWorkers
      ? [BullModule.registerQueue({ name: 'match-expiry' })]
      : []),
    NotificationsModule,
    GamificationModule,
    ChatModule,
  ],
  controllers: [MatchingController],
  providers: [
    MatchingService,
    ...(enableBullWorkers ? [MatchExpiryProcessor] : []),
  ],
  exports: [MatchingService],
})
export class MatchingModule {}
