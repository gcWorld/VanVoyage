import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanvoyage/domain/entities/trip_preferences.dart';
import 'package:vanvoyage/presentation/widgets/forms/trip_preferences_form.dart';

void main() {
  group('TripPreferencesForm Widget Tests', () {
    testWidgets('renders form with all sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TripPreferencesForm(
                onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                        tolls, highways, scenic) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify section titles - some may need scrolling
      expect(find.text('Driving Preferences'), findsOneWidget);
      expect(find.text('Route Preferences'), findsOneWidget);
      
      // Note: Form now uses Column instead of ListView (for use in Stepper)
      // Elements may be off-screen in tests, so using findsWidgets check
      expect(find.text('Rest Stop Settings'), findsWidgets);
      expect(find.text('Save Preferences'), findsOneWidget);
    });

    testWidgets('displays max daily distance slider', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TripPreferencesForm(
                onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                        tolls, highways, scenic) {},
              ),
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
            body: SingleChildScrollView(
              child: TripPreferencesForm(
                onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                        tolls, highways, scenic) {},
              ),
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
            body: SingleChildScrollView(
              child: TripPreferencesForm(
                onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                        tolls, highways, scenic) {},
              ),
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
            body: SingleChildScrollView(
              child: TripPreferencesForm(
                onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                        tolls, highways, scenic) {},
              ),
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
            body: SingleChildScrollView(
              child: TripPreferencesForm(
                onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                        tolls, highways, scenic) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Note: Form now uses Column instead of ListView (for use in Stepper)
      // Verify rest stop switch
      expect(find.text('Include Rest Stops'), findsWidgets);
      
      // Since default is true, rest stop interval should be visible
      expect(find.text('Rest Stop Interval'), findsOneWidget);
    });

    testWidgets('toggles rest stop interval visibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TripPreferencesForm(
                onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                        tolls, highways, scenic) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Note: Form now uses Column instead of ListView (for use in Stepper)
      // Rest stop interval should be present
      expect(find.text('Rest Stop Interval'), findsWidgets);

      // Toggle off include rest stops (scroll to make it visible first)
      await tester.ensureVisible(find.byType(SwitchListTile).last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchListTile).last);
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
            body: SingleChildScrollView(
              child: TripPreferencesForm(
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
        ),
      );

      await tester.pumpAndSettle();

      // Note: Form now uses Column instead of ListView (for use in Stepper)
      // Tap save button (may need to use tester.ensureVisible if off-screen)
      await tester.ensureVisible(find.text('Save Preferences'));
      await tester.pumpAndSettle();
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
            body: SingleChildScrollView(
              child: SizedBox(
                height: 1200, // Force a large height to render all content
                child: TripPreferencesForm(
                  onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                          tolls, highways, scenic) {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have 4 sliders total: distance, time, speed, rest interval (when rest stops enabled)
      final allSliders = find.byType(Slider);
      expect(allSliders, findsNWidgets(4));
    });

    testWidgets('has correct number of switches', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                height: 1200, // Force a large height to render all content
                child: TripPreferencesForm(
                  onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                          tolls, highways, scenic) {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have 4 switches: avoid tolls, avoid highways, prefer scenic, include rest stops
      expect(find.byType(SwitchListTile), findsNWidgets(4));
    });

    testWidgets('displays warnings for values outside recommended range', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                height: 1400,
                child: TripPreferencesForm(
                  onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                          tolls, highways, scenic) {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially with default values, there should be no warnings
      expect(find.text('Travel Constraint Warnings'), findsNothing);
      
      // Drag the max daily distance slider to a low value (below recommended)
      final distanceSlider = find.byType(Slider).first;
      await tester.drag(distanceSlider, const Offset(-300, 0));
      await tester.pumpAndSettle();
      
      // Now there should be a warning section
      expect(find.text('Travel Constraint Warnings'), findsOneWidget);
      
      // Should have at least one warning card with warning icon
      expect(find.byIcon(Icons.warning_amber_outlined), findsWidgets);
    });

    testWidgets('displays error for extreme values', (WidgetTester tester) async {
      // Create preferences with extreme values that trigger errors
      final extremePrefs = TripPreferences.create(
        tripId: 'test-trip',
        maxDailyDrivingDistance: 1100, // Above maximum
        maxDailyDrivingTime: 750, // Above maximum (12.5 hours)
        preferredDrivingSpeed: 80,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TripPreferencesForm(
                preferences: extremePrefs,
                onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                        tolls, highways, scenic) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Should display error icons for values exceeding safe limits
      // Use skipOffstage: false to find widgets even if they're scrolled off-screen
      expect(find.byIcon(Icons.error_outline, skipOffstage: false), findsWidgets);
      expect(find.text('Travel Constraint Warnings', skipOffstage: false), findsOneWidget);
    });

    testWidgets('warnings update dynamically when values change', (WidgetTester tester) async {
      // Test with a widget that has values triggering warnings
      final prefsWithWarnings = TripPreferences.create(
        tripId: 'test-trip',
        maxDailyDrivingDistance: 200, // Below recommended (should trigger warning)
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TripPreferencesForm(
                preferences: prefsWithWarnings,
                onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                        tolls, highways, scenic) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Warning should appear for below-recommended value
      // Use skipOffstage: false to find widgets even if they're scrolled off-screen
      expect(find.text('Travel Constraint Warnings', skipOffstage: false), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_outlined, skipOffstage: false), findsWidgets);
    });

    testWidgets('displays consistency warnings', (WidgetTester tester) async {
      // Create preferences with inconsistent values
      // Distance 600 km, time 4 hours (240 min), speed 80 km/h
      // Max achievable at 80 km/h for 4 hours is 320 km, so 600 km is unreachable
      final inconsistentPrefs = TripPreferences.create(
        tripId: 'test-trip',
        maxDailyDrivingDistance: 600, // Unreachable with time and speed
        maxDailyDrivingTime: 240, // 4 hours
        preferredDrivingSpeed: 80, // 80 km/h
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TripPreferencesForm(
                preferences: inconsistentPrefs,
                onSave: (maxDistance, maxTime, speed, includeRest, interval, 
                        tolls, highways, scenic) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Should display warnings for inconsistent values
      // Use skipOffstage: false to find widgets even if they're scrolled off-screen
      expect(find.text('Travel Constraint Warnings', skipOffstage: false), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_outlined, skipOffstage: false), findsWidgets);
    });
  });
}
