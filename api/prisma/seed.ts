import {
  BadgeCriteriaType,
  ItemCategory,
  ItemCondition,
  ItemSize,
  ItemStatus,
  MatchStatus,
  NotificationType,
  PrismaClient,
  User,
  UserRole,
} from '@prisma/client';

const prisma = new PrismaClient();

const DEFAULT_LATITUDE = 30.0444;
const DEFAULT_LONGITUDE = 31.2357;
const nowMs = Date.now();

type BadgeSeed = {
  slug: string;
  name: string;
  description: string;
  iconUrl: string;
  criteriaType: BadgeCriteriaType;
  criteriaValue: number;
};

type UserSeed = {
  id: string;
  email: string;
  firebaseUid: string;
  displayName: string;
  bio: string;
  city: string;
  latitudeOffset: number;
  longitudeOffset: number;
  profilePhotoUrl: string;
};

type PartnerKey = 'sara' | 'omar' | 'lina';
type PartnerMap = Record<PartnerKey, User>;

type ItemSeed = {
  id: string;
  ownerId: string;
  category: ItemCategory;
  brand: string;
  size: ItemSize;
  shoeSizeEu?: number;
  condition: ItemCondition;
  status: ItemStatus;
  notes: string;
  latitude: number;
  longitude: number;
  createdAt: Date;
  photoId: string;
  photoUrl: string;
  thumbnailUrl: string;
};

type ItemPhotoSeed = {
  id: string;
  itemId: string;
  url: string;
  thumbnailUrl: string;
  sortOrder: number;
};

type MatchSeed = {
  id: string;
  userAId: string;
  userBId: string;
  itemAId: string;
  itemBId: string;
  status: MatchStatus;
  userAConfirmed: boolean;
  userBConfirmed: boolean;
  createdAt: Date;
  lastActivityAt: Date;
  completedAt?: Date;
};

type MessageSeed = {
  id: string;
  matchId: string;
  senderId: string;
  text: string;
  createdAt: Date;
  readAt: Date | null;
};

type NotificationSeed = {
  id: string;
  userId: string;
  type: NotificationType;
  title: string;
  body: string;
  referenceId?: string;
  matchId?: string;
  readAt: Date | null;
  createdAt: Date;
};

const BADGES: BadgeSeed[] = [
  {
    slug: 'first_swap',
    name: 'First Swap',
    description: 'Completed your very first clothing swap!',
    iconUrl: '/badges/first-swap.svg',
    criteriaType: BadgeCriteriaType.swap_count,
    criteriaValue: 1,
  },
  {
    slug: 'streak_7',
    name: '7-Day Streak',
    description: 'Stayed active on Swap Style for 7 days in a row.',
    iconUrl: '/badges/streak-7.svg',
    criteriaType: BadgeCriteriaType.streak_days,
    criteriaValue: 7,
  },
  {
    slug: 'streak_30',
    name: '30-Day Streak',
    description: 'Incredible dedication — 30 consecutive active days!',
    iconUrl: '/badges/streak-30.svg',
    criteriaType: BadgeCriteriaType.streak_days,
    criteriaValue: 30,
  },
  {
    slug: 'top_rater',
    name: 'Top Rater',
    description: 'Received 10+ five-star ratings from other swappers.',
    iconUrl: '/badges/top-rater.svg',
    criteriaType: BadgeCriteriaType.rating_count,
    criteriaValue: 10,
  },
];

const FALLBACK_ANCHOR: UserSeed = {
  id: '21000000-0000-4000-8000-000000000000',
  email: 'local.tester@swapstyle.dev',
  firebaseUid: 'seed_local_tester',
  displayName: 'Local Tester',
  bio: 'Love practical swaps and minimalist style.',
  city: 'Cairo',
  latitudeOffset: 0,
  longitudeOffset: 0,
  profilePhotoUrl:
    'https://placehold.co/256x256/f5f5f5/222222/png?text=You',
};

const PARTNER_USERS: Array<UserSeed & { key: PartnerKey }> = [
  {
    key: 'sara',
    id: '21000000-0000-4000-8000-000000000001',
    email: 'sara.swap@swapstyle.dev',
    firebaseUid: 'seed_sara_swap',
    displayName: 'Sara Nabil',
    bio: 'Vintage jackets, oversized shirts, and clean sneakers.',
    city: 'Cairo',
    latitudeOffset: 0.011,
    longitudeOffset: 0.009,
    profilePhotoUrl:
      'https://placehold.co/256x256/faf3e0/3a3a3a/png?text=Sara',
  },
  {
    key: 'omar',
    id: '21000000-0000-4000-8000-000000000002',
    email: 'omar.swap@swapstyle.dev',
    firebaseUid: 'seed_omar_swap',
    displayName: 'Omar Adel',
    bio: 'Streetwear, hoodies, and sneakers in great condition.',
    city: 'Giza',
    latitudeOffset: -0.014,
    longitudeOffset: 0.012,
    profilePhotoUrl:
      'https://placehold.co/256x256/e7f0ff/2f3b52/png?text=Omar',
  },
  {
    key: 'lina',
    id: '21000000-0000-4000-8000-000000000003',
    email: 'lina.swap@swapstyle.dev',
    firebaseUid: 'seed_lina_swap',
    displayName: 'Lina Mostafa',
    bio: 'Soft tones, dresses, and curated capsule wardrobe pieces.',
    city: 'New Cairo',
    latitudeOffset: 0.018,
    longitudeOffset: -0.01,
    profilePhotoUrl:
      'https://placehold.co/256x256/ffeef4/593247/png?text=Lina',
  },
];

