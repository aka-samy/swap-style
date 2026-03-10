import { PrismaClient, BadgeCriteriaType } from '@prisma/client';

const prisma = new PrismaClient();

const BADGES = [
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

async function main() {
  console.log('Seeding badge definitions…');

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
    console.log(`  ✓ ${badge.slug}`);
  }

  console.log('Seed complete.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
