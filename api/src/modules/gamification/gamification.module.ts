import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { GamificationService } from './gamification.service';
import { GamificationController } from './gamification.controller';
import { StreakResetProcessor, STREAK_RESET_QUEUE } from './jobs/streak-reset.processor';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    BullModule.registerQueue({ name: STREAK_RESET_QUEUE }),
    NotificationsModule,
  ],
  controllers: [GamificationController],
  providers: [GamificationService, StreakResetProcessor],
  exports: [GamificationService],
})
export class GamificationModule {}
