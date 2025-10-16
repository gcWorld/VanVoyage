import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanvoyage/presentation/widgets/forms/trip_form.dart';
import 'package:vanvoyage/domain/entities/trip.dart';

void main() {
  group('TripForm Widget Tests', () {
    testWidgets('renders form with all required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TripForm(
                onSubmit: (name, description, startDate, endDate, transitStart, transitEnd, locationStart, locationEnd) {},
              ),
            ),
          ),
        ),
      );

      // Verify form fields are present
      expect(find.text('Trip Name'), findsOneWidget);
      expect(find.text('Description (Optional)'), findsOneWidget);
      expect(find.text('Start Date'), findsOneWidget);
      expect(find.text('End Date'), findsOneWidget);
      expect(find.text('Create Trip'), findsOneWidget);
    });

    testWidgets('validates trip name is required', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TripForm(
                onSubmit: (name, description, startDate, endDate, transitStart, transitEnd, locationStart, locationEnd) {},
              ),
            ),
          ),
        ),
      );

      // Ensure submit button is visible and tap it without entering data
      await tester.ensureVisible(find.text('Create Trip'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Trip'));
      await tester.pumpAndSettle();

      // Verify validation error appears
      expect(find.text('Please enter a trip name'), findsOneWidget);
    });

    testWidgets('validates trip name minimum length', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TripForm(
                onSubmit: (name, description, startDate, endDate, transitStart, transitEnd, locationStart, locationEnd) {},
              ),
            ),
          ),
        ),
      );

      // Enter a name that's too short
      await tester.enterText(find.byType(TextFormField).first, 'ab');
      
      // Ensure submit button is visible before tapping
      await tester.ensureVisible(find.text('Create Trip'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Trip'));
      await tester.pumpAndSettle();

      // Verify validation error appears
      expect(find.text('Trip name must be at least 3 characters'), findsOneWidget);
    });

    testWidgets('shows edit mode for existing trip', (WidgetTester tester) async {
      final trip = Trip.create(
        name: 'Test Trip',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TripForm(
                trip: trip,
                onSubmit: (name, description, startDate, endDate, transitStart, transitEnd, locationStart, locationEnd) {},
              ),
            ),
          ),
        ),
      );

      // Verify edit mode button text
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Create Trip'), findsNothing);
      
      // Verify pre-filled name
      expect(find.text('Test Trip'), findsOneWidget);
    });

    testWidgets('displays trip duration', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TripForm(
                onSubmit: (name, description, startDate, endDate, transitStart, transitEnd, locationStart, locationEnd) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify duration is displayed (default is 8 days)
      expect(find.textContaining('Duration:'), findsOneWidget);
    });

    testWidgets('can open date picker for start date', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TripForm(
                onSubmit: (name, description, startDate, endDate, transitStart, transitEnd, locationStart, locationEnd) {},
              ),
            ),
          ),
        ),
      );

      // Find and tap the start date card
      final startDateCard = find.ancestor(
        of: find.text('Start Date'),
        matching: find.byType(ListTile),
      );
      
      await tester.tap(startDateCard);
      await tester.pumpAndSettle();

      // Verify date picker appears
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('submits form with valid data', (WidgetTester tester) async {
      String? submittedName;
      String? submittedDescription;
      DateTime? submittedStartDate;
      DateTime? submittedEndDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TripForm(
                onSubmit: (name, description, startDate, endDate, transitStart, transitEnd, locationStart, locationEnd) {
                  submittedName = name;
                  submittedDescription = description;
                  submittedStartDate = startDate;
                  submittedEndDate = endDate;
                },
              ),
            ),
          ),
        ),
      );

      // Enter valid trip name
      await tester.enterText(find.byType(TextFormField).first, 'My Trip');
      
      // Enter description
      await tester.enterText(find.byType(TextFormField).at(1), 'A great adventure');
      
      // Ensure submit button is visible before tapping
      await tester.ensureVisible(find.text('Create Trip'));
      await tester.pumpAndSettle();
      
      // Submit form
      await tester.tap(find.text('Create Trip'));
      await tester.pumpAndSettle();

      // Verify form was submitted
      expect(submittedName, 'My Trip');
      expect(submittedDescription, 'A great adventure');
      expect(submittedStartDate, isNotNull);
      expect(submittedEndDate, isNotNull);
    });
  });
}
