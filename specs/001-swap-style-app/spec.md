# Feature Specification: Swap Style — Community Clothing Swap Platform

**Feature Branch**: `001-swap-style-app`  
**Created**: 2026-03-09  
**Status**: Draft  
**Input**: User description: "Swap Style — a community-driven mobile application for clothing swaps, focusing on sustainability and circular fashion. Features swipe discovery, double matching, counter-offers, item listings, verification & trust, user profiles, smart filtering, gamification, and built-in chat."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Item Listing & Closet Management (Priority: P1)

As a user, I want to list clothing items in my closet so that other users can discover and express interest in swapping with me. I open the "Add Item" screen, upload one or more photos, select a category (Shirt, Hoodie, Shoes, etc.), enter the brand name, pick the size, describe the condition, and optionally add personal notes. Once published, the item appears in my "Closet" on my profile and becomes visible to nearby users in the swipe feed.

**Why this priority**: Without items in the system, no other feature (swiping, matching, trading) can function. Item listing is the foundational data entry point for the entire platform.

**Independent Test**: Can be fully tested by creating an account, listing one or more items, and confirming they appear in the user's closet and in the discovery feed for nearby users.

**Acceptance Scenarios**:

1. **Given** a registered user on the Add Item screen, **When** they upload at least one photo, select a category, enter brand, pick size, select condition, and tap "Publish," **Then** the item is saved and visible in their Closet.
2. **Given** a user listing an item, **When** they omit any required field (photo, category, size, condition), **Then** the system highlights the missing field and prevents submission.
3. **Given** a user with a published item, **When** another user in the same area opens the swipe feed, **Then** the published item appears as a swipeable card.
4. **Given** a user viewing their Closet, **When** they tap an item, **Then** they can edit or remove it at any time.

---

### User Story 2 — Swipe Discovery (Priority: P1)

As a user, I want to swipe through clothing items posted by nearby users so I can quickly browse and express interest in pieces I like. The home screen shows one item card at a time with photos, category, brand, size, condition, and distance. I swipe right to "Like" or left to "Pass."

**Why this priority**: The swipe-based discovery mechanic is the core interaction loop and the primary way users engage with the platform daily. Without it, there is no pathway to matching.

**Independent Test**: Can be tested by listing items from multiple test accounts in the same area, then swiping through them on a different account to verify cards render correctly and swipe actions are recorded.

**Acceptance Scenarios**:

1. **Given** a user on the home screen with items available in their area, **When** the feed loads, **Then** item cards display photos, category, brand, size, condition, and approximate distance.
2. **Given** a user viewing an item card, **When** they swipe right, **Then** the item is recorded as "Liked" and the next card appears.
3. **Given** a user viewing an item card, **When** they swipe left, **Then** the item is recorded as "Passed" and the next card appears.
4. **Given** a user who has swiped through all available items, **When** no more items remain, **Then** a friendly "No more items nearby" message is shown with a prompt to adjust filters.
5. **Given** a user with active filters (size, location radius), **When** the feed loads, **Then** only items matching those filters appear.

---

### User Story 3 — Double Match & Match Notification (Priority: P1)

As a user, I want to be notified when a mutual "double match" occurs — meaning I liked an item from another user's closet and they liked an item from mine — so we can proceed to negotiate a swap.

**Why this priority**: The double-match mechanic is the unique value proposition of Swap Style. It ensures both parties have expressed genuine interest before enabling communication, which drives trust and swap completion.

**Independent Test**: Can be tested by having User A like an item from User B and User B like an item from User A, then verifying both receive a match notification with the matched items displayed.

**Acceptance Scenarios**:

1. **Given** User A has liked an item from User B and User B has liked an item from User A, **When** the second like is registered, **Then** both users receive a "Match" notification showing the two matched items.
2. **Given** a match notification, **When** a user taps it, **Then** they are taken to the match detail screen showing both items and an option to open chat.
3. **Given** User A has liked an item from User B but User B has not liked any of User A's items, **When** time passes, **Then** no match notification is sent and User A is not informed of the one-sided like.
4. **Given** a match with no activity for 13 days, **When** the 24-hour warning threshold is reached, **Then** both users receive a notification that the match will expire in 24 hours unless activity occurs.
5. **Given** a match that has been inactive for 14 days, **When** the expiry threshold is reached, **Then** the match is automatically canceled, both users are notified, and the items are released back into the swipe feed.

