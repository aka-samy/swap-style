# Tasks: Swap Style — Community Clothing Swap Platform

**Input**: Design documents from `/specs/001-swap-style-app/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/api-contracts.md, research.md, quickstart.md

**Tests**: Included — Constitution Principle II (Testing Standards) requires TDD as NON-NEGOTIABLE. Tests are written before implementation within each user story phase.

**Organization**: Tasks grouped by user story for independent implementation and testing. Registration/auth is in Foundational since ALL stories depend on it. User Story 5's phase covers profile display and management.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Exact file paths included per task

## Path Conventions

- **Backend (NestJS API)**: `api/src/`, `api/prisma/`, `api/test/`
- **Mobile (Flutter)**: `mobile/lib/`, `mobile/test/`, `mobile/integration_test/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Scaffold both projects, configure dev tooling and infrastructure

- [X] T001 Initialize NestJS project with dependencies (Prisma, Socket.IO, BullMQ, class-validator, Swagger) in api/
- [X] T002 Initialize Flutter project with dependencies (Riverpod, Dio, GoRouter, freezed, appinio_swipe_cards, socket_io_client, firebase_auth, firebase_messaging) in mobile/
- [X] T003 [P] Create Docker Compose file with PostGIS 16 and Redis 7 in docker-compose.yml
- [X] T004 [P] Configure ESLint + Prettier for the API in api/.eslintrc.js and api/.prettierrc
- [X] T005 [P] Configure Dart analysis options and lint rules in mobile/analysis_options.yaml
- [X] T006 [P] Create environment configuration file with all required variables in api/.env.example
- [X] T007 [P] Configure GitHub Actions CI pipeline skeleton in .github/workflows/ci.yml

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Database & ORM

- [X] T008 Define complete Prisma schema with all 16 entities, enums, relations, and indexes in api/prisma/schema.prisma
- [X] T009 Enable PostGIS extension and run initial Prisma migration in api/prisma/migrations/

### Backend Core (NestJS)

- [X] T010 [P] Implement Firebase Auth guard for JWT validation in api/src/common/guards/firebase-auth.guard.ts
- [X] T011 [P] Create global HTTP exception filter with standard error format in api/src/common/filters/http-exception.filter.ts
- [X] T012 [P] Configure global validation pipe with class-validator in api/src/common/pipes/validation.pipe.ts
- [X] T013 [P] Configure Swagger/OpenAPI documentation in api/src/main.ts
- [X] T014 [P] Setup Redis connection module in api/src/common/redis/redis.module.ts
- [X] T015 [P] Setup BullMQ queue module with connection config in api/src/common/queue/queue.module.ts
- [X] T016 [P] Implement Cloudflare R2 upload service with presigned URLs in api/src/common/storage/storage.service.ts
- [X] T017 Implement Auth module (register, phone verify, FCM token update) in api/src/modules/auth/

### Mobile Core (Flutter)

- [X] T018 [P] Configure Dio HTTP client with Firebase Auth token interceptor in mobile/lib/core/api/api_client.dart
- [X] T019 [P] Configure GoRouter navigation shell with bottom tab bar in mobile/lib/core/router/app_router.dart
- [X] T020 [P] Setup Riverpod root providers and auth state notifier in mobile/lib/core/providers/auth_provider.dart
- [X] T021 [P] Create app theme with design tokens, colors, and typography in mobile/lib/core/theme/app_theme.dart
- [X] T022 [P] Setup Firebase SDK initialization (Auth + Messaging) in mobile/lib/main.dart
- [X] T023 Implement auth screens (sign-in, registration flow) in mobile/lib/features/auth/screens/

**Checkpoint**: Foundation ready — both projects run, auth works, DB migrated, user story implementation can begin

---

## Phase 3: User Story 1 — Item Listing & Closet Management (Priority: P1) 🎯 MVP

**Goal**: Users can list clothing items with photos, manage their closet (edit, remove), and items become available for discovery

**Independent Test**: Register → list an item with photos → verify it appears in Closet → edit it → remove it

**FRs**: FR-002, FR-012, FR-017

### Tests for US1

- [X] T024 [P] [US1] Write unit tests for ItemsService CRUD operations in api/src/modules/items/items.service.spec.ts
- [X] T025 [P] [US1] Write unit tests for ItemsController endpoint validation in api/src/modules/items/items.controller.spec.ts

