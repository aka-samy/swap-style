# Quickstart: Swap Style Development Setup

**Date**: 2026-03-09

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Node.js | 20 LTS | https://nodejs.org |
| npm | 10+ | Bundled with Node.js |
| Flutter | 3.x (stable) | https://docs.flutter.dev/get-started/install |
| Dart | 3.x | Bundled with Flutter |
| PostgreSQL | 16 | https://www.postgresql.org/download/ |
| PostGIS | 3.4+ | `CREATE EXTENSION postgis;` after installing PostgreSQL |
| Redis | 7+ | https://redis.io/download or Docker |
| Git | 2.x | https://git-scm.com |

## Project Structure

```
swap-style/
├── api/                    # NestJS backend
│   ├── src/
│   │   ├── modules/        # Feature modules (auth, items, discovery, etc.)
│   │   ├── common/         # Shared guards, pipes, interceptors
│   │   └── main.ts
│   ├── prisma/
│   │   └── schema.prisma   # Database schema
│   ├── .env.example
│   └── package.json
├── mobile/                 # Flutter app
│   ├── lib/
│   │   ├── features/       # Feature-first folders
│   │   ├── core/           # DI, routing, theme
│   │   └── main.dart
│   └── pubspec.yaml
└── specs/                  # This specification directory
```

## 1. Backend Setup (NestJS API)

```bash
# Clone and navigate
cd swap-style/api

# Install dependencies
npm install

# Copy environment file and fill in values
cp .env.example .env
```

### Environment Variables (.env)

```env
# Database
DATABASE_URL=postgresql://postgres:password@localhost:5432/swapstyle?schema=public

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# Firebase
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_SERVICE_ACCOUNT_KEY=./firebase-service-account.json

# Cloudflare R2
R2_ACCOUNT_ID=your-account-id
R2_ACCESS_KEY_ID=your-access-key
R2_SECRET_ACCESS_KEY=your-secret-key
R2_BUCKET_NAME=swapstyle-photos
R2_PUBLIC_URL=https://your-r2-domain.example.com

# App
PORT=3000
NODE_ENV=development
JWT_SECRET=dev-secret-change-in-production
```

### Database Setup

```bash
# Create the database
createdb swapstyle

# Enable PostGIS
psql -d swapstyle -c "CREATE EXTENSION postgis;"

# Run Prisma migrations
npx prisma migrate dev

# Seed sample data (if seed script exists)
npx prisma db seed
```

### Run the API

```bash
# Development (watch mode)
npm run start:dev

# API available at http://localhost:3000
# Swagger docs at http://localhost:3000/api/docs
```

### Verify API is Running

```bash
curl http://localhost:3000/health
# Expected: { "status": "ok" }
```

## 2. Mobile Setup (Flutter)

```bash
cd swap-style/mobile

# Get dependencies
flutter pub get

# Verify setup
flutter doctor
```

### Firebase Configuration

1. Create a Firebase project at https://console.firebase.google.com
2. Add an Android app (package: `com.swapstyle.app`) — download `google-services.json` → `mobile/android/app/`
3. Add an iOS app (bundle: `com.swapstyle.app`) — download `GoogleService-Info.plist` → `mobile/ios/Runner/`
4. Enable **Email/Password** and **Phone** sign-in methods in Firebase Console → Authentication

### Run the Mobile App

```bash
# Run on connected device / emulator
flutter run

# Run on specific platform
flutter run -d chrome    # Web (for quick testing)
flutter run -d android   # Android emulator
flutter run -d ios       # iOS simulator (macOS only)
```

### Point to Local API

In `mobile/lib/core/config/app_config.dart`, set:
```dart
static const String apiBaseUrl = 'http://10.0.2.2:3000/api/v1'; // Android emulator
// static const String apiBaseUrl = 'http://localhost:3000/api/v1'; // iOS simulator
```

## 3. Common Dev Commands

| Task | Command | Location |
|------|---------|----------|
| Run API tests | `npm run test` | `api/` |
| Run API e2e tests | `npm run test:e2e` | `api/` |
| Run Flutter tests | `flutter test` | `mobile/` |
| Generate Prisma client | `npx prisma generate` | `api/` |
| Create migration | `npx prisma migrate dev --name <name>` | `api/` |
| View database | `npx prisma studio` | `api/` |
| Lint API code | `npm run lint` | `api/` |
| Lint Flutter code | `flutter analyze` | `mobile/` |
| Build APK | `flutter build apk` | `mobile/` |
| Build iOS | `flutter build ios` | `mobile/` |

## 4. Docker Alternative (Backend)

```yaml
# docker-compose.yml (place in repo root)
services:
  postgres:
    image: postgis/postgis:16-3.4
    environment:
      POSTGRES_DB: swapstyle
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  pgdata:
```

```bash
docker compose up -d
# Then run API with npm run start:dev as above
```

## 5. First Smoke Test

1. Start PostgreSQL + Redis: `docker compose up -d` (from repo root)
2. `cd api && npm install && cp .env.example .env` (fill in Firebase + R2 values)
3. `npx prisma migrate dev --name init`
4. `npx prisma db seed` (seeds badge definitions)
5. `npm run start:dev`
6. Open Swagger at `http://localhost:3000/api/docs`
7. Register a user via `POST /auth/register`
8. `cd mobile && flutter pub get && flutter run`
9. Sign in in the app → verify user appears in DB via `npx prisma studio`

## 6. Key API Modules (Quick Reference)

| Module | Base Route | Description |
|--------|-----------|-------------|
| auth | `/auth` | Register, FCM token, phone verification |
| items | `/items` | CRUD clothing items + photo upload |
| discovery | `/discovery` | Feed (PostGIS), swipe |
| matching | `/matching/matches` | Match management, confirm, cancel |
| counter-offers | `/matches/:id/counter-offers` | Propose/accept/decline |
| chat | `/chat/:matchId/messages` | REST messages + Socket.IO |
| ratings | `/matches/:id/rating`, `/users/:id/ratings` | Post-swap ratings |
| users | `/users` | Profile, wishlist |
| gamification | `/gamification/stats`, `/gamification/badges` | Streaks and badges |
| moderation | `/users/:id/report`, `/users/:id/block` | Report and block |
| notifications | `/notifications` | FCM push notification history |
