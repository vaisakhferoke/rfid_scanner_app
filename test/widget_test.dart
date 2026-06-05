// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:event_rfid_app/controllers/battery_controller.dart';
import 'package:event_rfid_app/controllers/range_controller.dart';
import 'package:event_rfid_app/screens/main_navigation_screen.dart';

void main() {
  late BatteryController batteryController;
  late RangeController rangeController;

  setUp(() {
    // Clear GetX registry
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('App loads Home screen successfully smoke test', (WidgetTester tester) async {
    // Initialize dependencies required by MainNavigationScreen and HomeScreen
    batteryController = Get.put(BatteryController());
    rangeController = Get.put(RangeController());

    // Build our navigation screen directly, bypassing the splash screen timer.
    await tester.pumpWidget(
      GetMaterialApp(
        home: MainNavigationScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that the Home screen loads and shows the "Home" title.
    expect(find.text('Home'), findsAtLeastNWidgets(1));
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Recent Activity'), findsOneWidget);

    // Clean up inside the testWidgets body (in the same async zone)
    batteryController.onClose();
    rangeController.onClose();
  });
}