### Backend Implementation for US1

- [X] T026 [US1] Create Items module with request/response DTOs in api/src/modules/items/dto/
- [X] T027 [US1] Implement ItemsService with create, read, update, delete, and photo upload in api/src/modules/items/items.service.ts
- [X] T028 [US1] Implement ItemsController (POST /items, GET /items/me, GET /items/:id, PATCH /items/:id, DELETE /items/:id) in api/src/modules/items/items.controller.ts

### Mobile Implementation for US1

- [X] T029 [P] [US1] Create Item, ItemPhoto, and ItemVerification models with freezed in mobile/lib/core/models/item.dart
- [X] T030 [P] [US1] Create items API repository in mobile/lib/features/items/data/items_repository.dart
- [X] T031 [US1] Implement items state provider (list, create, update, delete) in mobile/lib/features/items/providers/items_provider.dart
- [X] T032 [US1] Build Add Item screen with photo picker, category/size/condition selectors, and form validation in mobile/lib/features/items/screens/add_item_screen.dart
- [X] T033 [US1] Build Closet screen with item grid, status indicators, and tap-to-edit in mobile/lib/features/items/screens/closet_screen.dart
- [X] T034 [US1] Build Edit Item screen with pre-populated form and delete action in mobile/lib/features/items/screens/edit_item_screen.dart
- [X] T035 [P] [US1] Write widget tests for Add Item and Closet screens in mobile/test/features/items/

**Checkpoint**: User Story 1 fully functional — users can list, view, edit, and remove items

---

## Phase 4: User Story 2 — Swipe Discovery (Priority: P1)

**Goal**: Users see a swipe feed of nearby items, can Like (right) or Pass (left), with location-based ranking

**Independent Test**: List items from multiple accounts → swipe through on another account → verify cards render, swipe actions recorded, already-swiped items don't reappear

**FRs**: FR-003, FR-004, FR-006, FR-020

### Tests for US2

- [X] T036 [P] [US2] Write unit tests for DiscoveryService feed query and swipe logic in api/src/modules/discovery/discovery.service.spec.ts

### Backend Implementation for US2

- [X] T037 [US2] Create Discovery module with feed and swipe DTOs in api/src/modules/discovery/dto/
- [X] T038 [US2] Implement DiscoveryService with PostGIS ST_DWithin feed query and Like recording in api/src/modules/discovery/discovery.service.ts
- [X] T039 [US2] Implement DiscoveryController (GET /discovery/feed, POST /discovery/swipe) in api/src/modules/discovery/discovery.controller.ts

### Mobile Implementation for US2

- [X] T040 [P] [US2] Create discovery API repository in mobile/lib/features/discovery/data/discovery_repository.dart
- [X] T041 [US2] Implement discovery provider with card stack state in mobile/lib/features/discovery/providers/discovery_provider.dart
- [X] T042 [US2] Build swipe feed screen with Appinio swipe cards in mobile/lib/features/discovery/screens/discovery_screen.dart
- [X] T043 [P] [US2] Build item card widget with photo carousel, brand, size, condition, and distance in mobile/lib/features/discovery/widgets/item_card.dart
- [X] T044 [P] [US2] Build empty feed widget with "No more items nearby" message in mobile/lib/features/discovery/widgets/empty_feed.dart
- [X] T045 [US2] Write widget tests for discovery screen and item card in mobile/test/features/discovery/

**Checkpoint**: Users can browse nearby items via swipe — the core daily interaction loop works

---

## Phase 5: User Story 3 — Double Match & Match Notification (Priority: P1)

**Goal**: When two users mutually like each other's items, a Match is created and both are notified via push + in-app. Matches expire after 14 days of inactivity with a 24-hour warning.

**Independent Test**: User A likes User B's item → User B likes User A's item → both get match notification → verify match detail screen → wait for expiry warning

**FRs**: FR-005, FR-006, FR-010, FR-017, FR-022

### Tests for US3

- [X] T046 [P] [US3] Write unit tests for MatchingService double-match detection in api/src/modules/matching/matching.service.spec.ts
- [X] T047 [P] [US3] Write unit tests for NotificationsService push dispatch in api/src/modules/notifications/notifications.service.spec.ts

### Backend Implementation for US3

