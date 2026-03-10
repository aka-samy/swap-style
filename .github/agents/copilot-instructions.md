# Swap Style Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-03-09

## Active Technologies

- **Languages**: TypeScript 5.x (backend: Node.js 20 LTS), Dart 3.x (mobile: Flutter 3.x)
- **Framework (Backend)**: NestJS, Prisma ORM, Socket.IO, BullMQ
- **Framework (Mobile)**: Flutter, Riverpod, Dio, GoRouter
- **Database**: PostgreSQL 16 + PostGIS 3.4 (geospatial), Redis 7 (caching/sessions/pub-sub/queue)
- **Storage**: Cloudflare R2 (S3-compatible object storage for photos)
- **Auth**: Firebase Auth (email/phone)
- **Notifications**: Firebase Cloud Messaging (FCM)
- **Project Type**: mobile-app + web-service (API backend)

## Project Structure

```text
swap-style/
├── api/                        # NestJS backend
│   ├── src/
│   │   ├── modules/
│   │   │   ├── auth/           # Firebase Auth integration
│   │   │   ├── users/          # Profile, verification
│   │   │   ├── items/          # CRUD, photos, verification checklist
│   │   │   ├── discovery/      # PostGIS feed, swipe recording
│   │   │   ├── matching/       # Double-match detection, confirmation
│   │   │   ├── counter-offers/ # Negotiation (max 5/side)
│   │   │   ├── chat/           # Socket.IO real-time messaging
│   │   │   ├── notifications/  # FCM push + in-app
│   │   │   ├── gamification/   # Streaks, badges
│   │   │   └── moderation/     # Reports, blocks
│   │   ├── common/             # Guards, pipes, interceptors
│   │   └── main.ts
│   ├── prisma/
│   │   └── schema.prisma
│   └── package.json
├── mobile/                     # Flutter app
│   ├── lib/
│   │   ├── features/           # Feature-first architecture
│   │   │   ├── auth/
│   │   │   ├── discovery/
│   │   │   ├── matching/
│   │   │   ├── chat/
│   │   │   ├── profile/
│   │   │   └── gamification/
│   │   ├── core/               # DI, routing, theme, config
│   │   ├── shared/             # Reusable widgets, models
│   │   └── main.dart
│   └── pubspec.yaml
└── specs/                      # Spec Kit artifacts
```

## Commands

### Backend (api/)
```bash
npm run start:dev          # Dev server with hot-reload
npm run test               # Unit tests
npm run test:e2e           # Integration tests
npm run lint               # ESLint
npx prisma migrate dev     # Run migrations
npx prisma generate        # Regenerate Prisma client
npx prisma studio          # Database GUI
```

### Mobile (mobile/)
```bash
flutter pub get            # Install dependencies
flutter run                # Run on connected device
flutter test               # Run tests
flutter analyze            # Dart linter
flutter build apk          # Build Android
flutter build ios          # Build iOS
```

## Code Style

### TypeScript (Backend)
- NestJS module pattern: controller → service → repository (via Prisma)
- Use decorators for validation (`class-validator`), auth guards, and Swagger docs
- Async/await everywhere; no raw callbacks
- DTOs for request/response shapes
- Prisma for all database access (no raw SQL except PostGIS functions)

### Dart (Mobile)
- Feature-first folder structure
- Riverpod for state management (prefer `AsyncNotifier` + `ref.watch`)
- Dio interceptors for auth token injection
- GoRouter for declarative navigation
- Immutable models with `freezed` or manual `copyWith`

## Recent Changes

- **001-swap-style-app**: Initial feature — clothing swap platform with swipe discovery, double matching, counter-offers, real-time chat, gamification, and verification system.

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
