import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swap_style/features/matching/widgets/rating_prompt.dart';
import 'package:swap_style/features/profile/widgets/ratings_list.dart';
import 'package:swap_style/core/models/rating.dart';

void main() {
  group('RatingPrompt', () {
    testWidgets('shows ratee name and disabled submit button initially',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingPrompt(
              rateeDisplayName: 'Alice',
              onSubmit: (_, __) {},
            ),
          ),
        ),
      );

      expect(find.textContaining('Alice'), findsOneWidget);
      expect(find.text('Tap to rate'), findsOneWidget);

      final submitButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Submit Rating'),
      );
      expect(submitButton.onPressed, isNull);
    });

    testWidgets('selecting stars enables submit button', (tester) async {
      int? capturedScore;
      String? capturedComment;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingPrompt(
              rateeDisplayName: 'Bob',
              onSubmit: (score, comment) {
                capturedScore = score;
                capturedComment = comment;
              },
            ),
          ),
        ),
      );

      // Tap the 4th star
      await tester.tap(find.bySemanticsLabel('Star 4'));
      await tester.pump();

      expect(find.text('Great'), findsOneWidget);

      final submitButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Submit Rating'),
      );
      expect(submitButton.onPressed, isNotNull);

      await tester.tap(find.widgetWithText(FilledButton, 'Submit Rating'));
      await tester.pump();

      expect(capturedScore, 4);
      expect(capturedComment, isNull);
    });

    testWidgets('submits comment when filled', (tester) async {
      String? capturedComment;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RatingPrompt(
                rateeDisplayName: 'Carol',
                onSubmit: (_, comment) => capturedComment = comment,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Star 5'));
      await tester.pump();

      await tester.enterText(
        find.byType(TextField),
        'Great swap experience!',
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Submit Rating'));
      await tester.pump();

      expect(capturedComment, 'Great swap experience!');
    });

    testWidgets('skip button calls onSkip callback', (tester) async {
      bool skipped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingPrompt(
              rateeDisplayName: 'Dave',
              onSubmit: (_, __) {},
              onSkip: () => skipped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Skip'));
      await tester.pump();

      expect(skipped, isTrue);
    });
  });

  group('RatingsList', () {
    final mockRatings = [
      Rating(
        id: 'r1',
        matchId: 'm1',
        raterId: 'u2',
        rateeId: 'u1',
        score: 5,
        comment: 'Excellent swap!',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        rater: const RaterSummary(
          id: 'u2',
          displayName: 'Eve',
        ),
      ),
      Rating(
        id: 'r2',
        matchId: 'm2',
        raterId: 'u3',
        rateeId: 'u1',
        score: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        rater: const RaterSummary(
          id: 'u3',
          displayName: 'Frank',
        ),
      ),
    ];

    testWidgets('shows summary card with average and total', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingsList(
              ratings: mockRatings,
              averageScore: 4.5,
              total: 2,
            ),
          ),
        ),
      );

      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('2 ratings'), findsOneWidget);
    });

    testWidgets('shows each rater name and comment', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingsList(
              ratings: mockRatings,
              averageScore: 4.5,
              total: 2,
            ),
          ),
        ),
      );

      expect(find.text('Eve'), findsOneWidget);
      expect(find.text('Frank'), findsOneWidget);
      expect(find.text('Excellent swap!'), findsOneWidget);
    });

    testWidgets('shows empty state when no ratings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const RatingsList(
              ratings: [],
              averageScore: 0,
              total: 0,
            ),
          ),
        ),
      );

      expect(find.text('No ratings yet'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const RatingsList(
              ratings: [],
              averageScore: 0,
              total: 0,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
