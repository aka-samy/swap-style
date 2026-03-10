import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swap_style/main.dart';

void main() {
  testWidgets('SwapStyleApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SwapStyleApp()));
    // Just verify it doesn't crash on build
    expect(find.byType(SwapStyleApp), findsOneWidget);
  });
}
