/**
 * k6 Load Test — Swap Style API
 *
 * Scenarios:
 *   1. Browse: GET /discovery/feed (read-heavy)
 *   2. Swipe:  POST /discovery/swipe (write)
 *   3. Chat:   POST /chat/:matchId/messages (write)
 *
 * Run:
 *   k6 run --env API_URL=http://localhost:3000 \
 *           --env AUTH_TOKEN=<firebase-id-token> \
 *           k6-load-test.js
 *
 * Install k6: https://k6.io/docs/get-started/installation/
 */
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Rate } from 'k6/metrics';

// ─── Custom metrics ──────────────────────────────────────
const feedDuration = new Trend('feed_request_duration', true);
const swipeDuration = new Trend('swipe_request_duration', true);
const chatDuration = new Trend('chat_request_duration', true);
const errorRate = new Rate('errors');

// ─── Config ──────────────────────────────────────────────
const BASE_URL = __ENV.API_URL || 'http://localhost:3000';
const TOKEN = __ENV.AUTH_TOKEN || 'test-token';

const HEADERS = {
  Authorization: `Bearer ${TOKEN}`,
  'Content-Type': 'application/json',
};

// ─── Load profile ────────────────────────────────────────
export const options = {
  scenarios: {
    browse_feed: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '30s', target: 20 },   // ramp up
        { duration: '1m', target: 50 },    // sustained load
        { duration: '30s', target: 0 },    // ramp down
      ],
      gracefulRampDown: '10s',
      exec: 'browseFeed',
    },
    swipe_items: {
      executor: 'constant-arrival-rate',
      rate: 10,            // 10 swipes/second
      timeUnit: '1s',
      duration: '2m',
      preAllocatedVUs: 20,
      maxVUs: 50,
      exec: 'swipeItem',
    },
  },
  thresholds: {
    // 95th percentile of feed requests under 500ms
    feed_request_duration: ['p(95)<500'],
    // 95th percentile of swipe requests under 800ms
    swipe_request_duration: ['p(95)<800'],
    // Error rate below 1%
    errors: ['rate<0.01'],
    // Overall HTTP failure rate below 1%
    http_req_failed: ['rate<0.01'],
  },
};

// ─── Scenario functions ──────────────────────────────────

export function browseFeed() {
  const res = http.get(
    `${BASE_URL}/discovery/feed?latitude=30.0444&longitude=31.2357&radiusKm=25`,
    { headers: HEADERS },
  );

  feedDuration.add(res.timings.duration);

  const ok = check(res, {
    'feed status 200': (r) => r.status === 200,
    'feed returns data array': (r) => {
      const body = r.json();
      return Array.isArray(body?.data);
    },
  });

  errorRate.add(!ok);
  sleep(1);
}

export function swipeItem() {
  const payload = JSON.stringify({
    itemId: 'placeholder-item-id', // Replace with real seeded itemId in CI
    direction: 'RIGHT',
  });

  const res = http.post(`${BASE_URL}/discovery/swipe`, payload, {
    headers: HEADERS,
  });

  swipeDuration.add(res.timings.duration);

  const ok = check(res, {
    'swipe status 201 or 409': (r) => r.status === 201 || r.status === 409,
  });

  errorRate.add(!ok);
  sleep(0.5);
}
