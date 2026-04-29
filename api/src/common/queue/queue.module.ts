import { Module, Global } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { ConfigService } from '@nestjs/config';

function parseRedisUrl(redisUrl: string) {
  const parsed = new URL(redisUrl);
  const isTls = parsed.protocol === 'rediss:';
  const queryUsername =
    parsed.searchParams.get('username') || parsed.searchParams.get('user');
  const queryPassword =
    parsed.searchParams.get('password') ||
    parsed.searchParams.get('pass') ||
    parsed.searchParams.get('pwd');

  const parsedUsername = parsed.username
    ? decodeURIComponent(parsed.username)
    : queryUsername || undefined;
  const parsedPassword = parsed.password
    ? decodeURIComponent(parsed.password)
    : queryPassword || undefined;

  return {
    host: parsed.hostname,
    port: Number(parsed.port || 6379),
    username: parsedUsername,
    password: parsedPassword,
    tls: isTls ? {} : undefined,
  };
}

@Global()
@Module({
  imports: [
    BullModule.forRootAsync({
      useFactory: (configService: ConfigService) => {
        const isProduction = configService.get<string>('NODE_ENV') === 'production';
        const redisUsername =
          configService.get<string>('REDIS_USERNAME') ||
          configService.get<string>('REDISUSER') ||
          configService.get<string>('REDIS_USER') ||
          undefined;
        const redisPassword =
          configService.get<string>('REDIS_PASSWORD') ||
          configService.get<string>('REDISPASSWORD') ||
          undefined;
        const redisUrl =
          configService.get<string>('REDIS_URL') ||
          configService.get<string>('REDISURL') ||
          configService.get<string>('REDIS_PRIVATE_URL') ||
          configService.get<string>('REDIS_PUBLIC_URL');

        const parsedUrlConnection = redisUrl ? parseRedisUrl(redisUrl) : undefined;

        const connection = redisUrl
          ? {
              ...parsedUrlConnection,
              username: parsedUrlConnection?.username || redisUsername,
              password: parsedUrlConnection?.password || redisPassword,
            }
          : {
              host: configService.get<string>('REDIS_HOST') || undefined,
              port:
                configService.get<number>('REDIS_PORT') ||
                Number(configService.get<string>('REDISPORT')) ||
                6379,
              username: redisUsername,
              password: redisPassword,
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

        if (
          isProduction &&
          connection.host &&
          connection.host !== 'localhost' &&
          !connection.password
        ) {
          throw new Error(
            'BullMQ Redis password is missing in production. Use REDIS_URL with credentials or set REDIS_PASSWORD.',
          );
        }

        return {
          connection,
        };
      },
      inject: [ConfigService],
    }),
  ],
})
export class QueueModule {}