const ITEM_IDS = {
  anchorDenim: '31000000-0000-4000-8000-000000000001',
  anchorWindbreaker: '31000000-0000-4000-8000-000000000002',
  anchorTrousers: '31000000-0000-4000-8000-000000000003',
  anchorBomber: '31000000-0000-4000-8000-000000000004',
  anchorLoafers: '31000000-0000-4000-8000-000000000005',
  anchorOvershirt: '31000000-0000-4000-8000-000000000006',
  saraCoat: '31000000-0000-4000-8000-000000000011',
  saraShirt: '31000000-0000-4000-8000-000000000012',
  saraJeans: '31000000-0000-4000-8000-000000000013',
  saraSneakers: '31000000-0000-4000-8000-000000000014',
  saraScarf: '31000000-0000-4000-8000-000000000015',
  omarHoodie: '31000000-0000-4000-8000-000000000021',
  omarSneakers: '31000000-0000-4000-8000-000000000022',
  omarCargo: '31000000-0000-4000-8000-000000000023',
  omarPuffer: '31000000-0000-4000-8000-000000000024',
  omarTee: '31000000-0000-4000-8000-000000000025',
  linaDress: '31000000-0000-4000-8000-000000000031',
  linaBlazer: '31000000-0000-4000-8000-000000000032',
  linaSkirt: '31000000-0000-4000-8000-000000000033',
  linaBag: '31000000-0000-4000-8000-000000000034',
} as const;

const MATCH_IDS = {
  negotiating: '41000000-0000-4000-8000-000000000001',
  agreed: '41000000-0000-4000-8000-000000000002',
  completed: '41000000-0000-4000-8000-000000000003',
  pendingSara: '41000000-0000-4000-8000-000000000004',
  negotiatingOmar: '41000000-0000-4000-8000-000000000005',
  awaitingLina: '41000000-0000-4000-8000-000000000006',
} as const;

const RATING_IDS = {
  linaToAnchor: '51000000-0000-4000-8000-000000000001',
  anchorToLina: '51000000-0000-4000-8000-000000000002',
} as const;

const SEEDED_ITEM_IDS = Object.values(ITEM_IDS);
const SEEDED_MATCH_IDS = Object.values(MATCH_IDS);
const SEEDED_RATING_IDS = Object.values(RATING_IDS);
const SEEDED_WISHLIST_IDS = [
  '91000000-0000-4000-8000-000000000001',
  '91000000-0000-4000-8000-000000000002',
] as const;
const SEEDED_MESSAGE_IDS = [
  '61000000-0000-4000-8000-000000000001',
  '61000000-0000-4000-8000-000000000002',
  '61000000-0000-4000-8000-000000000003',
  '61000000-0000-4000-8000-000000000004',
  '61000000-0000-4000-8000-000000000005',
  '61000000-0000-4000-8000-000000000006',
  '61000000-0000-4000-8000-000000000007',
  '61000000-0000-4000-8000-000000000008',
  '61000000-0000-4000-8000-000000000009',
  '61000000-0000-4000-8000-000000000010',
  '61000000-0000-4000-8000-000000000011',
  '61000000-0000-4000-8000-000000000012',
] as const;
const SEEDED_NOTIFICATION_IDS = [
  '71000000-0000-4000-8000-000000000001',
  '71000000-0000-4000-8000-000000000002',
  '71000000-0000-4000-8000-000000000003',
  '71000000-0000-4000-8000-000000000004',
  '71000000-0000-4000-8000-000000000005',
] as const;

function minutesAgo(minutes: number): Date {
  return new Date(nowMs - minutes * 60_000);
}

function hoursAgo(hours: number): Date {
  return new Date(nowMs - hours * 3_600_000);
}

function daysAgo(days: number): Date {
  return new Date(nowMs - days * 86_400_000);
}

function offset(base: number, delta: number): number {
  return Number((base + delta).toFixed(6));
}

const REAL_IMAGES: Record<string, string> = {
  'anchor-denim-jacket': 'https://images.unsplash.com/photo-1576871337622-98d48d1cf531?w=800&q=80',
  'anchor-windbreaker': 'https://images.unsplash.com/photo-1521223830114-4c010c7bf321?w=800&q=80',
  'anchor-pleated-trousers': 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=800&q=80',
  'anchor-bomber-jacket': 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&q=80',
  'anchor-suede-loafers': 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=800&q=80',
  'anchor-overshirt': 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=800&q=80',
  'sara-wool-coat': 'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=800&q=80',
  'sara-linen-shirt': 'https://images.unsplash.com/photo-1573216896269-83bc9cc3ec52?w=800&q=80',
  'sara-straight-jeans': 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=800&q=80',
  'sara-veja-sneakers': 'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=800&q=80',
  'sara-wool-scarf': 'https://images.unsplash.com/photo-1601004113337-0d70390ea669?w=800&q=80',
  'omar-hoodie': 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800&q=80',
  'omar-high-top-sneakers': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&q=80',
  'omar-cargo-pants': 'https://images.unsplash.com/photo-1610425712165-27a36f663f73?w=800&q=80',
  'omar-puffer-jacket': 'https://images.unsplash.com/photo-1555069519-127aadedf1ee?w=800&q=80',
  'omar-essentials-tee': 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=800&q=80',
  'lina-midi-dress': 'https://images.unsplash.com/photo-1515347619114-659f13c19b22?w=800&q=80',
  'lina-cream-blazer': 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800&q=80',
  'lina-pleated-skirt': 'https://images.unsplash.com/photo-1583496661160-c5dcb4c6f1fa?w=800&q=80',
  'lina-shoulder-bag': 'https://images.unsplash.com/photo-1584916201218-f4242ceb4809?w=800&q=80',
};

function catalogPhoto(seed: string): string {
  if (REAL_IMAGES[seed]) return REAL_IMAGES[seed];
  const text = encodeURIComponent(seed.replace(/-/g, ' '));
  return `https://placehold.co/900x1200/eff3f7/1f2937?text=${text}`;
}

function catalogThumb(seed: string): string {
  if (REAL_IMAGES[seed]) return REAL_IMAGES[seed];
  const text = encodeURIComponent(seed.replace(/-/g, ' '));
  return `https://placehold.co/450x600/eff3f7/1f2937?text=${text}`;
}

const PHOTO_ANGLES = ['front view', 'side view', 'detail view'] as const;
const PHOTO_BG_COLORS = ['f3f4f6', 'e9f2ff', 'f9efe6', 'e8f5f0', 'f3eefe'] as const;
const PHOTO_TEXT_COLORS = ['1f2937', '243447', '3b2f2f', '1f3b33', '2f2857'] as const;

function stableNumberHash(value: string): number {
  let hash = 0;
  for (let i = 0; i < value.length; i += 1) {
    hash = (hash * 31 + value.charCodeAt(i)) % 100_000;
  }
  return hash;
}

