// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:event_rfid_app/main.dart';

void main() {
  testWidgets('App loads Home screen successfully smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the Home screen loads and shows the "Home" title.
    expect(find.text('Home'), findsAtLeastNWidgets(1));
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Recent Activity'), findsOneWidget);
  });
}
