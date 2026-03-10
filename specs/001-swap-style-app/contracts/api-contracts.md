# API Contracts: Swap Style

**Date**: 2026-03-09  
**Source**: [spec.md](spec.md) FRs, [data-model.md](data-model.md), [research.md](research.md)  
**Base URL**: `/api/v1`  
**Auth**: Firebase Auth JWT in `Authorization: Bearer <token>` header (all endpoints except auth)

---

## 1. Auth Module

### POST /auth/register

Create a new user account linked to Firebase Auth.

**Request Body**:
```json
{
  "firebaseIdToken": "string (Firebase ID token from client-side sign-in)",
  "name": "string (2-50 chars)",
  "latitude": 30.0444,
  "longitude": 31.2357
}
```

**Response 201**:
```json
{
  "id": "uuid",
  "name": "string",
  "email": "string",
  "emailVerified": false,
  "phoneVerified": false,
  "createdAt": "ISO8601"
}
```

**Errors**: 400 (validation), 409 (email exists)

### POST /auth/verify-phone

Initiate or confirm phone verification.

**Request Body**:
```json
{
  "phoneNumber": "string (E.164 format, e.g. +201234567890)"
}
```

**Response 200**:
```json
{
  "message": "Verification code sent"
}
```

### POST /auth/verify-phone/confirm

**Request Body**:
```json
{
  "verificationCode": "string (6 digits)"
}
```

**Response 200**:
```json
{
  "phoneVerified": true
}
```

### POST /auth/fcm-token

Update the device FCM token for push notifications.

**Request Body**:
```json
{
  "fcmToken": "string"
}
```

**Response 204**: No content

---

## 2. Users Module

### GET /users/me

Get the authenticated user's full profile.

**Response 200**:
```json
{
  "id": "uuid",
  "name": "string",
  "email": "string",
  "profilePhotoUrl": "string | null",
  "city": "string | null",
  "emailVerified": true,
  "phoneVerified": true,
  "averageRating": 4.5,
  "ratingCount": 12,
  "swapCount": 8,
  "closetCount": 5,
  "streak": {
    "currentCount": 3,
    "longestCount": 14
  },
  "badges": [
    { "name": "first_swap", "displayName": "First Swap!", "iconUrl": "string", "earnedAt": "ISO8601" }
  ],
  "createdAt": "ISO8601"
}
```

### PATCH /users/me

Update the authenticated user's profile.

**Request Body** (all fields optional):
```json
{
  "name": "string (2-50 chars)",
  "latitude": 30.0444,
  "longitude": 31.2357,
  "timezone": "Africa/Cairo"
}
```

**Response 200**: Updated user object (same shape as GET /users/me)

### POST /users/me/profile-photo

Upload or replace the user's profile photo.

**Request Body**: `multipart/form-data` with field `photo` (JPEG/PNG, max 5 MB)

**Response 200**:
```json
{
  "profilePhotoUrl": "string"
}
```

### GET /users/:userId

View another user's public profile.

**Response 200**:
```json
{
  "id": "uuid",
  "name": "string",
  "profilePhotoUrl": "string | null",
  "city": "string | null",
  "emailVerified": true,
  "phoneVerified": true,
  "averageRating": 4.5,
  "ratingCount": 12,
  "swapCount": 8,
  "closetCount": 5,
  "badges": [...],
  "createdAt": "ISO8601"
}
```

### GET /users/:userId/closet

List another user's public closet items.

**Query**: `?page=1&limit=20`

**Response 200**:
```json
{
  "data": [ /* Item objects (see Items module) */ ],
  "meta": { "page": 1, "limit": 20, "total": 5 }
}
```

---

## 3. Items Module

### POST /items

Create a new item listing.

**Request Body**: `multipart/form-data`
```
photos[]:     File[] (1-5 images, JPEG/PNG, max 5 MB each)
category:     enum (Shirt|Hoodie|Pants|Shoes|Jacket|Dress|Accessories|Other)
brand:        string (1-100 chars)
size:         enum (XS|S|M|L|XL|XXL|ONE_SIZE)
condition:    enum (New|LikeNew|Good|Fair)
notes:        string (optional, max 500 chars)
```

