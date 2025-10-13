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

    // Wait for the app to initialize and load
    await tester.pumpAndSettle();

    // Verify that the app shows the trip list screen
    expect(find.text('My Trips'), findsOneWidget);
    
    // When no trips exist, should show empty state
    expect(find.text('No trips yet'), findsOneWidget);
    expect(find.text('Create your first trip to get started'), findsOneWidget);
    expect(find.text('Create Your First Trip'), findsOneWidget);
    
    // Should also have the FAB with "Create Trip"
    expect(find.text('Create Trip'), findsOneWidget);
  });
}
