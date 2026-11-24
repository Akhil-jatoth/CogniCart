import 'package:flutter_test/flutter_test.dart';
import 'package:cognicart/main.dart';

void main() {
  testWidgets('CogniCart smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CogniCartApp());
    expect(find.byType(CogniCartApp), findsOneWidget);
  });
}
