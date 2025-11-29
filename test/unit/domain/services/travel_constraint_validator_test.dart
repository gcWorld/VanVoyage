import 'package:flutter_test/flutter_test.dart';
import 'package:vanvoyage/domain/entities/constraint_violation.dart';
import 'package:vanvoyage/domain/entities/travel_constraint.dart';
import 'package:vanvoyage/domain/entities/trip_preferences.dart';
import 'package:vanvoyage/domain/services/travel_constraint_validator.dart';

void main() {
  group('TravelConstraintValidator', () {
    late TravelConstraintValidator validator;

    setUp(() {
      validator = const TravelConstraintValidator();
    });

    group('validate daily distance', () {
      test('should return no violations for valid distance', () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          maxDailyDrivingDistance: 400,
        );

        final violations = validator.validate(prefs);
        final distanceViolations = violations
            .where((v) => v.field == 'maxDailyDrivingDistance')
            .toList();

        expect(distanceViolations, isEmpty);
      });

      test('should return warning for distance below recommended range', () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          maxDailyDrivingDistance: 200,
        );

        final violations = validator.validate(prefs);
        final distanceViolations = violations
            .where((v) => v.field == 'maxDailyDrivingDistance')
            .toList();

        expect(distanceViolations, hasLength(1));
        expect(distanceViolations.first.severity, ViolationSeverity.warning);
        expect(distanceViolations.first.message,
            contains('below recommended range'));
      });

      test('should return warning for distance above recommended range', () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          maxDailyDrivingDistance: 600,
        );

        final violations = validator.validate(prefs);
        final distanceViolations = violations
            .where((v) => v.field == 'maxDailyDrivingDistance')
            .toList();

        expect(distanceViolations, hasLength(1));
        expect(distanceViolations.first.severity, ViolationSeverity.warning);
        expect(distanceViolations.first.message,
            contains('above recommended range'));
      });

      test('should return error for distance below minimum', () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          maxDailyDrivingDistance: 30,
        );

        final violations = validator.validate(prefs);
        final distanceViolations = violations
            .where((v) => v.field == 'maxDailyDrivingDistance')
            .toList();

        expect(distanceViolations, hasLength(1));
        expect(distanceViolations.first.severity, ViolationSeverity.error);
        expect(distanceViolations.first.message, contains('too low'));
      });

      test('should return error for distance above maximum', () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          maxDailyDrivingDistance: 1100,
        );

        final violations = validator.validate(prefs);
        final distanceViolations = violations
            .where((v) => v.field == 'maxDailyDrivingDistance')
            .toList();

        expect(distanceViolations, hasLength(1));
        expect(distanceViolations.first.severity, ViolationSeverity.error);
        expect(
            distanceViolations.first.message, contains('exceeds safe limit'));
      });
    });

    group('validate daily driving time', () {
      test('should return no violations for valid time', () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          maxDailyDrivingTime: 240, // 4 hours
        );

        final violations = validator.validate(prefs);
        final timeViolations =
            violations.where((v) => v.field == 'maxDailyDrivingTime').toList();

        expect(timeViolations, isEmpty);
      });

      test('should return warning for time below recommended range', () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          maxDailyDrivingTime: 120, // 2 hours
        );

        final violations = validator.validate(prefs);
        final timeViolations =
            violations.where((v) => v.field == 'maxDailyDrivingTime').toList();

        expect(timeViolations, hasLength(1));
        expect(timeViolations.first.severity, ViolationSeverity.warning);
        expect(
            timeViolations.first.message, contains('below recommended range'));
      });

      test('should return warning for time above recommended range', () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          maxDailyDrivingTime: 420, // 7 hours
        );

        final violations = validator.validate(prefs);
        final timeViolations =
            violations.where((v) => v.field == 'maxDailyDrivingTime').toList();

        expect(timeViolations, hasLength(1));
        expect(timeViolations.first.severity, ViolationSeverity.warning);
        expect(
            timeViolations.first.message, contains('above recommended range'));
      });

      test('should return error for time above maximum', () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          maxDailyDrivingTime: 750, // 12.5 hours
        );

        final violations = validator.validate(prefs);
        final timeViolations =
            violations.where((v) => v.field == 'maxDailyDrivingTime').toList();

        expect(timeViolations, hasLength(1));
        expect(timeViolations.first.severity, ViolationSeverity.error);
        expect(timeViolations.first.message, contains('exceeds safe limit'));
      });
    });

    group('validate driving speed', () {
      test('should return no violations for normal speed', () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          preferredDrivingSpeed: 80,
        );

        final violations = validator.validate(prefs);
        final speedViolations = violations
            .where((v) => v.field == 'preferredDrivingSpeed')
            .toList();

        expect(speedViolations, isEmpty);
      });

      test('should return warning for very low speed', () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          preferredDrivingSpeed: 35,
        );

        final violations = validator.validate(prefs);
        final speedViolations = violations
            .where((v) => v.field == 'preferredDrivingSpeed')
            .toList();

        expect(speedViolations, hasLength(1));
        expect(speedViolations.first.severity, ViolationSeverity.warning);
        expect(speedViolations.first.message, contains('very slow'));
      });

      test('should return warning for very high speed', () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          preferredDrivingSpeed: 135,
        );

        final violations = validator.validate(prefs);
        final speedViolations = violations
            .where((v) => v.field == 'preferredDrivingSpeed')
            .toList();

        expect(speedViolations, hasLength(1));
        expect(speedViolations.first.severity, ViolationSeverity.warning);
        expect(speedViolations.first.message, contains('very high'));
      });
    });

    group('validate rest stop interval', () {
      test('should return no violations for valid interval', () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          includeRestStops: true,
          restStopInterval: 120, // 2 hours
        );

        final violations = validator.validate(prefs);
        final restViolations =
            violations.where((v) => v.field == 'restStopInterval').toList();

        expect(restViolations, isEmpty);
      });

      test('should return warning for too frequent rest stops', () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          includeRestStops: true,
          restStopInterval: 20, // 20 minutes
        );

        final violations = validator.validate(prefs);
        final restViolations =
            violations.where((v) => v.field == 'restStopInterval').toList();

        expect(restViolations, isNotEmpty);
        expect(restViolations.first.severity, ViolationSeverity.warning);
        expect(restViolations.first.message, contains('too frequent'));
      });

      test('should return error for too long interval', () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          includeRestStops: true,
          restStopInterval: 400, // 6.67 hours
        );

        final violations = validator.validate(prefs);
        final restViolations =
            violations.where((v) => v.field == 'restStopInterval').toList();

        expect(restViolations, isNotEmpty);
        expect(restViolations.first.severity, ViolationSeverity.error);
        expect(restViolations.first.message, contains('too long'));
      });

      test('should not validate rest interval when disabled', () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          includeRestStops: false,
          restStopInterval: null,
        );

        final violations = validator.validate(prefs);
        final restViolations =
            violations.where((v) => v.field == 'restStopInterval').toList();

        expect(restViolations, isEmpty);
      });
    });

    group('validate consistency', () {
      test('should warn when distance is unreachable with given time and speed',
          () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          maxDailyDrivingDistance: 600, // 600 km
          maxDailyDrivingTime: 240, // 4 hours
          preferredDrivingSpeed: 80, // 80 km/h - max achievable is 320 km
        );

        final violations = validator.validate(prefs);
        final consistencyViolations =
            violations.where((v) => v.field == 'consistency').toList();

        expect(consistencyViolations, hasLength(1));
        expect(consistencyViolations.first.severity, ViolationSeverity.warning);
        expect(consistencyViolations.first.message, contains('unreachable'));
      });

      test('should warn when rest interval exceeds daily driving time', () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          maxDailyDrivingTime: 180, // 3 hours
          includeRestStops: true,
          restStopInterval: 200, // 3.33 hours
        );

        final violations = validator.validate(prefs);
        final restViolations = violations
            .where((v) =>
                v.field == 'restStopInterval' &&
                v.message.contains('daily driving time'))
            .toList();

        expect(restViolations, hasLength(1));
        expect(restViolations.first.severity, ViolationSeverity.warning);
      });
    });

    group('helper methods', () {
      test('hasErrors should return true when there are error violations', () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          maxDailyDrivingDistance: 1200, // Too high
        );

        final violations = validator.validate(prefs);

        expect(validator.hasErrors(violations), true);
      });

      test('hasWarnings should return true when there are warning violations',
          () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          maxDailyDrivingDistance: 250, // Below recommended
        );

        final violations = validator.validate(prefs);

        expect(validator.hasWarnings(violations), true);
      });

      test('getViolationsBySeverity should filter violations correctly', () {
        final prefs = TripPreferences.create(
          tripId: 'test',
          maxDailyDrivingDistance: 250, // Warning
          maxDailyDrivingTime: 750, // Error
        );

        final violations = validator.validate(prefs);
        final errors = validator.getViolationsBySeverity(
            violations, ViolationSeverity.error);
        final warnings = validator.getViolationsBySeverity(
            violations, ViolationSeverity.warning);

        expect(errors, isNotEmpty);
        expect(warnings, isNotEmpty);
        expect(
            errors.every((v) => v.severity == ViolationSeverity.error), true);
        expect(warnings.every((v) => v.severity == ViolationSeverity.warning),
            true);
      });
    });
  });
}