---

### User Story 4 — Counter-Offer System (Priority: P2)

As a user who has matched with another user, I want to propose a counter-offer to make the trade fair — for example, offering two items for one or adding a small monetary difference — so that both parties feel the swap is equitable.

**Why this priority**: Fair trading is essential for user retention. Without a counter-offer mechanism, users with items of differing perceived value would abandon the platform.

**Independent Test**: Can be tested after a match by one user proposing a counter-offer (e.g., adding a second item or a monetary amount), the other user reviewing, accepting, or declining it.

**Acceptance Scenarios**:

1. **Given** a confirmed match, **When** a user opens the match detail, **Then** they see an option to "Propose Counter-Offer."
2. **Given** a user proposing a counter-offer, **When** they add additional items from their closet or enter a monetary amount, **Then** the counter-offer is sent to the other user for review.
3. **Given** a received counter-offer, **When** the recipient reviews it, **Then** they can accept, decline, or propose a revised counter-offer.
4. **Given** both users accept an offer (original or counter), **When** the acceptance is confirmed, **Then** the swap is marked as "Agreed" and a chat opens automatically.
5. **Given** a counter-offer is declined, **When** the original proposer sees the decline, **Then** they can propose a new offer or abandon the swap.
6. **Given** an agreed swap, **When** both users meet and exchange items, **Then** each user independently confirms completion in the app; the swap is marked "Completed" only after both confirmations are received.
7. **Given** a user has already sent 5 counter-offers in a match, **When** they attempt to send another, **Then** the system prevents it and prompts them to accept the last offer or abandon the swap.

---

### User Story 5 — User Registration & Profile (Priority: P2)

As a new user, I want to create an account and set up my profile so I can participate in the Swap Style community. My profile displays my Closet (current items), Swap History (completed trades), Wishlist (desired categories/sizes), and my community rating.

**Why this priority**: Profiles provide identity, trust signals, and organizational structure for the user's items and activity. Users need accounts before any interaction, but the profile richness (history, wishlist, ratings) is iterative.

**Independent Test**: Can be tested by registering a new account, completing the profile setup, and verifying all profile sections (Closet, Swap History, Wishlist, Rating) render correctly, even when empty.

**Acceptance Scenarios**:

1. **Given** a new user, **When** they open the app for the first time, **Then** they are guided through registration (name, email, profile photo, location).
2. **Given** a registered user, **When** they visit their profile, **Then** they see their Closet, Swap History, Wishlist, and Rating sections.
3. **Given** a user with no completed swaps, **When** they view Swap History, **Then** a friendly empty state is shown with encouragement to start swiping.
4. **Given** a user viewing another user's profile, **When** they open it, **Then** they see that user's public Closet, Rating, and Swap History count (not details).

---

### User Story 6 — Built-in Chat (Priority: P2)

As a matched user, I want to chat with my swap partner to discuss trade details, meeting points, and confirm the swap, all within the app.

**Why this priority**: Communication is essential to convert matches into completed swaps. Without in-app chat, users would need to exchange personal contact information, reducing trust and safety.

**Independent Test**: Can be tested by creating a match between two users and verifying a chat thread opens, messages send and receive in real-time, and the conversation persists across sessions.

**Acceptance Scenarios**:

1. **Given** a confirmed match, **When** either user opens the match, **Then** a chat interface is available.
2. **Given** two matched users in a chat, **When** one sends a text message, **Then** the other receives it in real-time.
3. **Given** a chat thread, **When** a user leaves and returns to the app, **Then** the full conversation history is preserved.
4. **Given** a user receives a new chat message while the app is in the background, **Then** they receive a push notification.

---

### User Story 7 — Verification & Trust System (Priority: P2)

As a user, I want item verification checklists and user account verification so I can trust the quality of items and the authenticity of the people I'm swapping with.

**Why this priority**: Trust is the backbone of peer-to-peer trading. Verified items and users reduce disputes and encourage more swaps.

