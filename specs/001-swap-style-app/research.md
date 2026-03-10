# Research: Swap Style

**Date**: 2026-03-09  
**Feature**: [spec.md](spec.md) | [plan.md](plan.md)

## 1. Cross-Platform Mobile Framework

**Decision**: Flutter (Dart 3.x)

**Rationale**: Flutter's Skia rendering engine delivers consistent 60fps swipe animations with GPU acceleration and no bridge overhead. Direct Dart-to-native compilation achieves <50ms UI updates, well under the <200ms Constitution requirement. Mature ecosystem for swipe cards (`appinio_swipe_cards`), geolocation (`geolocator`), WebSocket chat (`socket_io_client`), image caching (`cached_network_image`), and Firebase integration.

**Alternatives Considered**:
- React Native: JS bridge causes animation frame drops on complex swipe gestures, creating jank during the core interaction loop. Larger developer ecosystem but performance risk on primary UX feature.
- Native (Swift/Kotlin): Guaranteed performance but requires two codebases (2x development cost). Not justified given Flutter's capabilities meet all requirements.

**Key Notes**:
- Use `GestureDetector` + velocity-based physics for swipe animations
- Preload next 2-3 card images via `precacheImage()` to prevent lag
- Cache geolocation for 2-5 minutes to preserve battery
- State management: Riverpod for predictable, testable state

## 2. Backend Framework

**Decision**: NestJS (Node.js 20 LTS, TypeScript 5.x)

**Rationale**: First-class Socket.IO WebSocket support via `@nestjs/websockets` for real-time chat. Single framework handles REST + WebSocket without architectural friction. Native BullMQ integration for background jobs (match expiry, streak reset). PostGIS works seamlessly through Prisma ORM. Event loop handles 5,000 concurrent I/O connections efficiently.

**Alternatives Considered**:
- FastAPI (Python): WebSocket ecosystem less mature. Requires Celery + Redis for background jobs (adds complexity). Limited geospatial ORM packages.
- Spring Boot (Kotlin): Heavier startup (~2-3s vs <1s for Node), higher JVM memory footprint. Overkill for 5,000-user scale.

**Key Notes**:
- Connection pooling: PostgreSQL 20-30 connections, Redis 10-20
- Rate limiting middleware: separate limits for public vs authenticated endpoints
- Database transactions for critical operations (match creation, swap confirmation)
- Auto-generate API docs via `@nestjs/swagger`

## 3. Geospatial Query Strategy

**Decision**: PostgreSQL + PostGIS with GIST-indexed radius queries

**Rationale**: PostGIS natively supports `ST_DWithin` for radius queries and `ST_Distance` for distance sorting, both accelerated by GIST spatial indexes. Achieves <50ms response for 10k+ locations within 50km. Combines efficiently with bitmap indexes on filter columns (size, category) via PostgreSQL query planner. Proven at scale (Uber, Mapbox, Lyft).

**Alternatives Considered**:
- Redis Geospatial (`GEORADIUS`): Stores only lat/lon + single score; cannot combine with clothing filters efficiently. Would require post-filtering in application code.
- MongoDB 2dsphere: Less mature than PostGIS; inconsistent performance with large datasets.
- Elasticsearch Geo: Adds infrastructure complexity; primarily optimized for full-text search, not pure spatial queries.

**Key Notes**:
- Index: `CREATE INDEX idx_items_location ON items USING GIST(location)`
- Separate B-tree indexes on `size`, `category`, `condition` for filter queries
- Pagination: cursor-based with `location <-> user_location` operator and `LIMIT 50`
- Cache search results (vary by location hash + filters) for 2-5 minutes

## 4. Real-Time Chat Architecture

**Decision**: Socket.IO via NestJS with PostgreSQL message persistence + Redis adapter

**Rationale**: Socket.IO provides auto-fallback to HTTP long-polling, robust client libraries across iOS versions, and native Room abstraction perfect for 1:1 conversations. Messages persisted in PostgreSQL for history; Redis adapter enables horizontal scaling across multiple server instances. Read receipts tracked via `read_at` timestamp per message row.

**Alternatives Considered**:
- Raw WebSockets: Requires manual reconnection, message buffering, and connection tracking. Reinventing functionality Socket.IO provides out of the box.
- Firebase Realtime Database: Managed but limited history query capability, eventual consistency, vendor lock-in, higher cost at scale.
- Managed services (Pusher, Ably): Excellent uptime but $500+/month at scale; message history requires separate DB anyway.

**Key Notes**:
- Conversation ID: `sorted([user_a_id, user_b_id]).join('-')` for uniqueness
- Message history: cursor-based pagination (30 per page) using `created_at` + `id`
- Typing indicator: debounce client emissions to 200ms; "stopped" after 1s inactivity
- Offline: store unread count in Redis; trigger push notification via FCM

## 5. Authentication & User Verification

**Decision**: Firebase Auth

**Rationale**: Out-of-box email verification links, SMS phone verification via Firebase Phone Auth, and automatic token refresh via mobile SDKs. Eliminates custom JWT management, secret rotation, and token storage concerns. Production-ready in days. Firebase emulator enables offline testing.

**Alternatives Considered**:
- Auth0: Enterprise-grade with MFA and social auth but $500+/month at scale. Over-engineered for MVP.
- Custom JWT: Maximum control but high maintenance burden and security risk if implemented incorrectly. Deferred to post-MVP if specific compliance requirements arise.

