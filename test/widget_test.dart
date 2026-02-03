import 'package:flutter_test/flutter_test.dart';
import 'package:salah_umma/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SalahUmmaApp());

    // Verify that the app builds without errors
    expect(find.byType(SalahUmmaApp), findsOneWidget);
  });
}
