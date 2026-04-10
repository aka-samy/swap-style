import { Module, Global } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { ConfigService } from '@nestjs/config';

function parseRedisUrl(redisUrl: string) {
  const parsed = new URL(redisUrl);
  const isTls = parsed.protocol === 'rediss:';
  return {
    host: parsed.hostname,
    port: Number(parsed.port || 6379),
    username: parsed.username || undefined,
    password: parsed.password || undefined,
    tls: isTls ? {} : undefined,
  };
}

@Global()
@Module({
  imports: [
    BullModule.forRootAsync({
      useFactory: (configService: ConfigService) => {
        const isProduction = configService.get<string>('NODE_ENV') === 'production';
        const redisUrl =
          configService.get<string>('REDIS_URL') ||
          configService.get<string>('REDISURL') ||
          configService.get<string>('REDIS_PRIVATE_URL') ||
          configService.get<string>('REDIS_PUBLIC_URL');

        const connection = redisUrl
          ? parseRedisUrl(redisUrl)
          : {
              host: configService.get<string>('REDIS_HOST') || undefined,
              port:
                configService.get<number>('REDIS_PORT') ||
                Number(configService.get<string>('REDISPORT')) ||
                6379,
              username:
                configService.get<string>('REDIS_USERNAME') ||
                configService.get<string>('REDISUSER') ||
                configService.get<string>('REDIS_USER') ||
                undefined,
              password:
                configService.get<string>('REDIS_PASSWORD') ||
                configService.get<string>('REDISPASSWORD') ||
                undefined,
            };

        if (!redisUrl && !connection.host) {
          connection.host =
            configService.get<string>('REDISHOST') ||
            (isProduction ? undefined : 'localhost');
        }

        if (!redisUrl && connection.host === 'localhost') {
          connection.host =
            configService.get<string>('REDISHOST') ||
            configService.get<string>('REDIS_HOST', 'localhost');
        }

        if (
          isProduction &&
          !redisUrl &&
          (!connection.host || connection.host === 'localhost')
        ) {
          throw new Error(
            'BullMQ Redis is not configured for production. Set REDIS_URL (or REDIS_PRIVATE_URL) in Railway variables.',
          );
        }

        return {
          connection,
          skipVersionCheck: true,
        };
      },
      inject: [ConfigService],
    }),
  ],
})
export class QueueModule {}