- [X] T048 [US3] Create Matching module with match DTOs in api/src/modules/matching/dto/
- [X] T049 [US3] Implement MatchingService with double-match detection triggered on swipe-like in api/src/modules/matching/matching.service.ts
- [X] T050 [US3] Implement MatchingController (GET /matches, GET /matches/:id, POST /matches/:id/confirm, POST /matches/:id/cancel) in api/src/modules/matching/matching.controller.ts
- [X] T051 [US3] Create Notifications module with FCM push dispatch service in api/src/modules/notifications/notifications.service.ts
- [X] T052 [US3] Implement NotificationsController (GET /notifications, PATCH /notifications/:id/read) in api/src/modules/notifications/notifications.controller.ts
- [X] T053 [US3] Create match expiry BullMQ job (14-day delay) and expiry warning job (hourly scan) in api/src/modules/matching/jobs/match-expiry.processor.ts
- [X] T054 [US3] Implement auto-cancel of pending matches when item is deleted or swapped in api/src/modules/matching/matching.service.ts

### Mobile Implementation for US3

- [X] T055 [P] [US3] Create Match model with status enum in mobile/lib/core/models/match.dart
- [X] T056 [US3] Create matching API repository in mobile/lib/features/matching/data/matching_repository.dart
- [X] T057 [US3] Implement matching provider with match list state in mobile/lib/features/matching/providers/matching_provider.dart
- [X] T058 [US3] Build match list screen with match cards in mobile/lib/features/matching/screens/match_list_screen.dart
- [X] T059 [US3] Build match detail screen with both items, confirm/cancel actions in mobile/lib/features/matching/screens/match_detail_screen.dart
- [X] T060 [US3] Integrate FCM push notification handling and navigation in mobile/lib/core/providers/notification_provider.dart
- [X] T061 [US3] Write widget tests for match list and match detail screens in mobile/test/features/matching/

**Checkpoint**: Core swap loop complete — list items → discover → match → confirm. This is the MVP.

---

## Phase 6: User Story 5 — User Profile & Wishlist (Priority: P2)

**Goal**: Users view their profile with Closet, Swap History, Wishlist, and Rating. Can view other users' public profiles. Can manage wishlist entries.

**Independent Test**: Register → view own profile (all sections render, empty states work) → add wishlist entry → view another user's public profile

**FRs**: FR-001, FR-011, FR-019

### Tests for US5

- [X] T062 [P] [US5] Write unit tests for UsersService profile and wishlist operations in api/src/modules/users/users.service.spec.ts

### Backend Implementation for US5

- [X] T063 [US5] Create Users module with profile and wishlist DTOs in api/src/modules/users/dto/
- [X] T064 [US5] Implement UsersService (get/update profile, public profile, closet, wishlist CRUD) in api/src/modules/users/users.service.ts
- [X] T065 [US5] Implement UsersController (GET/PATCH /users/me, POST profile-photo, GET /users/:id, GET /users/:id/closet, GET/POST/DELETE /wishlist) in api/src/modules/users/users.controller.ts

### Mobile Implementation for US5

- [X] T066 [P] [US5] Create User and WishlistEntry models in mobile/lib/core/models/user.dart
- [X] T067 [US5] Create profile API repository in mobile/lib/features/profile/data/profile_repository.dart
- [X] T068 [US5] Implement profile provider with user state in mobile/lib/features/profile/providers/profile_provider.dart
- [X] T069 [US5] Build own profile screen with Closet, Swap History, Wishlist, and Rating tabs in mobile/lib/features/profile/screens/profile_screen.dart
- [X] T070 [US5] Build public profile screen for viewing other users in mobile/lib/features/profile/screens/public_profile_screen.dart
- [X] T071 [US5] Build wishlist management screen (add/remove entries) in mobile/lib/features/profile/screens/wishlist_screen.dart

**Checkpoint**: User profiles fully functional — own and public profiles display all sections

---

## Phase 7: User Story 4 — Counter-Offer System (Priority: P2)

**Goal**: Matched users can negotiate fair trades by proposing counter-offers (add items, monetary amounts). Max 5 per side, 10 total. Accept/decline/revise flow. Dual confirmation for physical swap completion.

**Independent Test**: Create a match → propose counter-offer with extra item → other user declines → new offer with monetary amount → accepted → both confirm completion

**FRs**: FR-007, FR-008

### Tests for US4

