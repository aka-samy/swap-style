import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import helmet from 'helmet';
import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

function initFirebase() {
  if (admin.apps.length > 0) return;

  // Option 1: JSON file on disk (local dev)
  const keyPath = path.resolve(process.env.FIREBASE_SERVICE_ACCOUNT_KEY ?? './firebase-service-account.json');
  if (fs.existsSync(keyPath)) {
    const serviceAccount = JSON.parse(fs.readFileSync(keyPath, 'utf8'));
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: process.env.FIREBASE_PROJECT_ID,
    });
    return;
  }

  // Option 2: Base64-encoded service account in env var (Railway/cloud)
  if (process.env.FIREBASE_SERVICE_ACCOUNT_BASE64) {
    const decoded = Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_BASE64, 'base64').toString('utf8');
    const serviceAccount = JSON.parse(decoded);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: process.env.FIREBASE_PROJECT_ID,
    });
    return;
  }

  // Option 3: Fallback with just project ID
  admin.initializeApp({
    projectId: process.env.FIREBASE_PROJECT_ID,
  });
}

async function bootstrap() {
  initFirebase();
  const app = await NestFactory.create(AppModule);
  const isDev = process.env.NODE_ENV !== 'production';

  // Security headers
  app.use(
    helmet(
      isDev
        ? {
            // Swagger UI on HTTP LAN can render blank if CSP upgrades assets to HTTPS.
            contentSecurityPolicy: false,
            crossOriginEmbedderPolicy: false,
          }
        : undefined,
    ),
  );

  app.setGlobalPrefix('api/v1');

  app.useGlobalFilters(new HttpExceptionFilter());

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  // In development, allow all origins for mobile device testing
  // In production, restrict to ALLOWED_ORIGINS env variable
  app.enableCors({
    origin: isDev
      ? true
      : (process.env.ALLOWED_ORIGINS?.split(',') ?? []),
    methods: ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE'],
    credentials: true,
  });

  const config = new DocumentBuilder()
    .setTitle('Swap Style API')
    .setDescription('Community Clothing Swap Platform API')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('docs', app, document);
  SwaggerModule.setup('api', app, document);

  const port = process.env.PORT || 3001;
  // Listen on 0.0.0.0 to accept connections from physical devices on the network
  await app.listen(port, '0.0.0.0');
  console.log(`Application running on port ${port}`);
}
bootstrap();