function derivePhotoId(basePhotoId: string, offset: number): string {
  const suffix = Number.parseInt(basePhotoId.slice(-12), 10);
  const resolved = Number.isNaN(suffix) ? offset : suffix + offset;
  return `32000000-0000-4000-8000-${String(resolved).padStart(12, '0')}`;
}

function photoSeedByItem(item: ItemSeed, angleIndex: number): string {
  const angle = PHOTO_ANGLES[angleIndex] ?? PHOTO_ANGLES[0];
  return `${item.brand}-${item.category}-${angle}`
    .replace(/[^a-zA-Z0-9\s]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .toLowerCase()
    .replace(/\s+/g, '-');
}

function photoTextByItem(item: ItemSeed, angleIndex: number): string {
  const angle = PHOTO_ANGLES[angleIndex] ?? PHOTO_ANGLES[0];
  const compactAngle = angle.replace(' view', '');
  return `${item.brand} ${item.category} ${compactAngle}`;
}

function topicPhotoByItem(
  item: ItemSeed,
  angleIndex: number,
  thumbnail: boolean,
): string {
  const dimensions = thumbnail ? '450x600' : '900x1200';
  const seed = photoSeedByItem(item, angleIndex);
  const hash = stableNumberHash(seed);
  const paletteIndex = hash % PHOTO_BG_COLORS.length;
  const bg = PHOTO_BG_COLORS[paletteIndex];
  const fg = PHOTO_TEXT_COLORS[paletteIndex];
  const text = encodeURIComponent(photoTextByItem(item, angleIndex));
  return `https://placehold.co/${dimensions}/${bg}/${fg}?text=${text}`;
}

function buildItemPhotos(item: ItemSeed): ItemPhotoSeed[] {
  const photoIds = [
    item.photoId,
    derivePhotoId(item.photoId, 1_000),
    derivePhotoId(item.photoId, 2_000),
  ];

  return photoIds.map((id, index) => ({
    id,
    itemId: item.id,
    url: index === 0 ? item.photoUrl : topicPhotoByItem(item, index, false),
    thumbnailUrl: index === 0 ? item.thumbnailUrl : topicPhotoByItem(item, index, true),
    sortOrder: index,
  }));
}

async function seedBadges(): Promise<void> {
  console.log('Seeding badge definitions...');

  for (const badge of BADGES) {
    await prisma.badge.upsert({
      where: { slug: badge.slug },
      update: {
        name: badge.name,
        description: badge.description,
        iconUrl: badge.iconUrl,
      },
      create: badge,
    });
    console.log(`  - ${badge.slug}`);
  }
}

async function resolveAnchorUser(): Promise<User> {
  const excludedEmails = PARTNER_USERS.map((user) => user.email);

  const existing = await prisma.user.findFirst({
    where: {
      email: { notIn: excludedEmails },
      role: UserRole.USER,
    },
    orderBy: { createdAt: 'desc' },
  });

  if (existing) {
    const hasLocation = existing.latitude != null && existing.longitude != null;
    if (hasLocation) {
      return existing;
    }

    return prisma.user.update({
      where: { id: existing.id },
      data: {
        city: existing.city ?? 'Cairo',
        latitude: existing.latitude ?? DEFAULT_LATITUDE,
        longitude: existing.longitude ?? DEFAULT_LONGITUDE,
      },
    });
  }

  return prisma.user.upsert({
    where: { email: FALLBACK_ANCHOR.email },
    update: {
      displayName: FALLBACK_ANCHOR.displayName,
      bio: FALLBACK_ANCHOR.bio,
      city: FALLBACK_ANCHOR.city,
      latitude: DEFAULT_LATITUDE,
      longitude: DEFAULT_LONGITUDE,
      profilePhotoUrl: FALLBACK_ANCHOR.profilePhotoUrl,
      firebaseUid: FALLBACK_ANCHOR.firebaseUid,
      role: UserRole.USER,
      emailVerified: true,
      phoneVerified: true,
      timezone: 'Africa/Cairo',
    },
    create: {
      id: FALLBACK_ANCHOR.id,
      email: FALLBACK_ANCHOR.email,
      firebaseUid: FALLBACK_ANCHOR.firebaseUid,
      displayName: FALLBACK_ANCHOR.displayName,
      bio: FALLBACK_ANCHOR.bio,
      city: FALLBACK_ANCHOR.city,
      latitude: DEFAULT_LATITUDE,
      longitude: DEFAULT_LONGITUDE,
      profilePhotoUrl: FALLBACK_ANCHOR.profilePhotoUrl,
      role: UserRole.USER,
      emailVerified: true,
      phoneVerified: true,
      timezone: 'Africa/Cairo',
    },
  });
}

async function upsertPartnerUsers(
  baseLatitude: number,
  baseLongitude: number,
): Promise<PartnerMap> {
  const result: Partial<PartnerMap> = {};

  for (const partner of PARTNER_USERS) {
    const user = await prisma.user.upsert({
      where: { email: partner.email },
      update: {
        displayName: partner.displayName,
        bio: partner.bio,
        city: partner.city,
        latitude: offset(baseLatitude, partner.latitudeOffset),
        longitude: offset(baseLongitude, partner.longitudeOffset),
        profilePhotoUrl: partner.profilePhotoUrl,
        firebaseUid: partner.firebaseUid,
        role: UserRole.USER,
        emailVerified: true,
        phoneVerified: true,
        timezone: 'Africa/Cairo',
      },
      create: {
        id: partner.id,
        email: partner.email,
        firebaseUid: partner.firebaseUid,
        displayName: partner.displayName,
        bio: partner.bio,
        city: partner.city,
        latitude: offset(baseLatitude, partner.latitudeOffset),
        longitude: offset(baseLongitude, partner.longitudeOffset),
        profilePhotoUrl: partner.profilePhotoUrl,
        role: UserRole.USER,
        emailVerified: true,
        phoneVerified: true,
        timezone: 'Africa/Cairo',
      },
    });

    result[partner.key] = user;
  }

  return result as PartnerMap;
}

async function purgeExistingSeedData(): Promise<void> {
  await prisma.$transaction(async (tx) => {
    await tx.notification.deleteMany({
      where: {
        OR: [
          { id: { in: [...SEEDED_NOTIFICATION_IDS] } },
          { matchId: { in: SEEDED_MATCH_IDS } },
        ],
      },
    });

    await tx.rating.deleteMany({
      where: {
        OR: [
          { id: { in: SEEDED_RATING_IDS } },
          { matchId: { in: SEEDED_MATCH_IDS } },
        ],
      },
    });

    await tx.message.deleteMany({
      where: {
        OR: [
          { id: { in: [...SEEDED_MESSAGE_IDS] } },
          { matchId: { in: SEEDED_MATCH_IDS } },
        ],
      },
    });

    await tx.counterOffer.deleteMany({
      where: { matchId: { in: SEEDED_MATCH_IDS } },
    });

    await tx.match.deleteMany({
      where: {
        OR: [
          { id: { in: SEEDED_MATCH_IDS } },
          { itemAId: { in: SEEDED_ITEM_IDS } },
          { itemBId: { in: SEEDED_ITEM_IDS } },
        ],
      },
    });

    await tx.like.deleteMany({
      where: {
        itemId: { in: SEEDED_ITEM_IDS },
      },
    });

    await tx.itemVerification.deleteMany({
      where: { itemId: { in: SEEDED_ITEM_IDS } },
    });

    await tx.itemPhoto.deleteMany({
      where: { itemId: { in: SEEDED_ITEM_IDS } },
    });

    await tx.item.deleteMany({
      where: { id: { in: SEEDED_ITEM_IDS } },
    });

    await tx.wishlistEntry.deleteMany({
      where: { id: { in: [...SEEDED_WISHLIST_IDS] } },
    });
  });
}

function buildItems(anchor: User, partners: PartnerMap): ItemSeed[] {
  const baseLatitude = anchor.latitude ?? DEFAULT_LATITUDE;
  const baseLongitude = anchor.longitude ?? DEFAULT_LONGITUDE;

  return [
    {
      id: ITEM_IDS.anchorDenim,
      ownerId: anchor.id,
      category: ItemCategory.Jacket,
      brand: 'Levis denim jacket',
      size: ItemSize.M,
      condition: ItemCondition.LikeNew,
      status: ItemStatus.available,
      notes: 'Barely worn, classic blue wash.',
      latitude: offset(baseLatitude, 0.002),
      longitude: offset(baseLongitude, -0.001),
      createdAt: daysAgo(6),
      photoId: '32000000-0000-4000-8000-000000000001',
      photoUrl: catalogPhoto('anchor-denim-jacket'),
      thumbnailUrl: catalogThumb('anchor-denim-jacket'),
    },
    {
      id: ITEM_IDS.anchorWindbreaker,
      ownerId: anchor.id,
      category: ItemCategory.Hoodie,
      brand: 'Nike windbreaker',
      size: ItemSize.L,
      condition: ItemCondition.Good,
      status: ItemStatus.available,
      notes: 'Lightweight for spring weather.',
      latitude: offset(baseLatitude, 0.001),
      longitude: offset(baseLongitude, 0.002),
      createdAt: daysAgo(4),
      photoId: '32000000-0000-4000-8000-000000000002',
      photoUrl: catalogPhoto('anchor-windbreaker'),
      thumbnailUrl: catalogThumb('anchor-windbreaker'),
    },
    {
      id: ITEM_IDS.anchorTrousers,
      ownerId: anchor.id,
      category: ItemCategory.Pants,
      brand: 'COS pleated trousers',
      size: ItemSize.M,
      condition: ItemCondition.LikeNew,
      status: ItemStatus.swapped,
      notes: 'Tailored fit, charcoal grey.',
      latitude: offset(baseLatitude, -0.003),
      longitude: offset(baseLongitude, 0.001),
      createdAt: daysAgo(12),
      photoId: '32000000-0000-4000-8000-000000000003',
      photoUrl: catalogPhoto('anchor-pleated-trousers'),
      thumbnailUrl: catalogThumb('anchor-pleated-trousers'),
    },
    {
      id: ITEM_IDS.anchorBomber,
      ownerId: anchor.id,
      category: ItemCategory.Jacket,
      brand: 'Alpha bomber jacket',
      size: ItemSize.L,
      condition: ItemCondition.Good,
      status: ItemStatus.available,
      notes: 'Olive green bomber, clean cuffs and zipper.',
      latitude: offset(baseLatitude, 0.003),
      longitude: offset(baseLongitude, 0.004),
      createdAt: daysAgo(3),
      photoId: '32000000-0000-4000-8000-000000000004',
      photoUrl: catalogPhoto('anchor-bomber-jacket'),
      thumbnailUrl: catalogThumb('anchor-bomber-jacket'),
    },
    {
      id: ITEM_IDS.anchorLoafers,
      ownerId: anchor.id,
      category: ItemCategory.Shoes,
      brand: 'Clarks suede loafers',
      size: ItemSize.ONE_SIZE,
      shoeSizeEu: 43,
      condition: ItemCondition.LikeNew,
      status: ItemStatus.available,
      notes: 'Dark brown loafers, lightly worn.',
      latitude: offset(baseLatitude, -0.001),
      longitude: offset(baseLongitude, -0.003),
      createdAt: daysAgo(5),
      photoId: '32000000-0000-4000-8000-000000000005',
      photoUrl: catalogPhoto('anchor-suede-loafers'),
      thumbnailUrl: catalogThumb('anchor-suede-loafers'),
    },
    {
      id: ITEM_IDS.anchorOvershirt,
      ownerId: anchor.id,
      category: ItemCategory.Shirt,
      brand: 'Muji overshirt',
      size: ItemSize.M,
      condition: ItemCondition.New,
      status: ItemStatus.available,
      notes: 'Unworn overshirt in stone color.',
      latitude: offset(baseLatitude, -0.002),
      longitude: offset(baseLongitude, 0.003),
      createdAt: daysAgo(2),
      photoId: '32000000-0000-4000-8000-000000000006',
      photoUrl: catalogPhoto('anchor-overshirt'),
      thumbnailUrl: catalogThumb('anchor-overshirt'),
    },
    {
      id: ITEM_IDS.saraCoat,
      ownerId: partners.sara.id,
      category: ItemCategory.Jacket,
      brand: 'Zara wool coat',
      size: ItemSize.M,
      condition: ItemCondition.Good,
      status: ItemStatus.available,
      notes: 'Warm and clean, camel color.',
      latitude: offset(baseLatitude, 0.011),
      longitude: offset(baseLongitude, 0.009),
      createdAt: daysAgo(3),
      photoId: '32000000-0000-4000-8000-000000000011',
      photoUrl: catalogPhoto('sara-wool-coat'),
      thumbnailUrl: catalogThumb('sara-wool-coat'),
    },
    {
      id: ITEM_IDS.saraShirt,
      ownerId: partners.sara.id,
      category: ItemCategory.Shirt,
      brand: 'Uniqlo linen shirt',
      size: ItemSize.S,
      condition: ItemCondition.LikeNew,
      status: ItemStatus.available,
      notes: 'Breathable fabric, pastel green.',
      latitude: offset(baseLatitude, 0.013),
      longitude: offset(baseLongitude, 0.006),
      createdAt: daysAgo(1),
      photoId: '32000000-0000-4000-8000-000000000012',
      photoUrl: catalogPhoto('sara-linen-shirt'),
      thumbnailUrl: catalogThumb('sara-linen-shirt'),
    },
    {
      id: ITEM_IDS.saraJeans,
      ownerId: partners.sara.id,
      category: ItemCategory.Pants,
      brand: 'Mango straight jeans',
      size: ItemSize.S,
      condition: ItemCondition.Good,
      status: ItemStatus.available,
      notes: 'Mid-rise blue denim with relaxed fit.',
      latitude: offset(baseLatitude, 0.014),
      longitude: offset(baseLongitude, 0.01),
      createdAt: daysAgo(2),
      photoId: '32000000-0000-4000-8000-000000000013',
      photoUrl: catalogPhoto('sara-straight-jeans'),
      thumbnailUrl: catalogThumb('sara-straight-jeans'),
    },
    {
      id: ITEM_IDS.saraSneakers,
      ownerId: partners.sara.id,
      category: ItemCategory.Shoes,
      brand: 'Veja white sneakers',
      size: ItemSize.ONE_SIZE,
      shoeSizeEu: 39,
      condition: ItemCondition.LikeNew,
      status: ItemStatus.available,
      notes: 'Minimal white sneakers, recently cleaned.',
      latitude: offset(baseLatitude, 0.009),
      longitude: offset(baseLongitude, 0.012),
      createdAt: hoursAgo(22),
      photoId: '32000000-0000-4000-8000-000000000014',
      photoUrl: catalogPhoto('sara-veja-sneakers'),
      thumbnailUrl: catalogThumb('sara-veja-sneakers'),
    },
    {
      id: ITEM_IDS.saraScarf,
      ownerId: partners.sara.id,
      category: ItemCategory.Accessories,
      brand: 'COS wool scarf',
      size: ItemSize.ONE_SIZE,
      condition: ItemCondition.New,
      status: ItemStatus.available,
      notes: 'Soft scarf, never used.',
      latitude: offset(baseLatitude, 0.012),
      longitude: offset(baseLongitude, 0.008),
      createdAt: hoursAgo(15),
      photoId: '32000000-0000-4000-8000-000000000015',
      photoUrl: catalogPhoto('sara-wool-scarf'),
      thumbnailUrl: catalogThumb('sara-wool-scarf'),
    },
    {
      id: ITEM_IDS.omarHoodie,
      ownerId: partners.omar.id,
      category: ItemCategory.Hoodie,
      brand: 'Adidas essentials hoodie',
      size: ItemSize.L,
      condition: ItemCondition.LikeNew,
      status: ItemStatus.available,
      notes: 'Black hoodie, no pilling.',
      latitude: offset(baseLatitude, -0.012),
      longitude: offset(baseLongitude, 0.011),
      createdAt: daysAgo(2),
      photoId: '32000000-0000-4000-8000-000000000021',
      photoUrl: catalogPhoto('omar-hoodie'),
      thumbnailUrl: catalogThumb('omar-hoodie'),
    },
    {
      id: ITEM_IDS.omarSneakers,
      ownerId: partners.omar.id,
      category: ItemCategory.Shoes,
      brand: 'Converse high top',
      size: ItemSize.ONE_SIZE,
      shoeSizeEu: 43,
      condition: ItemCondition.Good,
      status: ItemStatus.available,
      notes: 'White canvas, recently cleaned.',
      latitude: offset(baseLatitude, -0.01),
      longitude: offset(baseLongitude, 0.013),
      createdAt: hoursAgo(18),
      photoId: '32000000-0000-4000-8000-000000000022',
      photoUrl: catalogPhoto('omar-high-top-sneakers'),
      thumbnailUrl: catalogThumb('omar-high-top-sneakers'),
    },
    {
      id: ITEM_IDS.omarCargo,
      ownerId: partners.omar.id,
      category: ItemCategory.Pants,
      brand: 'Carhartt cargo pants',
      size: ItemSize.L,
      condition: ItemCondition.Good,
      status: ItemStatus.available,
      notes: 'Loose fit cargo with six pockets.',
      latitude: offset(baseLatitude, -0.015),
      longitude: offset(baseLongitude, 0.009),
      createdAt: daysAgo(1),
      photoId: '32000000-0000-4000-8000-000000000023',
      photoUrl: catalogPhoto('omar-cargo-pants'),
      thumbnailUrl: catalogThumb('omar-cargo-pants'),
    },
    {
      id: ITEM_IDS.omarPuffer,
      ownerId: partners.omar.id,
      category: ItemCategory.Jacket,
      brand: 'North Face puffer',
      size: ItemSize.XL,
      condition: ItemCondition.LikeNew,
      status: ItemStatus.available,
      notes: 'Warm puffer jacket in matte black.',
      latitude: offset(baseLatitude, -0.013),
      longitude: offset(baseLongitude, 0.014),
      createdAt: daysAgo(4),
      photoId: '32000000-0000-4000-8000-000000000024',
      photoUrl: catalogPhoto('omar-puffer-jacket'),
      thumbnailUrl: catalogThumb('omar-puffer-jacket'),
    },
    {
      id: ITEM_IDS.omarTee,
      ownerId: partners.omar.id,
      category: ItemCategory.Shirt,
      brand: 'Fear of God essentials tee',
      size: ItemSize.L,
      condition: ItemCondition.New,
      status: ItemStatus.available,
      notes: 'Oversized tee, sand color, never worn.',
      latitude: offset(baseLatitude, -0.011),
      longitude: offset(baseLongitude, 0.008),
      createdAt: hoursAgo(12),
      photoId: '32000000-0000-4000-8000-000000000025',
      photoUrl: catalogPhoto('omar-essentials-tee'),
      thumbnailUrl: catalogThumb('omar-essentials-tee'),
    },
    {
      id: ITEM_IDS.linaDress,
      ownerId: partners.lina.id,
      category: ItemCategory.Dress,
      brand: 'H and M midi dress',
      size: ItemSize.M,
      condition: ItemCondition.LikeNew,
      status: ItemStatus.swapped,
      notes: 'Soft beige, perfect condition.',
      latitude: offset(baseLatitude, 0.017),
      longitude: offset(baseLongitude, -0.009),
      createdAt: daysAgo(10),
      photoId: '32000000-0000-4000-8000-000000000031',
      photoUrl: catalogPhoto('lina-midi-dress'),
      thumbnailUrl: catalogThumb('lina-midi-dress'),
    },
    {
      id: ITEM_IDS.linaBlazer,
      ownerId: partners.lina.id,
      category: ItemCategory.Jacket,
      brand: 'Massimo Dutti blazer',
      size: ItemSize.M,
      condition: ItemCondition.LikeNew,
      status: ItemStatus.available,
      notes: 'Cream blazer with tailored silhouette.',
      latitude: offset(baseLatitude, 0.019),
      longitude: offset(baseLongitude, -0.011),
      createdAt: daysAgo(2),
      photoId: '32000000-0000-4000-8000-000000000032',
      photoUrl: catalogPhoto('lina-cream-blazer'),
      thumbnailUrl: catalogThumb('lina-cream-blazer'),
    },
    {
      id: ITEM_IDS.linaSkirt,
      ownerId: partners.lina.id,
      category: ItemCategory.Pants,
      brand: 'A-line pleated skirt',
      size: ItemSize.S,
      condition: ItemCondition.Good,
      status: ItemStatus.available,
      notes: 'Navy pleated skirt in excellent shape.',
      latitude: offset(baseLatitude, 0.016),
      longitude: offset(baseLongitude, -0.008),
      createdAt: daysAgo(3),
      photoId: '32000000-0000-4000-8000-000000000033',
      photoUrl: catalogPhoto('lina-pleated-skirt'),
      thumbnailUrl: catalogThumb('lina-pleated-skirt'),
    },
    {
      id: ITEM_IDS.linaBag,
      ownerId: partners.lina.id,
      category: ItemCategory.Accessories,
      brand: 'Charles and Keith shoulder bag',
      size: ItemSize.ONE_SIZE,
      condition: ItemCondition.New,
      status: ItemStatus.available,
      notes: 'Minimal shoulder bag, tags still attached.',
      latitude: offset(baseLatitude, 0.02),
      longitude: offset(baseLongitude, -0.012),
      createdAt: hoursAgo(20),
      photoId: '32000000-0000-4000-8000-000000000034',
      photoUrl: catalogPhoto('lina-shoulder-bag'),
      thumbnailUrl: catalogThumb('lina-shoulder-bag'),
    },
  ];
}

async function upsertItems(items: ItemSeed[]): Promise<void> {
  for (const item of items) {
    await prisma.item.upsert({
      where: { id: item.id },
      update: {
        ownerId: item.ownerId,
        category: item.category,
        brand: item.brand,
        size: item.size,
        shoeSizeEu: item.shoeSizeEu,
        condition: item.condition,
        status: item.status,
        notes: item.notes,
        latitude: item.latitude,
        longitude: item.longitude,
      },
      create: {
        id: item.id,
        ownerId: item.ownerId,
        category: item.category,
        brand: item.brand,
        size: item.size,
        shoeSizeEu: item.shoeSizeEu,
        condition: item.condition,
        status: item.status,
        notes: item.notes,
        latitude: item.latitude,
        longitude: item.longitude,
        createdAt: item.createdAt,
      },
    });

    const photos = buildItemPhotos(item);

    for (const photo of photos) {
      await prisma.itemPhoto.upsert({
        where: { id: photo.id },
        update: {
          itemId: photo.itemId,
          url: photo.url,
          thumbnailUrl: photo.thumbnailUrl,
          sortOrder: photo.sortOrder,
        },
        create: {
          id: photo.id,
          itemId: photo.itemId,
          url: photo.url,
          thumbnailUrl: photo.thumbnailUrl,
          sortOrder: photo.sortOrder,
        },
      });
    }

    await prisma.itemPhoto.deleteMany({
      where: {
        itemId: item.id,
        id: { notIn: photos.map((photo) => photo.id) },
      },
    });

    await prisma.itemVerification.upsert({
      where: { itemId: item.id },
      update: {
        washed: true,
        noStains: true,
        noTears: true,
        noDefects: true,
        photosAccurate: true,
        verifiedAt: daysAgo(1),
      },
      create: {
        itemId: item.id,
        washed: true,
        noStains: true,
        noTears: true,
        noDefects: true,
        photosAccurate: true,
        verifiedAt: daysAgo(1),
      },
    });
  }
}

function buildMatches(anchor: User, partners: PartnerMap): MatchSeed[] {
  return [
    {
      id: MATCH_IDS.negotiating,
      userAId: anchor.id,
      userBId: partners.sara.id,
      itemAId: ITEM_IDS.anchorDenim,
      itemBId: ITEM_IDS.saraCoat,
      status: MatchStatus.negotiating,
      userAConfirmed: false,
      userBConfirmed: false,
      createdAt: daysAgo(2),
      lastActivityAt: minutesAgo(25),
    },
    {
      id: MATCH_IDS.agreed,
      userAId: anchor.id,
      userBId: partners.omar.id,
      itemAId: ITEM_IDS.anchorWindbreaker,
      itemBId: ITEM_IDS.omarHoodie,
      status: MatchStatus.agreed,
      userAConfirmed: false,
      userBConfirmed: true,
      createdAt: daysAgo(1),
      lastActivityAt: minutesAgo(55),
    },
    {
      id: MATCH_IDS.completed,
      userAId: anchor.id,
      userBId: partners.lina.id,
      itemAId: ITEM_IDS.anchorTrousers,
      itemBId: ITEM_IDS.linaDress,
      status: MatchStatus.completed,
      userAConfirmed: true,
      userBConfirmed: true,
      createdAt: daysAgo(9),
      lastActivityAt: daysAgo(2),
      completedAt: daysAgo(2),
    },
    {
      id: MATCH_IDS.pendingSara,
      userAId: anchor.id,
      userBId: partners.sara.id,
      itemAId: ITEM_IDS.anchorLoafers,
      itemBId: ITEM_IDS.saraJeans,
      status: MatchStatus.pending,
      userAConfirmed: false,
      userBConfirmed: false,
      createdAt: hoursAgo(20),
      lastActivityAt: hoursAgo(20),
    },
    {
      id: MATCH_IDS.negotiatingOmar,
      userAId: anchor.id,
      userBId: partners.omar.id,
      itemAId: ITEM_IDS.anchorBomber,
      itemBId: ITEM_IDS.omarPuffer,
      status: MatchStatus.negotiating,
      userAConfirmed: false,
      userBConfirmed: false,
      createdAt: daysAgo(1),
      lastActivityAt: hoursAgo(4),
    },
    {
      id: MATCH_IDS.awaitingLina,
      userAId: anchor.id,
      userBId: partners.lina.id,
      itemAId: ITEM_IDS.anchorOvershirt,
      itemBId: ITEM_IDS.linaBlazer,
      status: MatchStatus.awaiting_confirmation,
      userAConfirmed: true,
      userBConfirmed: false,
      createdAt: hoursAgo(28),
      lastActivityAt: hoursAgo(3),
    },
  ];
}

async function upsertMatches(matches: MatchSeed[]): Promise<void> {
  for (const match of matches) {
    await prisma.match.upsert({
      where: { id: match.id },
      update: {
        userAId: match.userAId,
        userBId: match.userBId,
        itemAId: match.itemAId,
        itemBId: match.itemBId,
        status: match.status,
        userAConfirmed: match.userAConfirmed,
        userBConfirmed: match.userBConfirmed,
        lastActivityAt: match.lastActivityAt,
        completedAt: match.completedAt,
      },
      create: {
        id: match.id,
        userAId: match.userAId,
        userBId: match.userBId,
        itemAId: match.itemAId,
        itemBId: match.itemBId,
        status: match.status,
        userAConfirmed: match.userAConfirmed,
        userBConfirmed: match.userBConfirmed,
        createdAt: match.createdAt,
        lastActivityAt: match.lastActivityAt,
        completedAt: match.completedAt,
      },
    });
  }
}

function buildMessages(anchor: User, partners: PartnerMap): MessageSeed[] {
  return [
    {
      id: '61000000-0000-4000-8000-000000000001',
      matchId: MATCH_IDS.negotiating,
      senderId: partners.sara.id,
      text: 'Hey! I love your denim jacket. Is it still available?',
      createdAt: hoursAgo(18),
      readAt: hoursAgo(17),
    },
    {
      id: '61000000-0000-4000-8000-000000000002',
      matchId: MATCH_IDS.negotiating,
      senderId: anchor.id,
      text: 'Yes, still available. I can swap this weekend if that works.',
      createdAt: hoursAgo(17),
      readAt: hoursAgo(16),
    },
    {
      id: '61000000-0000-4000-8000-000000000003',
      matchId: MATCH_IDS.negotiating,
      senderId: partners.sara.id,
      text: 'Perfect. Saturday afternoon near Zamalek?',
      createdAt: minutesAgo(50),
      readAt: null,
    },
    {
      id: '61000000-0000-4000-8000-000000000004',
      matchId: MATCH_IDS.agreed,
      senderId: partners.omar.id,
      text: 'I accepted the swap. Can you confirm from your side?',
      createdAt: hoursAgo(7),
      readAt: hoursAgo(6),
    },
    {
      id: '61000000-0000-4000-8000-000000000005',
      matchId: MATCH_IDS.agreed,
      senderId: anchor.id,
      text: 'Looks great. I will confirm once we meet tomorrow.',
      createdAt: hoursAgo(5),
      readAt: hoursAgo(4),
    },
    {
      id: '61000000-0000-4000-8000-000000000006',
      matchId: MATCH_IDS.completed,
      senderId: partners.lina.id,
      text: 'Thanks again for the smooth swap.',
      createdAt: daysAgo(2),
      readAt: daysAgo(2),
    },
    {
      id: '61000000-0000-4000-8000-000000000007',
      matchId: MATCH_IDS.completed,
      senderId: anchor.id,
      text: 'Likewise. Enjoy the trousers!',
      createdAt: daysAgo(2),
      readAt: daysAgo(2),
    },
    {
      id: '61000000-0000-4000-8000-000000000008',
      matchId: MATCH_IDS.pendingSara,
      senderId: anchor.id,
      text: 'Hi Sara, I can share more photos of the loafers if needed.',
      createdAt: hoursAgo(19),
      readAt: null,
    },
    {
      id: '61000000-0000-4000-8000-000000000009',
      matchId: MATCH_IDS.negotiatingOmar,
      senderId: partners.omar.id,
      text: 'Bomber looks great. Can we swap near Dokki station?',
      createdAt: hoursAgo(5),
      readAt: hoursAgo(4),
    },
    {
      id: '61000000-0000-4000-8000-000000000010',
      matchId: MATCH_IDS.negotiatingOmar,
      senderId: anchor.id,
      text: 'Works for me. Saturday at 5 PM?',
      createdAt: hoursAgo(4),
      readAt: hoursAgo(3),
    },
    {
      id: '61000000-0000-4000-8000-000000000011',
      matchId: MATCH_IDS.awaitingLina,
      senderId: partners.lina.id,
      text: 'I already confirmed. Let me know once you complete your confirmation.',
      createdAt: hoursAgo(3),
      readAt: null,
    },
    {
      id: '61000000-0000-4000-8000-000000000012',
      matchId: MATCH_IDS.awaitingLina,
      senderId: anchor.id,
      text: 'Perfect, I am confirming right after our meetup.',
      createdAt: hoursAgo(2),
      readAt: null,
    },
  ];
}

async function upsertMessages(messages: MessageSeed[]): Promise<void> {
  for (const message of messages) {
    await prisma.message.upsert({
      where: { id: message.id },
      update: {
        matchId: message.matchId,
        senderId: message.senderId,
        text: message.text,
        readAt: message.readAt,
        createdAt: message.createdAt,
      },
      create: {
        id: message.id,
        matchId: message.matchId,
        senderId: message.senderId,
        text: message.text,
        readAt: message.readAt,
        createdAt: message.createdAt,
      },
    });
  }
}

async function upsertRatings(anchor: User, partners: PartnerMap): Promise<void> {
  await prisma.rating.upsert({
    where: { id: RATING_IDS.linaToAnchor },
    update: {
      matchId: MATCH_IDS.completed,
      raterId: partners.lina.id,
      rateeId: anchor.id,
      score: 5,
      comment: 'Great communication and item exactly as described.',
      createdAt: daysAgo(2),
    },
    create: {
      id: RATING_IDS.linaToAnchor,
      matchId: MATCH_IDS.completed,
      raterId: partners.lina.id,
      rateeId: anchor.id,
      score: 5,
      comment: 'Great communication and item exactly as described.',
      createdAt: daysAgo(2),
    },
  });

  await prisma.rating.upsert({
    where: { id: RATING_IDS.anchorToLina },
    update: {
      matchId: MATCH_IDS.completed,
      raterId: anchor.id,
      rateeId: partners.lina.id,
      score: 5,
      comment: 'Friendly and punctual. Smooth swap.',
      createdAt: daysAgo(2),
    },
    create: {
      id: RATING_IDS.anchorToLina,
      matchId: MATCH_IDS.completed,
      raterId: anchor.id,
      rateeId: partners.lina.id,
      score: 5,
      comment: 'Friendly and punctual. Smooth swap.',
      createdAt: daysAgo(2),
    },
  });
}

function buildNotifications(anchorUserId: string): NotificationSeed[] {
  return [
    {
      id: '71000000-0000-4000-8000-000000000001',
      userId: anchorUserId,
      type: NotificationType.message,
      title: 'New message from Sara',
      body: 'Perfect. Saturday afternoon near Zamalek?',
      referenceId: MATCH_IDS.negotiating,
      matchId: MATCH_IDS.negotiating,
      readAt: null,
      createdAt: minutesAgo(45),
    },
    {
      id: '71000000-0000-4000-8000-000000000002',
      userId: anchorUserId,
      type: NotificationType.match,
      title: 'Swap ready to confirm',
      body: 'Omar marked your swap as agreed.',
      referenceId: MATCH_IDS.agreed,
      matchId: MATCH_IDS.agreed,
      readAt: hoursAgo(1),
      createdAt: hoursAgo(2),
    },
    {
      id: '71000000-0000-4000-8000-000000000003',
      userId: anchorUserId,
      type: NotificationType.rating_prompt,
      title: 'Rate your recent swap',
      body: 'How was your completed swap with Lina?',
      referenceId: MATCH_IDS.completed,
      matchId: MATCH_IDS.completed,
      readAt: null,
      createdAt: daysAgo(1),
    },
    {
      id: '71000000-0000-4000-8000-000000000004',
      userId: anchorUserId,
      type: NotificationType.match,
      title: 'New pending match',
      body: 'You and Sara have a new pending swap.',
      referenceId: MATCH_IDS.pendingSara,
      matchId: MATCH_IDS.pendingSara,
      readAt: null,
      createdAt: hoursAgo(20),
    },
    {
      id: '71000000-0000-4000-8000-000000000005',
      userId: anchorUserId,
      type: NotificationType.message,
      title: 'New message from Lina',
      body: 'I already confirmed. Let me know once you complete your confirmation.',
      referenceId: MATCH_IDS.awaitingLina,
      matchId: MATCH_IDS.awaitingLina,
      readAt: null,
      createdAt: hoursAgo(3),
    },
  ];
}

async function upsertNotifications(
  notifications: NotificationSeed[],
): Promise<void> {
  for (const notification of notifications) {
    await prisma.notification.upsert({
      where: { id: notification.id },
      update: {
        userId: notification.userId,
        type: notification.type,
        title: notification.title,
        body: notification.body,
        referenceId: notification.referenceId,
        matchId: notification.matchId,
        readAt: notification.readAt,
        createdAt: notification.createdAt,
      },
      create: {
        id: notification.id,
        userId: notification.userId,
        type: notification.type,
        title: notification.title,
        body: notification.body,
        referenceId: notification.referenceId,
        matchId: notification.matchId,
        readAt: notification.readAt,
        createdAt: notification.createdAt,
      },
    });
  }
}

async function main() {
  console.log('Seeding realistic demo data for local testing...');

  await seedBadges();

  const anchor = await resolveAnchorUser();
  await purgeExistingSeedData();
  const anchorLatitude = anchor.latitude ?? DEFAULT_LATITUDE;
  const anchorLongitude = anchor.longitude ?? DEFAULT_LONGITUDE;
  console.log(`Anchor user: ${anchor.email} (${anchor.id})`);

  const partners = await upsertPartnerUsers(anchorLatitude, anchorLongitude);
  console.log('Partner users upserted: 3');

  const items = buildItems(anchor, partners);
  await upsertItems(items);
  console.log(`Items upserted: ${items.length}`);

  const matches = buildMatches(anchor, partners);
  await upsertMatches(matches);
  console.log(`Matches upserted: ${matches.length}`);

  const messages = buildMessages(anchor, partners);
  await upsertMessages(messages);
  console.log(`Messages upserted: ${messages.length}`);

  await upsertRatings(anchor, partners);
  console.log('Ratings upserted: 2');

  const notifications = buildNotifications(anchor.id);
  await upsertNotifications(notifications);
  console.log(`Notifications upserted: ${notifications.length}`);

  await prisma.streak.upsert({
    where: { userId: anchor.id },
    update: {
      currentStreak: 6,
      longestStreak: 12,
      lastActivityAt: new Date(),
    },
    create: {
      userId: anchor.id,
      currentStreak: 6,
      longestStreak: 12,
      lastActivityAt: new Date(),
    },
  });

  console.log('Seed complete. Chat and match data are ready.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
