import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vanvoyage/app.dart';

void main() {
  testWidgets('VanVoyage app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: VanVoyageApp(),
      ),
    );

    // Pump a frame to start loading
    await tester.pump();

    // Verify that the app shows the trip list screen with title
    expect(find.text('My Trips'), findsOneWidget);
    
    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // After loading, should show either empty state or trip list
    // Check for the Create Trip FAB which is always present
    expect(find.widgetWithText(FloatingActionButton, 'Create Trip'), findsOneWidget);
  });
}
