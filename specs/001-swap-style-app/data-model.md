# Data Model: Swap Style

**Date**: 2026-03-09  
**Source**: [spec.md](spec.md) entities + [research.md](research.md) technical decisions

## Entity Relationship Overview

```text
User ──────┬── owns ──────── Item (1:N)
           ├── creates ───── Like (1:N)
           ├── participates ─ Match (N:M via Match)
           ├── proposes ──── CounterOffer (1:N)
           ├── sends ─────── Message (1:N)
           ├── gives ─────── Rating (1:N)
           ├── has ────────── Streak (1:1)
           ├── earns ─────── Badge (N:M via UserBadge)
           ├── files ─────── Report (1:N)
           └── blocks ────── Block (1:N, directional)

Item ──────┬── receives ──── Like (1:N)
           └── involved in ── Match (via item_a / item_b)

Match ─────┬── has ────────── CounterOffer (1:N)
           ├── has ────────── Chat (1:1, implicit via match_id)
           └── triggers ───── Rating (1:N, after completion)
```

## Entities

### User

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| email | String | UNIQUE, NOT NULL | Used for login + verification |
| name | String | NOT NULL | Display name |
| profile_photo_url | String | NULLABLE | S3/R2 URL |
| location | Geography(Point) | NOT NULL | PostGIS POINT for geospatial queries |
| city | String | NULLABLE | Derived from geocoding for display |
| email_verified | Boolean | NOT NULL, DEFAULT false | |
| phone_verified | Boolean | NOT NULL, DEFAULT false | |
| phone_number | String | NULLABLE | For phone verification |
| firebase_uid | String | UNIQUE, NOT NULL | Firebase Auth UID |
| fcm_token | String | NULLABLE | Firebase Cloud Messaging device token |
| timezone | String | NOT NULL, DEFAULT 'UTC' | IANA timezone (e.g., 'Africa/Cairo') for streak reset |
| created_at | Timestamp | NOT NULL, DEFAULT now() | |
| updated_at | Timestamp | NOT NULL, auto-updated | |

**Computed/derived** (not stored directly):
- `average_rating`: AVG of received Rating.stars
- `rating_count`: COUNT of received Ratings
- `swap_count`: COUNT of completed Matches
- `closet_count`: COUNT of available Items

### Item

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| owner_id | UUID | FK → User.id, NOT NULL | |
| category | Enum | NOT NULL | Shirt, Hoodie, Pants, Shoes, Jacket, Dress, Accessories, Other |
| brand | String | NOT NULL | |
| size | Enum | NOT NULL | XS, S, M, L, XL, XXL, ONE_SIZE |
| condition | Enum | NOT NULL | New, Like New, Good, Fair |
| notes | String | NULLABLE | Optional personal notes |
| status | Enum | NOT NULL, DEFAULT 'available' | available, swapped, removed |
| location | Geography(Point) | NOT NULL | Copied from owner at listing time for query efficiency |
| created_at | Timestamp | NOT NULL, DEFAULT now() | |
| updated_at | Timestamp | NOT NULL, auto-updated | |

### ItemPhoto

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| item_id | UUID | FK → Item.id, NOT NULL | CASCADE DELETE |
| url | String | NOT NULL | S3/R2 full URL |
| thumbnail_url | String | NOT NULL | Generated thumbnail URL |
| sort_order | Integer | NOT NULL, DEFAULT 0 | Display ordering |
| created_at | Timestamp | NOT NULL, DEFAULT now() | |

Constraint: Each Item MUST have at least 1 photo (enforced at application layer).

### ItemVerification

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| item_id | UUID | FK → Item.id, UNIQUE, NOT NULL | 1:1 with Item |
| is_washed | Boolean | NOT NULL, DEFAULT false | |
| no_stains | Boolean | NOT NULL, DEFAULT false | |
| no_tears | Boolean | NOT NULL, DEFAULT false | |
| no_defects | Boolean | NOT NULL, DEFAULT false | |
| photos_accurate | Boolean | NOT NULL, DEFAULT false | |
| verified_at | Timestamp | NULLABLE | Set when all checks confirmed |

**Derived**: `is_verified` = all boolean fields are true AND `verified_at` IS NOT NULL.