**Response 201**:
```json
{
  "id": "uuid",
  "ownerId": "uuid",
  "category": "Shirt",
  "brand": "Nike",
  "size": "M",
  "condition": "Good",
  "notes": null,
  "status": "available",
  "photos": [
    { "id": "uuid", "url": "string", "thumbnailUrl": "string", "sortOrder": 0 }
  ],
  "verification": null,
  "createdAt": "ISO8601"
}
```

**Errors**: 400 (validation — missing required fields, no photos)

### GET /items/me

List the authenticated user's closet.

**Query**: `?page=1&limit=20&status=available`

**Response 200**:
```json
{
  "data": [ /* Item objects */ ],
  "meta": { "page": 1, "limit": 20, "total": 12 }
}
```

### GET /items/:itemId

Get a single item's details.

**Response 200**: Full Item object with photos and verification.

### PATCH /items/:itemId

Update an item's details. Owner-only.

**Request Body** (all fields optional):
```json
{
  "category": "Hoodie",
  "brand": "Adidas",
  "size": "L",
  "condition": "LikeNew",
  "notes": "Barely worn"
}
```

**Response 200**: Updated Item object.  
**Errors**: 403 (not owner), 404

### DELETE /items/:itemId

Remove an item from the closet. Cancels pending matches involving it.

**Response 204**: No content  
**Errors**: 403 (not owner), 404

### POST /items/:itemId/verify

Submit verification checklist for an item. Owner-only.

**Request Body**:
```json
{
  "isWashed": true,
  "noStains": true,
  "noTears": true,
  "noDefects": true,
  "photosAccurate": true
}
```

**Response 200**:
```json
{
  "isVerified": true,
  "verifiedAt": "ISO8601"
}
```

---

## 4. Discovery Module

### GET /discovery/feed

Get the swipe feed (paginated, geospatially filtered).

**Query**:
```
?page=1
&limit=20
&radiusKm=50          (default 50, custom allowed)
&size=M               (optional filter)
&category=Shirt       (optional filter)
```

**Response 200**:
```json
{
  "data": [
    {
      "id": "uuid",
      "ownerId": "uuid",
      "ownerName": "string",
      "ownerPhotoUrl": "string | null",
      "ownerVerified": true,
      "category": "Shirt",
      "brand": "Nike",
      "size": "M",
      "condition": "Good",
      "isVerified": true,
      "distanceKm": 3.2,
      "photos": [
        { "url": "string", "thumbnailUrl": "string" }
      ]
    }
  ],
  "meta": { "page": 1, "limit": 20, "hasMore": true }
}
```

**Logic**:
- Excludes own items
- Excludes already-swiped items
- Excludes items from blocked users
- Ordered by distance (nearest first) via PostGIS `ST_Distance`
- Filtered by `ST_DWithin` for radius

### POST /discovery/swipe

Record a Like or Pass action.

**Request Body**:
```json
{
  "itemId": "uuid",
  "action": "like | pass"
}
```

**Response 200**:
```json
{
  "matched": false
}
```

**Response 200 (match detected)**:
```json
{
  "matched": true,
  "match": {
    "id": "uuid",
    "otherUser": { "id": "uuid", "name": "string", "profilePhotoUrl": "string | null" },
    "myItem": { "id": "uuid", "brand": "string", "thumbnailUrl": "string" },
    "theirItem": { "id": "uuid", "brand": "string", "thumbnailUrl": "string" }
  }
}
```

**Errors**: 400 (already swiped), 404 (item not found)

---

## 5. Matching Module

### GET /matches

List the authenticated user's matches.

**Query**: `?status=pending,negotiating,agreed,awaiting_confirmation&page=1&limit=20`

**Response 200**:
```json
{
  "data": [
    {
      "id": "uuid",
      "otherUser": { "id": "uuid", "name": "string", "profilePhotoUrl": "string | null" },
      "myItem": { "id": "uuid", "brand": "string", "thumbnailUrl": "string" },
      "theirItem": { "id": "uuid", "brand": "string", "thumbnailUrl": "string" },
      "status": "pending",
      "myConfirmed": false,
      "theirConfirmed": false,
      "lastActivityAt": "ISO8601",
      "createdAt": "ISO8601"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 4 }
}
```

### GET /matches/:matchId

Get full match details including counter-offer history.

