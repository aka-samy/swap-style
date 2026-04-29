/* eslint-env node */
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './common/prisma/prisma.module';
import { RedisModule } from './common/redis/redis.module';
import { QueueModule } from './common/queue/queue.module';
import { StorageModule } from './common/storage/storage.module';
import { AuthModule } from './modules/auth/auth.module';
import { ItemsModule } from './modules/items/items.module';
import { DiscoveryModule } from './modules/discovery/discovery.module';
import { MatchingModule } from './modules/matching/matching.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { UsersModule } from './modules/users/users.module';
import { CounterOffersModule } from './modules/counter-offers/counter-offers.module';
import { ChatModule } from './modules/chat/chat.module';
import { RatingsModule } from './modules/ratings/ratings.module';
import { GamificationModule } from './modules/gamification/gamification.module';
import { ModerationModule } from './modules/moderation/moderation.module';
import { AdminModule } from './modules/admin/admin.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: process.env.NODE_ENV === 'production' ? undefined : '.env',
    }),
    PrismaModule,
    RedisModule,
    QueueModule,
    StorageModule,
    AuthModule,
    ItemsModule,
    DiscoveryModule,
    MatchingModule,
    NotificationsModule,
    UsersModule,
    CounterOffersModule,
    ChatModule,
    RatingsModule,
    GamificationModule,
    ModerationModule,
    AdminModule,
  ],
})
export class AppModule {}
