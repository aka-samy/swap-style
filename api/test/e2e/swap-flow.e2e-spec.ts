import * as request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { AppModule } from '../../src/app.module';

/**
 * Full swap-flow E2E test.
 *
 * Requires:
 *   - TEST_FIREBASE_TOKEN_A and TEST_FIREBASE_TOKEN_B env vars (valid Firebase ID tokens)
 *   - Running PostgreSQL + Redis (services defined in CI workflow)
 *
 * Skipped automatically in unit-test runs without the env vars.
 */
const SKIP = !process.env.TEST_FIREBASE_TOKEN_A || !process.env.TEST_FIREBASE_TOKEN_B;

(SKIP ? describe.skip : describe)('Full Swap Flow (e2e)', () => {
  let app: INestApplication;
  const tokenA = process.env.TEST_FIREBASE_TOKEN_A ?? '';
  const tokenB = process.env.TEST_FIREBASE_TOKEN_B ?? '';

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  let itemAId: string;
  let itemBId: string;
  let matchId: string;

  it('User A lists an item', async () => {
    const res = await request(app.getHttpServer())
      .post('/items')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({
        title: 'Blue Denim Jacket',
        description: 'Like new, size M',
        category: 'TOPS',
        size: 'M',
        condition: 'LIKE_NEW',
        tags: ['denim', 'jacket'],
      })
      .expect(201);

    itemAId = res.body.id;
    expect(itemAId).toBeDefined();
  });

  it('User B lists an item', async () => {
    const res = await request(app.getHttpServer())
      .post('/items')
      .set('Authorization', `Bearer ${tokenB}`)
      .send({
        title: 'Floral Summer Dress',
        description: 'Worn once, size S',
        category: 'DRESSES',
        size: 'S',
        condition: 'GOOD',
        tags: ['dress', 'summer'],
      })
      .expect(201);

    itemBId = res.body.id;
    expect(itemBId).toBeDefined();
  });

  it('User A gets discovery feed', async () => {
    const res = await request(app.getHttpServer())
      .get('/discovery/feed')
      .set('Authorization', `Bearer ${tokenA}`)
      .expect(200);

    expect(Array.isArray(res.body)).toBe(true);
  });

  it('User A swipes right on User B item → no match yet', async () => {
    await request(app.getHttpServer())
      .post('/discovery/swipe')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({ itemId: itemBId, direction: 'RIGHT' })
      .expect(201);
  });

  it('User B swipes right on User A item → double-match created', async () => {
    const res = await request(app.getHttpServer())
      .post('/discovery/swipe')
      .set('Authorization', `Bearer ${tokenB}`)
      .send({ itemId: itemAId, direction: 'RIGHT' })
      .expect(201);

    matchId = res.body.matchId;
    expect(matchId).toBeDefined();
  });

  it('User A sees the match in their list', async () => {
    const res = await request(app.getHttpServer())
      .get('/matching/matches')
      .set('Authorization', `Bearer ${tokenA}`)
      .expect(200);

    const match = res.body.find((m: any) => m.id === matchId);
    expect(match).toBeDefined();
    expect(match.status).toBe('PENDING');
  });

  it('User A sends a chat message', async () => {
    await request(app.getHttpServer())
      .post(`/chat/${matchId}/messages`)
      .set('Authorization', `Bearer ${tokenA}`)
      .send({ content: 'Hey, interested in swapping!' })
      .expect(201);
  });

  it('User B reads messages', async () => {
    const res = await request(app.getHttpServer())
      .get(`/chat/${matchId}/messages`)
      .set('Authorization', `Bearer ${tokenB}`)
      .expect(200);

    expect(res.body.messages.length).toBeGreaterThan(0);
    expect(res.body.messages[0].content).toBe('Hey, interested in swapping!');
  });

  it('User A confirms the match', async () => {
    await request(app.getHttpServer())
      .patch(`/matching/matches/${matchId}/confirm`)
      .set('Authorization', `Bearer ${tokenA}`)
      .expect(200);
  });

  it('User B confirms the match → status becomes CONFIRMED', async () => {
    const res = await request(app.getHttpServer())
      .patch(`/matching/matches/${matchId}/confirm`)
      .set('Authorization', `Bearer ${tokenB}`)
      .expect(200);

    expect(res.body.status).toBe('CONFIRMED');
  });

  it('User A rates User B', async () => {
    await request(app.getHttpServer())
      .post(`/matches/${matchId}/rating`)
      .set('Authorization', `Bearer ${tokenA}`)
      .send({ score: 5, comment: 'Great swap!' })
      .expect(201);
  });

  it('User B rates User A', async () => {
    await request(app.getHttpServer())
      .post(`/matches/${matchId}/rating`)
      .set('Authorization', `Bearer ${tokenB}`)
      .send({ score: 4 })
      .expect(201);
  });
});