### Like

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| liker_id | UUID | FK → User.id, NOT NULL | The user who swiped |
| item_id | UUID | FK → Item.id, NOT NULL | The item swiped on |
| is_like | Boolean | NOT NULL | true = Like (right), false = Pass (left) |
| created_at | Timestamp | NOT NULL, DEFAULT now() | |

Constraint: UNIQUE(liker_id, item_id) — a user can only swipe once per item.

### Match

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| user_a_id | UUID | FK → User.id, NOT NULL | First user in the match |
| user_b_id | UUID | FK → User.id, NOT NULL | Second user in the match |
| item_a_id | UUID | FK → Item.id, NOT NULL | User A's item liked by User B |
| item_b_id | UUID | FK → Item.id, NOT NULL | User B's item liked by User A |
| status | Enum | NOT NULL, DEFAULT 'pending' | pending, negotiating, agreed, awaiting_confirmation, completed, canceled, expired |
| user_a_confirmed | Boolean | NOT NULL, DEFAULT false | Dual confirmation: User A confirmed physical swap |
| user_b_confirmed | Boolean | NOT NULL, DEFAULT false | Dual confirmation: User B confirmed physical swap |
| last_activity_at | Timestamp | NOT NULL, DEFAULT now() | Updated on any action (chat, offer, confirm) |
| expired_at | Timestamp | NULLABLE | Set when match expires |
| completed_at | Timestamp | NULLABLE | Set when both users confirm |
| created_at | Timestamp | NOT NULL, DEFAULT now() | |

Constraint: UNIQUE(user_a_id, user_b_id, item_a_id, item_b_id) — no duplicate matches for same item pair.

**State Transitions**:
```text
pending → negotiating (first counter-offer proposed)
pending → agreed (both accept original match)
negotiating → agreed (counter-offer accepted)
negotiating → canceled (user abandons)
agreed → awaiting_confirmation (first user confirms physical swap)
awaiting_confirmation → completed (second user confirms)
any active → canceled (user cancels, blocks, or item removed)
any active → expired (14 days inactivity)
```

### CounterOffer

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| match_id | UUID | FK → Match.id, NOT NULL | |
| proposer_id | UUID | FK → User.id, NOT NULL | Who proposed this offer |
| monetary_amount | Decimal(10,2) | NULLABLE, DEFAULT NULL | Optional monetary difference |
| status | Enum | NOT NULL, DEFAULT 'pending' | pending, accepted, declined, superseded |
| round_number | Integer | NOT NULL | 1-based; max 5 per side, 10 total |
| created_at | Timestamp | NOT NULL, DEFAULT now() | |

Constraint: round_number ≤ 5 per proposer per match (enforced at application layer).

### CounterOfferItem

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| counter_offer_id | UUID | FK → CounterOffer.id, NOT NULL | CASCADE DELETE |
| item_id | UUID | FK → Item.id, NOT NULL | |
| direction | Enum | NOT NULL | offered (proposer gives), requested (proposer wants) |

### Message

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| match_id | UUID | FK → Match.id, NOT NULL | Conversation scoped to match |
| sender_id | UUID | FK → User.id, NOT NULL | |
| content | String | NOT NULL | Text content (max 2000 chars) |
| read_at | Timestamp | NULLABLE | NULL = unread by recipient |
| created_at | Timestamp | NOT NULL, DEFAULT now() | |

Index: (match_id, created_at) for paginated history loading.

### Rating

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| match_id | UUID | FK → Match.id, NOT NULL | Which swap this rates |
| rater_id | UUID | FK → User.id, NOT NULL | Who is rating |
| rated_user_id | UUID | FK → User.id, NOT NULL | Who is being rated |
| stars | Integer | NOT NULL, CHECK 1-5 | |
| comment | String | NULLABLE | Optional text feedback |
| created_at | Timestamp | NOT NULL, DEFAULT now() | |

Constraint: UNIQUE(match_id, rater_id) — one rating per user per swap.

