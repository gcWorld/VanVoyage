import 'package:flutter_test/flutter_test.dart';
import 'package:vanvoyage/domain/entities/trip.dart';
import 'package:vanvoyage/domain/enums/trip_status.dart';

void main() {
  group('Trip', () {
    test('should create a Trip with factory constructor', () {
      final trip = Trip.create(
        name: 'Summer Road Trip',
        description: 'A wonderful summer adventure',
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 15),
      );

      expect(trip.name, 'Summer Road Trip');
      expect(trip.description, 'A wonderful summer adventure');
      expect(trip.status, TripStatus.planning);
      expect(trip.id, isNotEmpty);
    });

    test('should validate trip with valid dates', () {
      final trip = Trip.create(
        name: 'Test Trip',
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 15),
      );

      expect(trip.isValid(), true);
    });

    test('should invalidate trip with end date before start date', () {
      final trip = Trip.create(
        name: 'Test Trip',
        startDate: DateTime(2024, 6, 15),
        endDate: DateTime(2024, 6, 1),
      );

      expect(trip.isValid(), false);
    });

    test('should serialize to and from map correctly', () {
      final originalTrip = Trip.create(
        name: 'Test Trip',
        description: 'Test Description',
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 15),
        status: TripStatus.active,
      );

      final map = originalTrip.toMap();
      final deserializedTrip = Trip.fromMap(map);

      expect(deserializedTrip.id, originalTrip.id);
      expect(deserializedTrip.name, originalTrip.name);
      expect(deserializedTrip.description, originalTrip.description);
      expect(deserializedTrip.status, originalTrip.status);
      expect(
        deserializedTrip.startDate.millisecondsSinceEpoch,
        originalTrip.startDate.millisecondsSinceEpoch,
      );
      expect(
        deserializedTrip.endDate.millisecondsSinceEpoch,
        originalTrip.endDate.millisecondsSinceEpoch,
      );
    });

    test('should create a copy with updated fields', () {
      final originalTrip = Trip.create(
        name: 'Original Trip',
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 15),
      );

      final updatedTrip = originalTrip.copyWith(
        name: 'Updated Trip',
        status: TripStatus.active,
      );

      expect(updatedTrip.name, 'Updated Trip');
      expect(updatedTrip.status, TripStatus.active);
      expect(updatedTrip.id, originalTrip.id);
      expect(updatedTrip.startDate, originalTrip.startDate);
    });

    test('should be equal when all properties match', () {
      final now = DateTime.now();
      final trip1 = Trip(
        id: '123',
        name: 'Test Trip',
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        status: TripStatus.planning,
        createdAt: now,
        updatedAt: now,
      );

      final trip2 = Trip(
        id: '123',
        name: 'Test Trip',
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        status: TripStatus.planning,
        createdAt: now,
        updatedAt: now,
      );

      expect(trip1, equals(trip2));
    });
  });

  group('TripStatus', () {
    test('should convert from string correctly', () {
      expect(TripStatus.fromString('PLANNING'), TripStatus.planning);
      expect(TripStatus.fromString('ACTIVE'), TripStatus.active);
      expect(TripStatus.fromString('COMPLETED'), TripStatus.completed);
      expect(TripStatus.fromString('ARCHIVED'), TripStatus.archived);
    });

    test('should convert to database string correctly', () {
      expect(TripStatus.planning.toDbString(), 'PLANNING');
      expect(TripStatus.active.toDbString(), 'ACTIVE');
      expect(TripStatus.completed.toDbString(), 'COMPLETED');
      expect(TripStatus.archived.toDbString(), 'ARCHIVED');
    });
  });
}