**Response 200**:
```json
{
  "id": "uuid",
  "userA": { "id": "uuid", "name": "string", "profilePhotoUrl": "string | null" },
  "userB": { "id": "uuid", "name": "string", "profilePhotoUrl": "string | null" },
  "itemA": { /* full item */ },
  "itemB": { /* full item */ },
  "status": "negotiating",
  "myConfirmed": false,
  "theirConfirmed": false,
  "counterOffers": [ /* ordered by round_number */ ],
  "lastActivityAt": "ISO8601",
  "createdAt": "ISO8601"
}
```

### POST /matches/:matchId/confirm

Confirm that the physical swap has been completed (dual confirmation).

**Response 200**:
```json
{
  "status": "awaiting_confirmation | completed",
  "myConfirmed": true,
  "theirConfirmed": false
}
```

If both confirmed → status becomes `completed`, items marked as `swapped`, rating prompts triggered.

### POST /matches/:matchId/cancel

Cancel a match.

**Response 200**:
```json
{
  "status": "canceled"
}
```

---

## 6. Counter-Offers Module

### POST /matches/:matchId/counter-offers

Propose a counter-offer.

**Request Body**:
```json
{
  "offeredItemIds": ["uuid"],
  "requestedItemIds": ["uuid"],
  "monetaryAmount": 50.00
}
```

**Response 201**:
```json
{
  "id": "uuid",
  "matchId": "uuid",
  "proposerId": "uuid",
  "offeredItems": [ /* item summaries */ ],
  "requestedItems": [ /* item summaries */ ],
  "monetaryAmount": 50.00,
  "status": "pending",
  "roundNumber": 1,
  "createdAt": "ISO8601"
}
```

**Errors**: 400 (round limit reached — max 5 per side), 403 (not a participant)

### POST /matches/:matchId/counter-offers/:offerId/accept

Accept a counter-offer. Match moves to `agreed`.

**Response 200**:
```json
{
  "counterOffer": { "id": "uuid", "status": "accepted" },
  "match": { "id": "uuid", "status": "agreed" }
}
```

### POST /matches/:matchId/counter-offers/:offerId/decline

Decline a counter-offer.

**Response 200**:
```json
{
  "id": "uuid",
  "status": "declined"
}
```

---

## 7. Chat Module

### GET /matches/:matchId/messages

Get chat history for a match (paginated, newest first).

**Query**: `?cursor=<messageId>&limit=50`

**Response 200**:
```json
{
  "data": [
    {
      "id": "uuid",
      "senderId": "uuid",
      "content": "Hey, when should we meet?",
      "readAt": "ISO8601 | null",
      "createdAt": "ISO8601"
    }
  ],
  "meta": { "nextCursor": "uuid | null", "limit": 50 }
}
```

### POST /matches/:matchId/messages

Send a chat message (also emitted via WebSocket).

**Request Body**:
```json
{
  "content": "string (1-2000 chars)"
}
```

**Response 201**: Message object.

### PATCH /matches/:matchId/messages/read

Mark all messages in a match as read up to a given point.

**Request Body**:
```json
{
  "upToMessageId": "uuid"
}
```

**Response 204**: No content.

### WebSocket: `/ws/chat`

**Connection**: `wss://host/ws/chat?token=<jwt>`

**Client → Server events**:
- `join_match` `{ matchId: "uuid" }` — join a match's chat room
- `leave_match` `{ matchId: "uuid" }` — leave a match's chat room
- `send_message` `{ matchId: "uuid", content: "string" }`
- `typing` `{ matchId: "uuid" }`

**Server → Client events**:
- `new_message` `{ id, matchId, senderId, content, createdAt }`
- `message_read` `{ matchId, readerId, upToMessageId }`
- `user_typing` `{ matchId, userId }`

---

## 8. Notifications Module

### GET /notifications

List the user's notifications.

**Query**: `?page=1&limit=20&unreadOnly=false`

**Response 200**:
```json
{
  "data": [
    {
      "id": "uuid",
      "type": "match | message | counter_offer | swap_completed | match_expiry_warning | match_expired | rating_prompt",
      "title": "New Match!",
      "body": "You matched with Ahmed on Nike Hoodie",
      "referenceId": "uuid (match/message ID)",
      "readAt": "ISO8601 | null",
      "createdAt": "ISO8601"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 15, "unreadCount": 3 }
}
```

