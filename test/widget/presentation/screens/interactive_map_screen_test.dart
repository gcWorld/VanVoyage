import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanvoyage/presentation/screens/interactive_map_screen.dart';

void main() {
  group('InteractiveMapScreen Widget Tests', () {
    testWidgets('renders map screen with app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: InteractiveMapScreen(),
          ),
        ),
      );

      // Verify app bar is present
      expect(find.text('Map'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders map controls', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: InteractiveMapScreen(),
          ),
        ),
      );

      // Wait for widget to build
      await tester.pumpAndSettle();

      // Verify map control buttons are present
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is FloatingActionButton && widget.heroTag == 'zoom_in',
        ),
        findsOneWidget,
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is FloatingActionButton && widget.heroTag == 'zoom_out',
        ),
        findsOneWidget,
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is FloatingActionButton &&
              widget.heroTag == 'center_location',
        ),
        findsOneWidget,
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is FloatingActionButton &&
              widget.heroTag == 'toggle_tracking',
        ),
        findsOneWidget,
      );
    });

    testWidgets('has correct number of floating action buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: InteractiveMapScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have 4 FABs for map controls
      expect(find.byType(FloatingActionButton), findsNWidgets(4));
    });
  });
}