### Streak

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| user_id | UUID | FK → User.id, UNIQUE, NOT NULL | 1:1 with User |
| current_count | Integer | NOT NULL, DEFAULT 0 | Current consecutive day count |
| longest_count | Integer | NOT NULL, DEFAULT 0 | All-time best streak |
| last_activity_date | Date | NULLABLE | Date of last qualifying activity (in user's timezone) |
| updated_at | Timestamp | NOT NULL, auto-updated | |

### Badge

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| name | String | UNIQUE, NOT NULL | e.g., 'first_swap', 'streak_7', 'streak_30' |
| display_name | String | NOT NULL | Human-readable: "First Swap!", "7-Day Streak" |
| description | String | NOT NULL | What the user did to earn it |
| icon_url | String | NOT NULL | Badge icon asset URL |
| criteria_type | Enum | NOT NULL | swap_count, streak_days, rating_count |
| criteria_value | Integer | NOT NULL | Threshold to earn (e.g., 1, 7, 30) |

### UserBadge

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| user_id | UUID | FK → User.id, NOT NULL | |
| badge_id | UUID | FK → Badge.id, NOT NULL | |
| earned_at | Timestamp | NOT NULL, DEFAULT now() | |

Constraint: UNIQUE(user_id, badge_id) — earn each badge once.

### Report

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| reporter_id | UUID | FK → User.id, NOT NULL | |
| reported_user_id | UUID | FK → User.id, NULLABLE | If reporting a user |
| reported_item_id | UUID | FK → Item.id, NULLABLE | If reporting an item |
| reason | String | NOT NULL | Free-text reason |
| status | Enum | NOT NULL, DEFAULT 'pending' | pending, reviewed, resolved |
| created_at | Timestamp | NOT NULL, DEFAULT now() | |
| resolved_at | Timestamp | NULLABLE | |

Constraint: CHECK(reported_user_id IS NOT NULL OR reported_item_id IS NOT NULL) — must report something.

### Block

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| blocker_id | UUID | FK → User.id, NOT NULL | The user who blocks |
| blocked_id | UUID | FK → User.id, NOT NULL | The user being blocked |
| created_at | Timestamp | NOT NULL, DEFAULT now() | |

Constraint: UNIQUE(blocker_id, blocked_id) — can only block once.

### Notification

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| user_id | UUID | FK → User.id, NOT NULL | Recipient |
| type | Enum | NOT NULL | match, message, counter_offer, swap_completed, match_expiry_warning, match_expired, rating_prompt |
| title | String | NOT NULL | Notification heading |
| body | String | NOT NULL | Notification detail text |
| reference_id | UUID | NULLABLE | ID of related entity (match, message, etc.) |
| read_at | Timestamp | NULLABLE | NULL = unread |
| created_at | Timestamp | NOT NULL, DEFAULT now() | |

Index: (user_id, read_at) for unread notification queries.

### WishlistEntry

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID | PK, auto-generated | |
| user_id | UUID | FK → User.id, NOT NULL | |
| category | Enum | NULLABLE | Desired category |
| size | Enum | NULLABLE | Desired size |
| brand | String | NULLABLE | Desired brand |
| created_at | Timestamp | NOT NULL, DEFAULT now() | |

## Database Indexes

| Table | Index | Type | Purpose |
|-------|-------|------|---------|
| Item | (location) | GIST | Geospatial radius queries for swipe feed |
| Item | (owner_id, status) | B-tree | Closet listing for a user |
| Item | (size, category, status) | B-tree | Filter queries combined with spatial |
| Like | (liker_id, item_id) | UNIQUE B-tree | Prevent duplicate swipes |
| Like | (item_id, is_like) | B-tree | Match detection: find who liked an item |
| Match | (user_a_id, status) | B-tree | User's active matches |
| Match | (user_b_id, status) | B-tree | User's active matches (other side) |
| Match | (status, last_activity_at) | B-tree | Expiry job: find stale matches |
| Message | (match_id, created_at) | B-tree | Chat history pagination |
| Message | (match_id, sender_id, read_at) | B-tree | Unread message count |
| Rating | (rated_user_id) | B-tree | Average rating calculation |
| Block | (blocker_id, blocked_id) | UNIQUE B-tree | Block lookup during feed/match |
| Notification | (user_id, read_at) | B-tree | Unread notification list |