- [X] T072 [P] [US4] Write unit tests for CounterOffersService negotiation and round-limit logic in api/src/modules/counter-offers/counter-offers.service.spec.ts

### Backend Implementation for US4

- [X] T073 [US4] Create Counter-Offers module with propose/accept/decline DTOs in api/src/modules/counter-offers/dto/
- [X] T074 [US4] Implement CounterOffersService (propose, accept, decline, supersede, round tracking max 5/side) in api/src/modules/counter-offers/counter-offers.service.ts
- [X] T075 [US4] Implement CounterOffersController (POST /matches/:id/counter-offers, POST accept, POST decline) in api/src/modules/counter-offers/counter-offers.controller.ts

### Mobile Implementation for US4

- [X] T076 [P] [US4] Create CounterOffer model with status enum in mobile/lib/core/models/counter_offer.dart
- [X] T077 [US4] Create counter-offers API repository in mobile/lib/features/matching/data/counter_offers_repository.dart
- [X] T078 [US4] Implement counter-offer provider with negotiation state in mobile/lib/features/matching/providers/counter_offer_provider.dart
- [X] T079 [US4] Build propose counter-offer screen (select items, enter monetary amount) in mobile/lib/features/matching/screens/propose_offer_screen.dart
- [X] T080 [US4] Build review counter-offer screen (accept, decline, counter) in mobile/lib/features/matching/screens/review_offer_screen.dart
- [X] T081 [US4] Integrate counter-offer status into match detail screen in mobile/lib/features/matching/screens/match_detail_screen.dart

**Checkpoint**: Full negotiation flow works — matches can be negotiated to agreed and confirmed as completed

---

## Phase 8: User Story 6 — Built-in Chat (Priority: P2)

**Goal**: Matched users communicate in real-time via Socket.IO. Messages persist across sessions. Push notifications for background messages. Read markers.

**Independent Test**: Create a match → open chat → send messages both ways → verify real-time delivery → close app → reopen → verify history persists → verify push notification for background message

**FRs**: FR-009, FR-010

### Tests for US6

- [X] T082 [P] [US6] Write unit tests for ChatService message persistence and read markers in api/src/modules/chat/chat.service.spec.ts
- [X] T083 [P] [US6] Write unit tests for ChatGateway WebSocket event handling in api/src/modules/chat/chat.gateway.spec.ts

### Backend Implementation for US6

- [X] T084 [US6] Create Chat module with message DTOs in api/src/modules/chat/dto/
- [X] T085 [US6] Implement ChatService (create message, list with cursor pagination, mark read) in api/src/modules/chat/chat.service.ts
- [X] T086 [US6] Implement ChatController (GET /matches/:id/messages, POST message, PATCH read) in api/src/modules/chat/chat.controller.ts
- [X] T087 [US6] Implement ChatGateway with Socket.IO (join_match, send_message, typing, new_message events) in api/src/modules/chat/chat.gateway.ts

### Mobile Implementation for US6

- [X] T088 [P] [US6] Create Message model in mobile/lib/core/models/message.dart
- [X] T089 [US6] Create chat repository with REST + Socket.IO client in mobile/lib/features/chat/data/chat_repository.dart
- [X] T090 [US6] Implement chat provider with real-time message state and typing indicators in mobile/lib/features/chat/providers/chat_provider.dart
- [X] T091 [US6] Build conversation screen with message bubbles, input field, and typing indicator in mobile/lib/features/chat/screens/conversation_screen.dart
- [X] T092 [US6] Build chat list screen showing active match conversations with unread counts in mobile/lib/features/chat/screens/chat_list_screen.dart
- [X] T093 [US6] Write widget tests for conversation screen and chat list in mobile/test/features/chat/

**Checkpoint**: Real-time communication works — matched users can chat seamlessly

---

## Phase 9: User Story 7 — Verification & Trust System (Priority: P2)

**Goal**: Item verification checklist (washed, no stains, no tears, no defects, photos accurate) with "Verified" badge on items. User account verification (email + phone) with "Verified User" badge on profiles.

**Independent Test**: List an item → complete verification checklist → verify "Verified" badge on item card → complete phone verification → verify "Verified User" badge on profile

**FRs**: FR-012, FR-013

### Tests for US7

- [X] T094 [P] [US7] Write unit tests for item verification logic in api/src/modules/items/items.service.spec.ts (extend)

