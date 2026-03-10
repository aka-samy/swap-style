# Security Audit — Swap Style API

**Date**: TBD
**Scope**: OWASP Top 10 review of the NestJS REST API and Flutter mobile app.

---

## 1. Broken Access Control

| Check | Status | Notes |
|-------|--------|-------|
| All endpoints behind `FirebaseAuthGuard` | ✅ Pass | All controllers use `@UseGuards(FirebaseAuthGuard)` |
| Users can only modify own items | ✅ Pass | `ItemsService.update/delete` checks `ownerId === userId` |
| Users can rate only matches they participated in | ✅ Pass | `RatingsService.createRating` validates match participants |
| Block/unblock targets validated | ✅ Pass | Cannot block self; NotFoundException on unknown target |

## 2. Cryptographic Failures

| Check | Status | Notes |
|-------|--------|-------|
| Secrets in environment variables | ✅ Pass | `.env` not committed; `.gitignore` covers `.env*` |
| Firebase token validation | ✅ Pass | `firebase-admin` SDK verifies JWT signatures |
| R2 presigned URLs expire | ✅ Pass | `expiresIn: 3600` (1 hour) |
| Database credentials not hardcoded | ✅ Pass | `DATABASE_URL` from `ConfigService` |

## 3. Injection

| Check | Status | Notes |
|-------|--------|-------|
| SQL injection via raw queries | ✅ Pass | `Prisma.sql` tagged template literals auto-parameterize |
| DTO validation with class-validator | ✅ Pass | `ValidationPipe({ whitelist: true })` strips extra fields |
| XSS via stored content | ⚠️ Review | Chat messages + item descriptions should be sanitized before rendering in Flutter (use `flutter_html` safely or plain Text widgets) |

## 4. Insecure Design

| Check | Status | Notes |
|-------|--------|-------|
| Rate limiting on auth endpoints | ⚠️ TODO | Add `@nestjs/throttler` to `/auth/*` endpoints |
| Counter-offer spam (5 per side limit) | ✅ Pass | Enforced in `CounterOffersService` |
| Match double-confirm idempotency | ✅ Pass | Checks `CONFIRMED` status before re-processing |

## 5. Security Misconfiguration

| Check | Status | Notes |
|-------|--------|-------|
| CORS origin restriction | ⚠️ TODO | `app.enableCors()` in `main.ts` — restrict `origin` in production |
| Helmet middleware | ⚠️ TODO | Add `helmet` package and `app.use(helmet())` in `main.ts` |
| `.dockerignore` covers `.env*` | ✅ Pass | `.dockerignore` includes `.env*` |

## 6. Vulnerable & Outdated Components

| Check | Status | Notes |
|-------|--------|-------|
| `npm audit` run | ⚠️ TODO | Run `npm audit --audit-level=high` in CI |
| `flutter pub outdated` run | ⚠️ TODO | Add to CI mobile check step |

## 7. Identification & Authentication Failures

| Check | Status | Notes |
|-------|--------|-------|
| Firebase phone verification required | ✅ Pass | `POST /auth/verify-phone` forces OTP check before verified flag |
| FCM token stored per-user | ✅ Pass | `POST /auth/fcm-token` requires auth |

## 8. Software & Data Integrity Failures

| Check | Status | Notes |
|-------|--------|-------|
| CI pipeline on all PRs | ✅ Pass | `.github/workflows/ci.yml` runs lint + test |
| Dependency lockfile committed | ✅ Pass | `package-lock.json` / `pubspec.lock` |

## 9. Security Logging & Monitoring

| Check | Status | Notes |
|-------|--------|-------|
| Structured logging with NestJS Logger | ✅ Pass | Used in services |
| Audit log for moderation actions | ⚠️ TODO | Store `Report` / `Block` creation timestamps (already in schema) |
| Error responses don't leak stack traces | ⚠️ TODO | Set `app.useGlobalFilters` in production to suppress stack traces |

## 10. SSRF

| Check | Status | Notes |
|-------|--------|-------|
| No server-side URL fetching from user input | ✅ Pass | Only presigned R2 URLs generated server-side |
| Webhook / external callback endpoints | ✅ N/A | None in current scope |

---

## Recommended Immediate Actions (Pre-Launch)

1. Add `@nestjs/throttler` for `/auth/*` (rate limit 5 req/min)
2. Add `helmet()` middleware in `main.ts`
3. Restrict CORS `origin` to production domain
4. Run `npm audit` in CI pipeline
5. Sanitize rendered chat content in Flutter (use `Text` widget, never `HtmlWidget` with unsanitized input)
