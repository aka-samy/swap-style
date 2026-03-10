import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swap_style/features/chat/screens/conversation_screen.dart';
import 'package:swap_style/features/chat/screens/chat_list_screen.dart';

void main() {
  group('ChatListScreen', () {
    testWidgets('renders empty state when no chats', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ChatListScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No conversations yet'), findsOneWidget);
    });
  });

  group('ConversationScreen', () {
    testWidgets('renders send button and input field', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ConversationScreen(
              matchId: 'match-1',
              currentUserId: 'user-1',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows empty state message when no messages', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ConversationScreen(
              matchId: 'match-1',
              currentUserId: 'user-1',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Say hello'), findsOneWidget);
    });
  });
}