### Backend Implementation for US7

- [X] T095 [US7] Implement item verification endpoint (POST /items/:id/verify) in api/src/modules/items/items.controller.ts
- [X] T096 [US7] Implement phone verification flow (send code, confirm) in api/src/modules/auth/auth.service.ts

### Mobile Implementation for US7

- [X] T097 [US7] Build item verification checklist step within Add Item flow in mobile/lib/features/items/widgets/verification_checklist.dart
- [X] T098 [US7] Build phone verification screen (enter number, confirm code) in mobile/lib/features/auth/screens/phone_verify_screen.dart
- [X] T099 [US7] Create reusable verified badge widget for items and profiles in mobile/lib/shared/widgets/verified_badge.dart
- [X] T100 [US7] Write widget tests for verification checklist and badge display in mobile/test/features/items/verification_test.dart

**Checkpoint**: Trust system active — verified items show badges, verified users show profile badges

---

## Phase 10: User Story 8 — Smart Filtering (Priority: P3)

**Goal**: Users can filter the swipe feed by size, category, and location radius (default 50 km, custom up to any distance). Empty-state when no matches.

**Independent Test**: Set filter to size M + 15 km → verify only matching items in feed → set custom radius 100 km → verify expanded results → clear filters → verify default 50 km feed

**FRs**: FR-014, FR-020

### Tests for US8

- [X] T101 [P] [US8] Write unit tests for filter query combinations in api/src/modules/discovery/discovery.service.spec.ts (extend)

### Backend Implementation for US8

- [X] T102 [US8] Extend DiscoveryService with size, category, and custom radius filter parameters in api/src/modules/discovery/discovery.service.ts
- [X] T103 [US8] Update DiscoveryController feed endpoint with filter query params in api/src/modules/discovery/discovery.controller.ts

### Mobile Implementation for US8

- [X] T104 [US8] Build filter panel widget with size/category pickers and radius slider in mobile/lib/features/discovery/widgets/filter_panel.dart
- [X] T105 [US8] Create filter state provider with persistence in mobile/lib/features/discovery/providers/filter_provider.dart
- [X] T106 [US8] Integrate filter state into discovery feed and add filter icon to discovery screen in mobile/lib/features/discovery/screens/discovery_screen.dart

**Checkpoint**: Feed is filterable — users see only relevant items, improving swap efficiency

---

## Phase 11: User Story 9 — Rating System (Priority: P3)

**Goal**: After both users confirm a swap, each can rate the other (1-5 stars + optional comment). Ratings appear on profiles. Gentle reminders for unrated swaps.

**Independent Test**: Complete a swap → both users get rating prompt → submit 5-star rating with comment → verify it appears on partner's profile → verify average rating updates

**FRs**: FR-015

### Tests for US9

- [X] T107 [P] [US9] Write unit tests for RatingsService create and average calculation in api/src/modules/ratings/ratings.service.spec.ts

### Backend Implementation for US9

- [X] T108 [US9] Create Ratings module with rating DTOs in api/src/modules/ratings/dto/
- [X] T109 [US9] Implement RatingsService (create rating, list by user, average calculation) in api/src/modules/ratings/ratings.service.ts
- [X] T110 [US9] Implement RatingsController (POST /matches/:id/rating, GET /users/:id/ratings) in api/src/modules/ratings/ratings.controller.ts

### Mobile Implementation for US9

- [X] T111 [P] [US9] Create Rating model in mobile/lib/core/models/rating.dart
- [X] T112 [US9] Build rating prompt dialog (stars selector + comment) triggered after swap completion in mobile/lib/features/matching/widgets/rating_prompt.dart
- [X] T113 [US9] Build ratings list widget for profile screen in mobile/lib/features/profile/widgets/ratings_list.dart
- [X] T114 [US9] Write widget tests for rating prompt and ratings list in mobile/test/features/matching/rating_test.dart

**Checkpoint**: Trust loop complete — completed swaps generate ratings that build reputation

---

## Phase 12: User Story 10 — Gamification & Streaks (Priority: P3)