### PATCH /notifications/:notificationId/read

Mark a notification as read.

**Response 204**: No content.

---

## 9. Ratings Module

### POST /matches/:matchId/rating

Rate a swap partner after completion.

**Request Body**:
```json
{
  "stars": 5,
  "comment": "Great swap, item was exactly as described!"
}
```

**Response 201**:
```json
{
  "id": "uuid",
  "matchId": "uuid",
  "raterId": "uuid",
  "ratedUserId": "uuid",
  "stars": 5,
  "comment": "Great swap, item was exactly as described!",
  "createdAt": "ISO8601"
}
```

**Errors**: 400 (match not completed), 409 (already rated)

### GET /users/:userId/ratings

List ratings received by a user.

**Query**: `?page=1&limit=20`

**Response 200**:
```json
{
  "data": [
    {
      "id": "uuid",
      "raterName": "string",
      "raterPhotoUrl": "string | null",
      "stars": 5,
      "comment": "string | null",
      "createdAt": "ISO8601"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 12 }
}
```

---

## 10. Gamification Module

### GET /gamification/streaks

Get the authenticated user's streak info.

**Response 200**:
```json
{
  "currentCount": 7,
  "longestCount": 14,
  "lastActivityDate": "2026-03-09"
}
```

### GET /gamification/badges

List all available badges with the user's earning status.

**Response 200**:
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "first_swap",
      "displayName": "First Swap!",
      "description": "Complete your first clothing swap",
      "iconUrl": "string",
      "criteriaType": "swap_count",
      "criteriaValue": 1,
      "earned": true,
      "earnedAt": "ISO8601 | null"
    }
  ]
}
```

---

## 11. Moderation Module

### POST /reports

File a report against a user or item.

**Request Body**:
```json
{
  "reportedUserId": "uuid (optional, one required)",
  "reportedItemId": "uuid (optional, one required)",
  "reason": "string (10-500 chars)"
}
```

**Response 201**:
```json
{
  "id": "uuid",
  "status": "pending",
  "createdAt": "ISO8601"
}
```

### POST /blocks

Block a user. Cancels active matches and disables chat.

**Request Body**:
```json
{
  "blockedUserId": "uuid"
}
```

**Response 201**:
```json
{
  "id": "uuid",
  "blockedUserId": "uuid",
  "createdAt": "ISO8601"
}
```

**Side effects**: All active matches with the blocked user are canceled. Blocked user's items excluded from blocker's feed.

### DELETE /blocks/:blockedUserId

Unblock a user.

**Response 204**: No content.

### GET /blocks

List all blocked users.

**Response 200**:
```json
{
  "data": [
    {
      "blockedUserId": "uuid",
      "blockedUserName": "string",
      "blockedAt": "ISO8601"
    }
  ]
}
```

---

## 12. Wishlist Module

### GET /wishlist

List the authenticated user's wishlist entries.

**Response 200**:
```json
{
  "data": [
    {
      "id": "uuid",
      "category": "Hoodie",
      "size": "L",
      "brand": "Nike",
      "createdAt": "ISO8601"
    }
  ]
}
```

### POST /wishlist

Add a wishlist entry.

**Request Body**:
```json
{
  "category": "Hoodie",
  "size": "L",
  "brand": "Nike"
}
```

**Response 201**: Wishlist entry object.

### DELETE /wishlist/:entryId

Remove a wishlist entry.

**Response 204**: No content.

---

## Common Patterns

### Pagination

All list endpoints use offset-based pagination (or cursor-based for chat):
```json
{
  "data": [...],
  "meta": { "page": 1, "limit": 20, "total": 100 }
}
```

### Error Response Format

```json
{
  "statusCode": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "details": [
    { "field": "brand", "message": "Brand is required" }
  ]
}
```

### HTTP Status Codes

| Code | Usage |
|------|-------|
| 200 | Success (read/update) |
| 201 | Resource created |
| 204 | Success, no body (delete, mark-read) |
| 400 | Validation error |
| 401 | Missing/invalid JWT |
| 403 | Forbidden (not owner, not participant) |
| 404 | Resource not found |
| 409 | Conflict (duplicate) |
| 429 | Rate limited |
