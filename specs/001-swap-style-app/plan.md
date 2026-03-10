# Implementation Plan: Swap Style

**Branch**: `001-swap-style-app` | **Date**: 2026-03-09 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-swap-style-app/spec.md`

## Summary

Swap Style is a community-driven mobile application for clothing swaps. Users list clothing items, discover nearby items via a Tinder-like swipe feed, form "double matches" when mutual interest exists, negotiate fair trades through counter-offers, and communicate through built-in chat. The platform emphasizes sustainability, trust (verification badges, ratings), and gamification (streaks, achievement badges). The technical approach uses a cross-platform mobile client with a REST + WebSocket backend API, geospatial queries for location-based discovery, and real-time messaging infrastructure.

## Technical Context

**Language/Version**: TypeScript 5.x (backend: Node.js 20 LTS), Dart 3.x (mobile: Flutter 3.x)  
**Primary Dependencies**: Backend: NestJS, Prisma ORM, Socket.IO; Mobile: Flutter, Riverpod, Dio  
**Storage**: PostgreSQL 16 (primary) + PostGIS (geospatial), Redis (caching/sessions/pub-sub), S3-compatible object storage (photos)  
**Testing**: Backend: Jest + Supertest; Mobile: Flutter test + integration_test; E2E: Maestro  
**Target Platform**: iOS 15+ and Android 10+ (API 29+)  
**Project Type**: mobile-app + web-service (API backend)  
**Performance Goals**: Feed load <2s on 4G, API p95 <500ms, real-time chat <300ms delivery, 5,000 concurrent users  
**Constraints**: <200ms UI response for interactions, <3s initial app load on 4G, photos max 5MB each, offline-tolerant (queue actions when offline)  
**Scale/Scope**: 5,000 concurrent users, ~12 screens, 17 data entities, single geographic market at launch

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| # | Principle | Requirement | Status | Notes |
|---|-----------|-------------|--------|-------|
| I | Code Quality Discipline | Style guides, naming conventions, self-documenting code, no dead code | ✅ PASS | ESLint + Prettier (backend), Dart analysis options (mobile), enforced in CI |
| II | Testing Standards (NON-NEGOTIABLE) | TDD, ≥80% coverage, unit + integration + E2E, automated in CI | ✅ PASS | Jest (backend), Flutter test (mobile), Maestro (E2E), coverage gates in CI |
| III | User Experience Consistency | Reusable components, WCAG 2.1 AA, <200ms UI response, user acceptance criteria | ✅ PASS | Flutter widget library for consistency, accessibility semantics, acceptance scenarios defined per story |
| IV | Performance Requirements | <3s load, API p95 <500ms, optimized queries, no N+1, timeouts on async | ✅ PASS | PostGIS spatial indexing, Prisma eager loading, Redis caching, Socket.IO heartbeat timeouts |
| QA | Quality Assurance Standards | Linting + type checking + security scanning on every commit | ✅ PASS | ESLint, dart analyze, npm audit, Snyk in CI pipeline |
| WF | Development Workflow | TDD cycle, code review gates, automated quality gates, docs updated | ✅ PASS | PR template with checklist, required CI pass before review, API docs auto-generated |

**Gate Result: PASS** — No violations. Proceeding to Phase 0.

### Post-Design Re-evaluation (after Phase 1)

| # | Principle | Design Artifact Check | Status | Notes |
|---|-----------|----------------------|--------|-------|
| I | Code Quality | data-model.md follows naming conventions; contracts use consistent patterns | ✅ PASS | Prisma-style naming (snake_case DB, camelCase API), clear entity separation |
| II | Testing | All 12 entities + 60+ endpoints defined → testable contracts established | ✅ PASS | Each endpoint has defined request/response shapes for contract testing |
| III | UX Consistency | API error format standardized; pagination patterns uniform across all endpoints | ✅ PASS | Consistent `{ data, meta }` envelope; standard HTTP status codes |
| IV | Performance | PostGIS GIST index on Item.location; B-tree indexes on hot query paths; cursor pagination for chat | ✅ PASS | 13 indexes defined in data-model.md; chat uses cursor-based pagination |
| QA | Quality Assurance | Swagger auto-generation planned; Prisma schema = single source of truth | ✅ PASS | `@nestjs/swagger` decorators on all DTOs; Prisma migrations versioned |
| WF | Development Workflow | quickstart.md documents full dev setup; docker-compose for infra | ✅ PASS | Repeatable local setup; common commands documented |

**Post-Design Gate Result: PASS** — All design artifacts align with Constitution principles.

## Project Structure

### Documentation (this feature)

```text
specs/001-swap-style-app/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (API contracts)
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
api/
├── src/
│   ├── modules/
│   │   ├── auth/            # Registration, login, JWT, verification
│   │   ├── users/           # Profiles, closets, wishlists, ratings
│   │   ├── items/           # Item CRUD, photo upload, verification checklist
│   │   ├── discovery/       # Swipe feed, geospatial queries, filtering
│   │   ├── matching/        # Like recording, double-match detection, expiry
│   │   ├── counter-offers/  # Negotiation proposals, round tracking
│   │   ├── chat/            # WebSocket messaging, message persistence
│   │   ├── notifications/   # Push notification dispatch (FCM/APNs)
│   │   ├── gamification/    # Streaks, badges, achievement tracking
│   │   └── moderation/      # Reports, blocks, flagged content
│   ├── common/              # Guards, interceptors, decorators, DTOs
│   ├── config/              # Environment config, database config
│   └── main.ts
├── prisma/
│   └── schema.prisma        # Database schema
├── test/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── package.json
└── tsconfig.json

mobile/
├── lib/
│   ├── core/
│   │   ├── api/             # API client (Dio), WebSocket client
│   │   ├── models/          # Data models (freezed)
│   │   ├── providers/       # Riverpod providers
│   │   ├── router/          # GoRouter navigation
│   │   └── theme/           # Design tokens, colors, typography
│   ├── features/
│   │   ├── auth/            # Login, registration, verification screens
│   │   ├── discovery/       # Swipe feed, item cards, filters
│   │   ├── matching/        # Match list, match detail, counter-offers
│   │   ├── chat/            # Chat list, conversation screen
│   │   ├── profile/         # Own profile, closet, history, wishlist
│   │   ├── items/           # Add item, edit item, verification checklist
│   │   └── gamification/    # Streaks, badges, achievements
│   ├── shared/
│   │   ├── widgets/         # Reusable UI components
│   │   └── utils/           # Formatters, validators, constants
│   └── main.dart
├── test/                    # Unit + widget tests
├── integration_test/        # Integration + E2E tests
└── pubspec.yaml
```

**Structure Decision**: Mobile + API architecture. Flutter for cross-platform mobile (iOS + Android from single codebase), NestJS API backend with modular architecture. Separation keeps backend independently testable and deployable.

## Complexity Tracking

> No constitution violations — this section is empty.