**Independent Test**: Can be tested by a user completing the item verification checklist during listing (confirming washed, no defects, etc.) and completing user verification (email confirmed, phone confirmed), then checking that verification badges appear on items and profiles.

**Acceptance Scenarios**:

1. **Given** a user listing an item, **When** they reach the verification step, **Then** they see a checklist (washed, no stains, no tears, no defects, photos match actual condition) and must confirm each applicable item.
2. **Given** an item with a completed verification checklist, **When** other users view it in the swipe feed, **Then** a "Verified" badge is displayed on the item card.
3. **Given** a new user, **When** they complete account verification (email confirmation and phone verification), **Then** a "Verified User" badge appears on their profile.
4. **Given** a user viewing another user's profile, **When** they check the trust indicators, **Then** they see the verification badge status and community rating.

---

### User Story 8 — Smart Filtering (Priority: P3)

As a user, I want to filter the swipe feed by size and location (city or radius) so I only see items that are practical for me to swap.

**Why this priority**: Filters improve efficiency and user satisfaction by eliminating irrelevant items. However, the app is functional without them (users can still browse all nearby items), making this a quality-of-life enhancement.

**Independent Test**: Can be tested by setting filters (e.g., size M, within 10 km) and verifying the swipe feed only shows items matching those criteria.

**Acceptance Scenarios**:

1. **Given** a user on the swipe feed, **When** they tap the filter icon, **Then** a filter panel appears with options for Size and Location (city or radius).
2. **Given** a user who sets size filter to "M" and location to "within 15 km," **When** the feed refreshes, **Then** only size M items within 15 km are displayed.
3. **Given** a user with active filters, **When** no items match, **Then** a message suggests broadening filter criteria.
4. **Given** a user who clears all filters, **When** the feed refreshes, **Then** all items within the default 50 km radius are shown.
5. **Given** a user who wants items beyond 50 km, **When** they manually set a custom radius (e.g., 100 km), **Then** the feed expands to show items within the custom radius.

---

### User Story 9 — Rating System (Priority: P3)

As a user who completed a swap, I want to rate my swap partner so the community can identify trustworthy traders and hold bad actors accountable.

**Why this priority**: Ratings build long-term trust and community health, but they only apply after swaps are completed, making them dependent on earlier features.

**Independent Test**: Can be tested by completing a swap between two users, then having each rate the other and verifying ratings appear on profiles.

**Acceptance Scenarios**:

1. **Given** both users have independently confirmed the swap in the app, **When** the swap status transitions to "Completed," **Then** both users receive a prompt to rate their swap partner (1-5 stars plus optional comment).
2. **Given** a user submitting a rating, **When** they select stars and optionally add a comment, **Then** the rating is saved and reflected in the partner's profile average.
3. **Given** a user who has not yet rated after a swap, **When** they open the app, **Then** a gentle reminder appears to complete the rating.

---

### User Story 10 — Gamification & Streaks (Priority: P3)

As an active user, I want to earn streaks and rewards for regular engagement (daily swiping, completed swaps) so I feel motivated to keep using the app.

**Why this priority**: Gamification drives retention and daily active usage, but the app delivers core value without it. This is an engagement layer built on top of functional swap mechanics.

**Independent Test**: Can be tested by a user swiping daily for consecutive days and verifying streak counters increment, and by completing swaps and checking that reward badges appear.

**Acceptance Scenarios**:

1. **Given** a user who swipes at least once per day for 3 consecutive days, **When** they open the app on day 3, **Then** they see a "3-day streak" indicator.
2. **Given** a user with an active streak, **When** they miss a day, **Then** the streak resets to zero with a friendly "Start again!" message.
3. **Given** a user who completes their first swap, **When** the swap is confirmed, **Then** they earn a "First Swap" achievement badge visible on their profile.
4. **Given** a user viewing their profile, **When** they check the gamification section, **Then** they see their current streak, total swaps, and any earned badges.

---

### Edge Cases