**Goal**: Track consecutive daily activity as streaks (reset at midnight in user's timezone). Award badges for milestones (first swap, 7-day streak, etc.). Display on profile.

**Independent Test**: Swipe daily for 3 days → verify streak counter increments → miss a day → verify reset → complete first swap → verify "First Swap" badge on profile

**FRs**: FR-016

### Tests for US10

- [X] T115 [P] [US10] Write unit tests for GamificationService streak and badge logic in api/src/modules/gamification/gamification.service.spec.ts

### Backend Implementation for US10

- [X] T116 [US10] Create Gamification module with streak and badge DTOs in api/src/modules/gamification/dto/
- [X] T117 [US10] Implement GamificationService (update streak on activity, check/award badges) in api/src/modules/gamification/gamification.service.ts
- [X] T118 [US10] Implement GamificationController (GET /gamification/streaks, GET /gamification/badges) in api/src/modules/gamification/gamification.controller.ts
- [X] T119 [US10] Create streak reset BullMQ job (daily per-timezone midnight reset) in api/src/modules/gamification/jobs/streak-reset.processor.ts
- [X] T120 [US10] Seed initial badge definitions (first_swap, streak_7, streak_30, etc.) in api/prisma/seed.ts

### Mobile Implementation for US10

- [X] T121 [P] [US10] Create Streak and Badge models in mobile/lib/core/models/gamification.dart
- [X] T122 [US10] Implement gamification provider with streak and badge state in mobile/lib/features/gamification/providers/gamification_provider.dart
- [X] T123 [US10] Build streak display and badge collection screen in mobile/lib/features/gamification/screens/gamification_screen.dart
- [X] T124 [US10] Write widget tests for streak and badge UI in mobile/test/features/gamification/

**Checkpoint**: Engagement layer complete — users are motivated by streaks and badges

---

## Phase 13: Polish & Cross-Cutting Concerns

**Purpose**: Moderation (reports, blocks), end-to-end tests, performance, security, documentation

- [X] T125 [P] Implement ModerationService (file report, block/unblock with match cancellation side effects) in api/src/modules/moderation/moderation.service.ts
- [X] T126 [P] Implement ModerationController (POST /reports, POST/DELETE/GET /blocks) in api/src/modules/moderation/moderation.controller.ts
- [X] T127 Build report/block UI (report dialog, block confirmation, blocked users list) in mobile/lib/shared/widgets/report_block_ui.dart
- [X] T128 [P] Write E2E test for full swap flow (register → list → swipe → match → negotiate → confirm → rate) in api/test/e2e/swap-flow.e2e-spec.ts
- [X] T129 [P] Write Flutter integration test for core user journey in mobile/integration_test/swap_flow_test.dart
- [X] T130 Add Redis caching layer to discovery feed queries in api/src/modules/discovery/discovery.service.ts
- [X] T131 [P] Add Swagger API documentation decorators to all module DTOs in api/src/modules/
- [X] T132 Security audit: validate all inputs, sanitize chat content, enforce authorization on all endpoints
- [X] T133 Run quickstart.md validation and update documentation
- [X] T134 Run WCAG 2.1 AA accessibility audit on all Flutter screens (semantic labels, contrast ratios, touch target sizes ≥48dp, screen reader compatibility) in mobile/lib/
- [X] T135 [P] Write integration tests for Items + Discovery modules (CRUD → PostGIS feed query round-trip with real DB) in api/test/integration/
- [X] T136 [P] Write integration tests for Matching + Counter-Offers modules (swipe → match → negotiate → confirm round-trip) in api/test/integration/
- [X] T137 [P] Write integration tests for Chat module (REST message + WebSocket event delivery) in api/test/integration/
- [X] T138 Configure k6 load tests for discovery feed (<2s), API p95 (<500ms), and chat delivery (<300ms); integrate performance budgets in CI pipeline
- [X] T139 Configure memory profiling (Node.js --inspect heap snapshots, Flutter DevTools memory tab) and document baseline thresholds for release gate

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Setup — **BLOCKS all user stories**
- **US1 (Phase 3)**: Depends on Phase 2 — no story dependencies
- **US2 (Phase 4)**: Depends on Phase 2 + items from US1 must exist in DB (can seed)
- **US3 (Phase 5)**: Depends on Phase 2 + discovery/like from US2
- **US5 (Phase 6)**: Depends on Phase 2 — no story dependencies (independent)
- **US4 (Phase 7)**: Depends on Phase 2 + matches from US3
- **US6 (Phase 8)**: Depends on Phase 2 + matches from US3
- **US7 (Phase 9)**: Depends on Phase 2 + items from US1 + auth from Phase 2
- **US8 (Phase 10)**: Depends on Phase 2 + discovery from US2
- **US9 (Phase 11)**: Depends on Phase 2 + completed swaps from US3/US4
- **US10 (Phase 12)**: Depends on Phase 2 — no strict story dependencies
- **Polish (Phase 13)**: Depends on all desired stories being complete

### User Story Dependencies

```text
Phase 2 (Foundational)
  ├── US1 (Item Listing)         ← can start immediately after Phase 2
  │     └── US2 (Discovery)      ← needs items to exist
  │           └── US3 (Matching)  ← needs likes/swipes
  │                 ├── US4 (Counter-Offers)  ← needs matches
  │                 ├── US6 (Chat)            ← needs matches
  │                 └── US9 (Ratings)         ← needs completed swaps
  ├── US5 (Profile)              ← independent, can parallelize with US1
  ├── US7 (Verification)         ← independent, can parallelize with US1
  ├── US8 (Filtering)            ← needs discovery to exist
  └── US10 (Gamification)        ← independent, can parallelize with US1
```

### Within Each User Story

1. Tests MUST be written FIRST and verified to FAIL before implementation (TDD per Constitution)
2. DTOs → Service → Controller (backend)
3. Models → Repository → Provider → Screens (mobile)
4. Story complete and independently testable before moving to next priority

### Parallel Opportunities per Phase

**Phase 1**: T003, T004, T005, T006, T007 all in parallel  
**Phase 2**: T010-T016 (backend core) in parallel; T018-T022 (mobile core) in parallel  
**Phase 3**: T024+T025 (tests) in parallel; T029+T030 (models/repo) in parallel  
**Phase 4**: T040, T043, T044 in parallel  
**Phase 5**: T046+T047 (tests) in parallel; T055 (model) parallel with backend  
**Phase 8**: T082+T083 (tests) in parallel; T088 (model) parallel with backend  

---

## Parallel Example: US1 (Item Listing)

```text
# Step 1: Tests first (parallel)
T024: Unit tests for ItemsService       ← can run in parallel
T025: Unit tests for ItemsController    ← can run in parallel

# Step 2: Backend (sequential)
T026: DTOs
T027: Service (depends on T026)
T028: Controller (depends on T027)

# Step 3: Mobile (parallel start, then sequential)
T029: Item model        ← parallel with T030
T030: Items repository  ← parallel with T029
T031: Items provider (depends on T030)
T032: Add Item screen (depends on T031)
T033: Closet screen (depends on T031)     ← parallel with T032 (different file)
T034: Edit Item screen (depends on T031)  ← parallel with T032 (different file)

# Step 4: Mobile tests
T035: Widget tests
```

---

## Implementation Strategy

### MVP First (US1 + US2 + US3)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks everything)
3. Complete Phase 3: US1 — Item Listing
4. Complete Phase 4: US2 — Swipe Discovery
5. Complete Phase 5: US3 — Double Match
6. **STOP and VALIDATE**: Test full core loop independently
7. Deploy/demo if ready — this is the MVP

### Incremental Delivery

| Increment | Stories | What It Delivers | Cumulative |
|-----------|---------|-------------------|------------|
| MVP | US1 + US2 + US3 | List → Swipe → Match → Confirm | Core swap loop |
| v1.1 | + US5. US4, US6 | Profiles, negotiation, chat | Full social swap |
| v1.2 | + US7, US8 | Trust badges, filtering | Quality + efficiency |
| v1.3 | + US9, US10 | Ratings, gamification | Retention + community |
| v1.4 | + Polish | Moderation, E2E tests, perf | Production-ready |

### Solo Developer Strategy

1. Complete Setup + Foundational together
2. Work sequentially: US1 → US2 → US3 → US5 → US4 → US6 → US7 → US8 → US9 → US10
3. Each story adds value without breaking previous stories
4. Commit after each task or logical group

---

## Notes

- [P] tasks = different files, no dependencies on concurrent tasks
- [Story] label maps task to specific user story for traceability
- Tests included per Constitution Principle II (TDD NON-NEGOTIABLE)
- Each user story is independently completable and testable at its checkpoint
- Commit after each task or logical group
- Stop at any checkpoint to validate the story independently
- Avoid cross-story dependencies that break independence
