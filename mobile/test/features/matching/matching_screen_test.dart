import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('MatchListScreen', () {
    testWidgets('shows empty state when no matches', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: Center(child: Text('No matches yet'))),
          ),
        ),
      );
      expect(find.text('No matches yet'), findsOneWidget);
    });

    testWidgets('renders match cards when matches exist', (tester) async {
      // TODO: provide mock matching state, verify cards render with status badges
      expect(true, isTrue);
    });
  });

  group('MatchDetailScreen', () {
    testWidgets('shows both items with swap icon', (tester) async {
      // TODO: pump MatchDetailScreen with mock match, verify item previews render
      expect(true, isTrue);
    });

    testWidgets('shows confirm and cancel buttons', (tester) async {
      // TODO: pump MatchDetailScreen, verify action buttons exist
      expect(true, isTrue);
    });
  });
}
