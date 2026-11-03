import 'package:flutter_test/flutter_test.dart';
import 'package:simar/main.dart';

void main() {
  testWidgets('SIMAR app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SimarApp());
    expect(find.byType(SimarApp), findsOneWidget);
  });
}