- What happens when a user tries to swap an item that has already been swapped (removed from closet)? The item must be automatically removed from all other users' feeds and any pending matches involving it must be canceled with notification.
- How does the system handle a user who creates an account but lists zero items? They can browse and like items, but matches cannot occur until they have at least one item listed. A prompt encourages them to list their first item.
- What happens when two users match but one deletes their account before chatting? The remaining user is notified that the match is no longer available.
- How does the system handle inappropriate or fraudulent item listings? A reporting mechanism allows users to flag items; flagged items are hidden pending review.
- What happens when a user's location changes significantly (e.g., moves to a new city)? Filters and feed update automatically based on current location. Previous matches and chats remain accessible.
- How does the system handle simultaneous counter-offers from both users? The system timestamps offers; the most recent offer is displayed and the earlier one is marked as superseded.
- What happens when a user blocks someone they have an active match with? The match is canceled, the chat is disabled for the blocker, and both users are notified the match is no longer available (without disclosing the block).
- What happens when a match expires due to inactivity? After 14 days with no chat, counter-offer, or confirmation activity, the match is auto-canceled. Both users are warned 24 hours before expiry. Items return to the swipe feed for new potential matches.

## Clarifications

### Session 2026-03-09

- Q: How is a physical swap confirmed as "completed" in the app? → A: Both users must independently confirm the swap is completed (dual confirmation).
- Q: Can users block other users, and what happens when they do? → A: Full block — blocked user's items hidden from feed, cannot match, existing chats disabled.
- Q: Should there be a maximum number of counter-offer rounds per match? → A: Maximum 5 counter-offers per side (10 total rounds), then must accept or abandon.
- Q: What should the default discovery radius be when no location filter is set? → A: Default 50 km; users can manually set a custom radius beyond 50 km.
- Q: Should matches expire if no activity occurs within a time window? → A: Expire after 14 days of inactivity; both users notified before expiry.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to register with name, email, profile photo, and location.
- **FR-002**: System MUST allow users to list clothing items with photos (at least one required), category, brand, size, condition, and optional notes.
- **FR-003**: System MUST display a swipe-based discovery feed showing one item card at a time from nearby users.
- **FR-004**: System MUST record "Like" and "Pass" actions when a user swipes right or left respectively.
- **FR-005**: System MUST detect a "Double Match" when User A likes an item from User B AND User B likes an item from User A, and notify both users.
- **FR-006**: System MUST never reveal one-sided likes to either party; only mutual matches are disclosed.
- **FR-007**: System MUST allow matched users to propose counter-offers (additional items or monetary amounts) to balance trade value.
- **FR-008**: System MUST support counter-offer negotiation: propose, accept, decline, or revise. Maximum 5 counter-offers per side (10 total rounds); once the limit is reached, users must accept the last offer or abandon the swap.
- **FR-009**: System MUST provide a real-time chat interface for matched users to discuss swap logistics.
- **FR-010**: System MUST send push notifications for new matches, chat messages, and counter-offer updates.
- **FR-011**: System MUST display user profiles with Closet, Swap History, Wishlist, and community Rating.
- **FR-012**: System MUST provide an item verification checklist during listing (washed, no stains, no tears, no defects, photos accurate).
- **FR-013**: System MUST support user verification (email and phone confirmation) with visual badge indicators.
- **FR-014**: System MUST allow filtering the swipe feed by clothing size, category, and location radius in km. Users can manually adjust from the default radius (defined in FR-020) to a custom value including beyond 50 km.
- **FR-015**: System MUST allow users to rate swap partners (1-5 stars plus optional comment) after a completed swap.
- **FR-016**: System MUST track and display user engagement streaks (consecutive days of activity) and achievement badges.
- **FR-017**: System MUST automatically remove swapped items from the Closet and cancel any pending matches involving those items.
- **FR-018**: System MUST allow users to report inappropriate or fraudulent listings.
- **FR-019**: System MUST allow users to manage a Wishlist of desired categories, sizes, or brands.
- **FR-020**: System MUST use the user's current location to determine which items appear in the swipe feed, with a default discovery radius of 50 km. This is the single source of truth for the default radius; FR-014 filtering builds on top.
- **FR-021**: System MUST allow users to block other users; blocked users' items are hidden from the blocker's feed, new matches are prevented, and existing chats are disabled for the blocker.
- **FR-022**: System MUST automatically expire matches after 14 days of inactivity (no chat messages, no counter-offers, no confirmation actions). Both users MUST be notified 24 hours before expiry. Expired matches release associated items back into the swipe feed.

