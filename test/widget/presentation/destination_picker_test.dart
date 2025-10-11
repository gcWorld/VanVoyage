import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanvoyage/presentation/widgets/forms/destination_picker.dart';
import 'package:vanvoyage/domain/enums/waypoint_type.dart';
import 'package:vanvoyage/infrastructure/services/mapbox_service.dart';
import 'package:vanvoyage/providers.dart';

void main() {
  group('DestinationPicker Autocomplete', () {
    testWidgets('shows search field', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mapboxServiceProvider.overrideWithValue(
              MapboxService(apiKey: 'test_key'),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: DestinationPicker(
                onLocationSelected: (name, lat, lng, type) {
                  // Callback for location selection
                },
              ),
            ),
          ),
        ),
      );

      // Verify search field exists
      expect(find.byType(TextField), findsWidgets);
      expect(
        find.widgetWithText(TextField, 'Search for a place...'),
        findsOneWidget,
      );
    });

    testWidgets('shows location name field', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mapboxServiceProvider.overrideWithValue(
              MapboxService(apiKey: 'test_key'),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: DestinationPicker(
                onLocationSelected: (name, lat, lng, type) {},
              ),
            ),
          ),
        ),
      );

      // Verify location name field exists
      expect(
        find.widgetWithText(TextField, 'Enter or confirm destination name'),
        findsOneWidget,
      );
    });

    testWidgets('shows waypoint type selector', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mapboxServiceProvider.overrideWithValue(
              MapboxService(apiKey: 'test_key'),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: DestinationPicker(
                onLocationSelected: (name, lat, lng, type) {},
              ),
            ),
          ),
        ),
      );

      // Verify waypoint type selector exists
      expect(find.byType(SegmentedButton<WaypointType>), findsOneWidget);
      expect(find.text('POI'), findsOneWidget);
      expect(find.text('Stay'), findsOneWidget);
      expect(find.text('Transit'), findsOneWidget);
    });

    testWidgets('shows confirm button', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mapboxServiceProvider.overrideWithValue(
              MapboxService(apiKey: 'test_key'),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: DestinationPicker(
                onLocationSelected: (name, lat, lng, type) {},
              ),
            ),
          ),
        ),
      );

      // Verify confirm button exists
      expect(find.text('Confirm Location'), findsOneWidget);
    });

    testWidgets('shows manual coordinate entry button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mapboxServiceProvider.overrideWithValue(
              MapboxService(apiKey: 'test_key'),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: DestinationPicker(
                onLocationSelected: (name, lat, lng, type) {},
              ),
            ),
          ),
        ),
      );

      // Verify manual entry button exists
      expect(
        find.text('Enter Coordinates Manually'),
        findsOneWidget,
      );
    });
  });
}