**Key Notes**:
- Client: `firebase_auth` Flutter package; auto-stores refresh token
- Backend: validate ID token via Firebase Admin SDK on every API request
- Token expiry: 1 hour; refresh token valid 30 days
- Account deletion: `admin.auth().deleteUser(uid)` cascades to user data
- Phone verification: 6-digit SMS OTP

## 6. Image Upload & Storage

**Decision**: Client-side compression + S3-compatible storage (Cloudflare R2) with presigned URLs + CDN

**Rationale**: Presigned URLs allow direct mobile-to-storage upload, bypassing the backend entirely. Client-side compression (80% JPEG, max 1024x1024) reduces bandwidth. R2 is 80% cheaper than S3 ($0.015/GB vs $0.023/GB) with identical S3 API. Native Cloudflare CDN on R2 has no egress fees. Thumbnail generation via serverless function on upload event.

**Alternatives Considered**:
- Server-side compression: Adds backend CPU load; becomes bottleneck at 5,000 concurrent users.
- MinIO (self-hosted): Operational burden outweighs cost savings at this scale.
- Firebase Storage: Acceptable alternative but less flexible and higher cost than R2.

**Key Notes**:
- Presigned URL flow: mobile requests URL from backend (15-min expiry), uploads directly
- Client: `image_picker` + `image` package for compression
- Thumbnail generation: serverless function triggered on upload event
- CDN headers: `Cache-Control: max-age=31536000` for immutable images (content-addressed)
- Lifecycle policy: delete unverified uploads after 7 days

## 7. Push Notification Strategy

**Decision**: Firebase Cloud Messaging (FCM) for both platforms

**Rationale**: Single integration handles iOS (APNs behind the scenes) and Android natively. Zero per-notification cost unlike OneSignal/Twilio. Production-grade reliability (99.9% SLA). Flutter integration via `firebase_messaging` package is standard and well-documented.

**Alternatives Considered**:
- Separate APNs + FCM: Double operational burden for certificate/key management. No benefit over FCM.
- OneSignal: Campaign UI is excellent but $99+/month at scale for transactional notifications.
- AWS SNS: General-purpose; less optimized for mobile use case.

**Key Notes**:
- Notification payload: `{ title, body, image_url, match_id, conversation_id, action }` — keep <1KB
- Android: `priority: 'high'` to prevent suppression; notification channel importance: high
- Device token: store in user record; refresh on token callback (~every 30 days)
- Testing: Firebase emulator for offline testing; Postman for Admin SDK testing

## 8. Background Job Processing

**Decision**: BullMQ (Redis-backed) with NestJS `@nestjs/bull` integration

**Rationale**: Native NestJS integration via decorator-based processors. Redis persistence ensures jobs survive process restarts. Handles all scheduled needs: match expiry (14-day delayed jobs), 24-hour expiry warnings (hourly scan), streak resets (daily per-timezone), and stale data cleanup (weekly). Bull Dashboard provides monitoring UI. 3-5 jobs/minute typical load is trivial for BullMQ.

**Alternatives Considered**:
- node-cron: No persistence; jobs lost if process crashes. Unacceptable for match expiry.
- pg_cron (database-level): Tight coupling to database logic; harder to test independently.
- AWS Lambda scheduled events: Cold starts (1-3s) and cost exceed Redis solution.
- Kubernetes CronJob: Over-engineered for MVP; viable for later scaling.

**Key Notes**:
- Job definitions: `expireMatch` (14d delay), `warnMatches` (hourly), `resetStreaks` (daily), `cleanupUnverified` (weekly)
- Retry: 3 attempts with exponential backoff (2s → 60s → 300s)
- Timezone: store user timezone in profile; calculate local midnight server-side via `date-fns`
- Monitoring: Bull Dashboard + Sentry alerts on job failures

## Integration Architecture Summary

```text
┌─────────────────────────────────────────────────┐
│                 Flutter Mobile App               │
│  (iOS 15+ / Android 10+)                        │
├─────────────────────────────────────────────────┤
│  REST API (Dio)  │  WebSocket (Socket.IO client) │
│  Firebase Auth    │  FCM Push Notifications       │
│  S3 Presigned URL │  Image Picker + Compression   │
└────────┬─────────┴──────────┬────────────────────┘
         │                    │
         ▼                    ▼
┌─────────────────────────────────────────────────┐
│              NestJS API Server                   │
│  (Node.js 20 LTS, TypeScript 5.x)               │
├─────────────────────────────────────────────────┤
│  REST Endpoints   │  Socket.IO Gateway           │
│  Prisma ORM       │  Firebase Admin SDK           │
│  BullMQ Workers   │  @nestjs/swagger (docs)       │
└────────┬─────────┴──────────┬────────────────────┘
         │                    │
    ┌────▼────┐         ┌────▼────┐
    │PostgreSQL│         │  Redis  │
    │+ PostGIS │         │(cache,  │
    │(primary  │         │sessions,│
    │ storage) │         │jobs,    │
    └─────────┘         │pub-sub) │
                        └─────────┘
         │
    ┌────▼──────────┐
    │ Cloudflare R2  │
    │ (S3-compatible │
    │  photo storage │
    │  + CDN)        │
    └────────────────┘
```
