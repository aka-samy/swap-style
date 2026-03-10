import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swap_style/features/items/widgets/verification_checklist.dart';
import 'package:swap_style/shared/widgets/verified_badge.dart';

void main() {
  group('VerificationChecklist', () {
    testWidgets('renders all 5 checklist items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerificationChecklist(onChanged: (_) {}),
          ),
        ),
      );
      expect(find.byType(CheckboxListTile), findsNWidgets(5));
    });

    testWidgets('shows Verified chip when all items are checked', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerificationChecklist(
              initialValues: {
                'washed': true,
                'noStains': true,
                'noTears': true,
                'noDefects': true,
                'photosAccurate': true,
              },
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('Verified'), findsOneWidget);
    });
  });

  group('VerifiedBadge', () {
    testWidgets('renders item verified badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerifiedBadge(type: BadgeType.item),
          ),
        ),
      );
      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
    });

    testWidgets('renders user verified badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerifiedBadge(type: BadgeType.user),
          ),
        ),
      );
      expect(find.text('Verified User'), findsOneWidget);
    });
  });
}