### Key Entities

- **User**: Represents a registered person on the platform. Key attributes: name, email, profile photo, location, verification status (email/phone), community rating (average stars), streak count, list of achievement badges.
- **Item**: A clothing piece listed for swap. Key attributes: photos, category, brand, size, condition, notes, verification checklist status, owner (User), availability status (available/swapped/removed), listing date.
- **Like**: A record of a user expressing interest in another user's item. Key attributes: liker (User), liked item (Item), timestamp.
- **Match**: Created when a double-like occurs between two users. Key attributes: User A, User B, Item A (from User A's closet liked by B), Item B (from User B's closet liked by A), status (pending/negotiating/agreed/awaiting_confirmation/completed/canceled/expired), creation date, User A confirmation status, User B confirmation status, last activity timestamp.
- **Counter-Offer**: A negotiation proposal within a match. Key attributes: proposer (User), match, offered items (list of Items), requested items (list of Items), monetary amount (optional), status (pending/accepted/declined/superseded), timestamp, round number. Maximum 5 per side (10 total per match).
- **Chat**: A messaging thread between matched users. Key attributes: match, participants, messages (ordered by timestamp).
- **Message**: An individual chat message. Key attributes: sender (User), content, timestamp, read status.
- **Rating**: Post-swap feedback. Key attributes: rater (User), rated user (User), match, stars (1-5), comment (optional), timestamp.
- **Streak**: Tracks consecutive daily engagement. Key attributes: user (User), current streak count, longest streak, last activity date.
- **Badge**: An achievement earned through activity. Key attributes: name, description, criteria, earned date, user (User).
- **Report**: A user-flagged item or account. Key attributes: reporter (User), reported item or user, reason, status (pending/reviewed/resolved), timestamp.
- **Block**: A directional relationship where one user blocks another. Key attributes: blocker (User), blocked (User), timestamp. Effect: blocked user's items excluded from blocker's feed, matching prevented, existing chats disabled for blocker.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can list a new item (with photos, category, brand, size, condition) in under 3 minutes from tapping "Add Item."
- **SC-002**: 80% of active users swipe through at least 10 items per session.
- **SC-003**: Matches resulting in at least one chat message within 24 hours exceed 60%.
- **SC-004**: Users can complete the full swap flow (match → negotiate → agree → confirm) in under 5 interactions on average.
- **SC-005**: App supports at least 5,000 concurrent active users without perceptible degradation in feed loading or chat responsiveness.
- **SC-006**: Swipe feed loads within 2 seconds on a standard 4G connection, even with active filters.
- **SC-007**: At least 70% of completed swaps result in ratings from both parties.
- **SC-008**: Users with 7+ day streaks show 40% higher monthly retention compared to non-streak users.
- **SC-009**: 90% of users who complete account verification (email + phone) report higher trust in swap partners.
- **SC-010**: Fewer than 5% of completed swaps result in dispute reports related to item condition.

## Assumptions

- Users will grant location permissions; the app requires location access to power the proximity-based swipe feed and smart filtering.
- The app targets a single geographic market at launch (one country/region); multi-region expansion is out of scope for v1.
- Monetary amounts in counter-offers are informational agreements between users; the app does not process payments in v1. Users settle monetary differences outside the app.
- Photo upload supports standard mobile camera photos (JPEG/PNG); advanced media like video is out of scope for v1.
- Push notifications require standard mobile OS permissions (iOS/Android); users who decline notifications can still use in-app indicators.
- Session-based or OAuth2 authentication is assumed for account security; specific auth provider choice is deferred to planning.
- Item categories are predefined by the system (Shirt, Hoodie, Pants, Shoes, Jacket, Dress, Accessories, Other); custom categories are out of scope for v1.
- The rating system uses a simple 1-5 star scale with optional text; advanced reputation algorithms are out of scope for v1.
- Streak tracking resets at midnight in the user's local timezone.
- Chat supports text messages only in v1; image sharing in chat is deferred to a future release.
