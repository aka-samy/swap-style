import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:swap_style/core/models/gamification.dart';
import 'package:swap_style/features/gamification/providers/gamification_provider.dart';
import 'package:swap_style/features/gamification/screens/gamification_screen.dart';

class MockGamificationRepository extends Mock
    implements GamificationRepository {}

final _testStats = GamificationStats(
  streak: Streak(
    id: 's1',
    userId: 'u1',
    currentStreak: 5,
    longestStreak: 12,
    lastActivityAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  badges: [
    Badge(
      id: 'b1',
      slug: 'first_swap',
      name: 'First Swap',
      description: 'Completed your first swap!',
      iconUrl: '/badges/first-swap.svg',
      awardedAt: DateTime.now(),
    ),
  ],
);

ProviderContainer _makeContainer({
  AsyncValue<GamificationStats>? statsOverride,
}) {
  return ProviderContainer(
    overrides: [
      gamificationStatsProvider.overrideWith(
        (ref) async => statsOverride is AsyncData<GamificationStats>
            ? statsOverride.value
            : _testStats,
      ),
    ],
  );
}

Widget _wrap(Widget child, ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(home: child),
  );
}

void main() {
  group('GamificationScreen', () {
    testWidgets('shows streak card with current streak', (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(const GamificationScreen(), container));
      await tester.pumpAndSettle();

      expect(find.textContaining('5 days'), findsOneWidget);
      expect(find.textContaining('Best: 12'), findsOneWidget);
    });

    testWidgets('shows badge tile for each badge', (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(const GamificationScreen(), container));
      await tester.pumpAndSettle();

      expect(find.text('First Swap'), findsOneWidget);
    });

    testWidgets('shows empty state when no badges', (tester) async {
      final container = ProviderContainer(
        overrides: [
          gamificationStatsProvider.overrideWith(
            (ref) async =>
                const GamificationStats(streak: null, badges: []),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(const GamificationScreen(), container));
      await tester.pumpAndSettle();

      expect(find.textContaining('No badges earned yet'), findsOneWidget);
    });

    testWidgets('tapping badge tile shows detail dialog', (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(const GamificationScreen(), container));
      await tester.pumpAndSettle();

      await tester.tap(find.text('First Swap'));
      await tester.pumpAndSettle();

      expect(find.text('Completed your first swap!'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });
  });
}
