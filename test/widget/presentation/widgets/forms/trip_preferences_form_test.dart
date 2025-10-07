import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanvoyage/presentation/widgets/forms/trip_preferences_form.dart';

void main() {
  group('TripPreferencesForm Widget Tests', () {
    testWidgets('renders form with all sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripPreferencesForm(
              onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                      tolls, highways, scenic) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify section titles
      expect(find.text('Driving Preferences'), findsOneWidget);
      expect(find.text('Route Preferences'), findsOneWidget);
      expect(find.text('Rest Stop Settings'), findsOneWidget);
      
      // Verify save button
      expect(find.text('Save Preferences'), findsOneWidget);
    });

    testWidgets('displays max daily distance slider', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripPreferencesForm(
              onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                      tolls, highways, scenic) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify max daily distance label
      expect(find.text('Max Daily Distance'), findsOneWidget);
      
      // Verify default value is displayed (300 km)
      expect(find.text('300 km'), findsOneWidget);
    });

    testWidgets('displays max daily driving time slider', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripPreferencesForm(
              onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                      tolls, highways, scenic) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify max daily time label
      expect(find.text('Max Daily Driving Time'), findsOneWidget);
      
      // Verify default value is displayed (4.0 hours = 240 minutes)
      expect(find.textContaining('4.0 hrs'), findsOneWidget);
    });

    testWidgets('displays preferred driving speed slider', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripPreferencesForm(
              onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                      tolls, highways, scenic) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify speed label
      expect(find.text('Preferred Driving Speed'), findsOneWidget);
      
      // Verify default value is displayed (80 km/h)
      expect(find.text('80 km/h'), findsOneWidget);
    });

    testWidgets('displays route preference switches', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripPreferencesForm(
              onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                      tolls, highways, scenic) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify route preference switches
      expect(find.text('Avoid Tolls'), findsOneWidget);
      expect(find.text('Avoid Highways'), findsOneWidget);
      expect(find.text('Prefer Scenic Routes'), findsOneWidget);
    });

    testWidgets('displays rest stop settings', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripPreferencesForm(
              onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                      tolls, highways, scenic) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify rest stop switch
      expect(find.text('Include Rest Stops'), findsOneWidget);
      
      // Since default is true, rest stop interval should be visible
      expect(find.text('Rest Stop Interval'), findsOneWidget);
    });

    testWidgets('toggles rest stop interval visibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripPreferencesForm(
              onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                      tolls, highways, scenic) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Rest stop interval should be visible initially
      expect(find.text('Rest Stop Interval'), findsOneWidget);

      // Toggle off include rest stops
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      // Rest stop interval should now be hidden
      expect(find.text('Rest Stop Interval'), findsNothing);
    });

    testWidgets('saves preferences with correct values', (WidgetTester tester) async {
      int? savedMaxDistance;
      int? savedMaxTime;
      int? savedSpeed;
      bool? savedIncludeRest;
      int? savedInterval;
      bool? savedAvoidTolls;
      bool? savedAvoidHighways;
      bool? savedPreferScenic;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripPreferencesForm(
              onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                      tolls, highways, scenic) {
                savedMaxDistance = maxDistance;
                savedMaxTime = maxTime;
                savedSpeed = speed;
                savedIncludeRest = includeRest;
                savedInterval = interval;
                savedAvoidTolls = tolls;
                savedAvoidHighways = highways;
                savedPreferScenic = scenic;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap save button
      await tester.tap(find.text('Save Preferences'));
      await tester.pumpAndSettle();

      // Verify default values were saved
      expect(savedMaxDistance, 300);
      expect(savedMaxTime, 240);
      expect(savedSpeed, 80);
      expect(savedIncludeRest, true);
      expect(savedInterval, 120);
      expect(savedAvoidTolls, false);
      expect(savedAvoidHighways, false);
      expect(savedPreferScenic, false);
    });

    testWidgets('has correct number of sliders', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripPreferencesForm(
              onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                      tolls, highways, scenic) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have 4 sliders: distance, time, speed, rest interval
      expect(find.byType(Slider), findsNWidgets(4));
    });

    testWidgets('has correct number of switches', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripPreferencesForm(
              onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                      tolls, highways, scenic) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have 4 switches: avoid tolls, avoid highways, prefer scenic, include rest stops
      expect(find.byType(SwitchListTile), findsNWidgets(4));
    });
  });
}
