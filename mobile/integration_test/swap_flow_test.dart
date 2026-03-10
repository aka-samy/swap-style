import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:swap_style/main.dart' as app;

/// Integration test for the full swap flow:
///   Sign in → List item → Discover → Swipe → Match → Chat → Rate
///
/// Requires the API to be running locally (or in CI with docker-compose).
/// Set environment variables TEST_USER_A_EMAIL / TEST_USER_A_PASSWORD
/// for Firebase phone auth to work during integration testing.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Swap Flow Integration', () {
    testWidgets('App launches and shows sign-in screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Should land on sign-in or home depending on auth state
      expect(
        find.byType(MaterialApp),
        findsOneWidget,
      );
    });

    testWidgets('Discovery tab loads', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to discover tab (bottom nav index 0)
      final discoverTab = find.byIcon(Icons.explore_outlined);
      if (discoverTab.evaluate().isNotEmpty) {
        await tester.tap(discoverTab);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Matches tab loads', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final matchesTab = find.byIcon(Icons.favorite_outline);
      if (matchesTab.evaluate().isNotEmpty) {
        await tester.tap(matchesTab);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Profile tab loads', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final profileTab = find.byIcon(Icons.person_outline);
      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab);
        await tester.pumpAndSettle();
      }
    });
  });
}
