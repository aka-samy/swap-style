import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import { GamificationService } from '../gamification.service';

export const STREAK_RESET_QUEUE = 'streak-reset';
export const STREAK_RESET_JOB = 'reset-expired-streaks';

@Processor(STREAK_RESET_QUEUE)
export class StreakResetProcessor extends WorkerHost {
  private readonly logger = new Logger(StreakResetProcessor.name);

  constructor(private readonly gamificationService: GamificationService) {
    super();
  }

  async process(job: Job): Promise<void> {
    this.logger.log(`Processing job ${job.name} (id: ${job.id})`);

    if (job.name === STREAK_RESET_JOB) {
      await this.gamificationService.resetExpiredStreaks();
    }
  }
}
