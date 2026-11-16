import 'package:flutter_test/flutter_test.dart';
import 'package:azhly/main.dart';

void main() {
  testWidgets('AZHly app starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const AzhlyApp());
    await tester.pump();

    expect(find.byType(AzhlyApp), findsOneWidget);
  });
}
