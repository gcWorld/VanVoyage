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

    // Verify that the app shows the correct elements
    expect(find.text('VanVoyage'), findsNWidgets(2)); // AppBar + body
    expect(find.text('Trip Planning for Van Life'), findsOneWidget);
    expect(find.text('Create Trip'), findsOneWidget);
    expect(find.text('Open Map'), findsOneWidget);
  });
}
