import { Module, Global } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';

export const REDIS_CLIENT = 'REDIS_CLIENT';

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
  providers: [
    {
      provide: REDIS_CLIENT,
      useFactory: (configService: ConfigService) => {
        const redisUrl =
          configService.get<string>('REDIS_URL') ||
          configService.get<string>('REDIS_PRIVATE_URL') ||
          configService.get<string>('REDIS_PUBLIC_URL');

        const options = redisUrl
          ? parseRedisUrl(redisUrl)
          : {
              host: configService.get<string>('REDIS_HOST', 'localhost'),
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

        if (!redisUrl && options.host === 'localhost') {
          options.host =
            configService.get<string>('REDISHOST') ||
            configService.get<string>('REDIS_HOST', 'localhost');
        }

        return new Redis({
          ...options,
          maxRetriesPerRequest: 3,
        });
      },
      inject: [ConfigService],
    },
  ],
  exports: [REDIS_CLIENT],
})
export class RedisModule {}
