import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello/main.dart';

void main() {
  testWidgets('App loads cleanly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: ZelloApp()));

    // Verify that the Welcome screen is showing
    expect(find.text('Welcome to Zello'), findsOneWidget);
  });
}
