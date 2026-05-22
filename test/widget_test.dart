import 'package:flutter_test/flutter_test.dart';
import 'package:bmi_tracker/app/app.dart';

void main() {
  testWidgets('App renders with root widget', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('Splash Page'), findsOneWidget);
  });
}
