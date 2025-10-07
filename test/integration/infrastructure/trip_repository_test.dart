import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vanvoyage/domain/entities/trip.dart';
import 'package:vanvoyage/domain/enums/trip_status.dart';
import 'package:vanvoyage/infrastructure/database/database_provider.dart';
import 'package:vanvoyage/infrastructure/repositories/trip_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TripRepository repository;

  setUp(() async {
    // Initialize sqflite for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Clean up and initialize database
    await DatabaseProvider.deleteDb();
    final db = await DatabaseProvider.database;
    repository = TripRepository(db);
  });

  tearDown(() async {
    await DatabaseProvider.close();
    await DatabaseProvider.deleteDb();
  });

  group('TripRepository', () {
    test('should insert and retrieve a trip', () async {
      final trip = Trip.create(
        name: 'Test Trip',
        description: 'A test trip',
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 15),
      );

      final id = await repository.insert(trip);
      expect(id, trip.id);

      final retrieved = await repository.findById(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Test Trip');
      expect(retrieved.description, 'A test trip');
    });

    test('should update an existing trip', () async {
      final trip = Trip.create(
        name: 'Original Trip',
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 15),
      );

      await repository.insert(trip);

      final updatedTrip = trip.copyWith(
        name: 'Updated Trip',
        status: TripStatus.active,
        updatedAt: DateTime.now(),
      );

      final rowsAffected = await repository.update(updatedTrip);
      expect(rowsAffected, 1);

      final retrieved = await repository.findById(trip.id);
      expect(retrieved!.name, 'Updated Trip');
      expect(retrieved.status, TripStatus.active);
    });

    test('should delete a trip', () async {
      final trip = Trip.create(
        name: 'Trip to Delete',
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 15),
      );

      await repository.insert(trip);

      final rowsAffected = await repository.delete(trip.id);
      expect(rowsAffected, 1);

      final retrieved = await repository.findById(trip.id);
      expect(retrieved, isNull);
    });

    test('should find all trips ordered by updated_at', () async {
      final trip1 = Trip.create(
        name: 'Trip 1',
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 15),
      );

      await Future.delayed(const Duration(milliseconds: 10));

      final trip2 = Trip.create(
        name: 'Trip 2',
        startDate: DateTime(2024, 7, 1),
        endDate: DateTime(2024, 7, 15),
      );

      await repository.insert(trip1);
      await repository.insert(trip2);

      final allTrips = await repository.findAll();
      expect(allTrips.length, 2);
      expect(allTrips.first.name, 'Trip 2'); // Most recent first
    });

    test('should find trips by status', () async {
      final trip1 = Trip.create(
        name: 'Planning Trip',
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 15),
        status: TripStatus.planning,
      );

      final trip2 = Trip.create(
        name: 'Active Trip',
        startDate: DateTime(2024, 7, 1),
        endDate: DateTime(2024, 7, 15),
        status: TripStatus.active,
      );

      await repository.insert(trip1);
      await repository.insert(trip2);

      final planningTrips = await repository.findByStatus(TripStatus.planning);
      expect(planningTrips.length, 1);
      expect(planningTrips.first.name, 'Planning Trip');

      final activeTrips = await repository.findByStatus(TripStatus.active);
      expect(activeTrips.length, 1);
      expect(activeTrips.first.name, 'Active Trip');
    });

    test('should find active trip', () async {
      final trip = Trip.create(
        name: 'Active Trip',
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 15),
        status: TripStatus.active,
      );

      await repository.insert(trip);

      final activeTrip = await repository.findActiveTrip();
      expect(activeTrip, isNotNull);
      expect(activeTrip!.name, 'Active Trip');
    });

    test('should count trips', () async {
      final trip1 = Trip.create(
        name: 'Trip 1',
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 15),
      );

      final trip2 = Trip.create(
        name: 'Trip 2',
        startDate: DateTime(2024, 7, 1),
        endDate: DateTime(2024, 7, 15),
      );

      await repository.insert(trip1);
      await repository.insert(trip2);

      final count = await repository.count();
      expect(count, 2);
    });

    test('should count trips by status', () async {
      final trip1 = Trip.create(
        name: 'Trip 1',
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 15),
        status: TripStatus.planning,
      );

      final trip2 = Trip.create(
        name: 'Trip 2',
        startDate: DateTime(2024, 7, 1),
        endDate: DateTime(2024, 7, 15),
        status: TripStatus.planning,
      );

      final trip3 = Trip.create(
        name: 'Trip 3',
        startDate: DateTime(2024, 8, 1),
        endDate: DateTime(2024, 8, 15),
        status: TripStatus.active,
      );

      await repository.insert(trip1);
      await repository.insert(trip2);
      await repository.insert(trip3);

      final planningCount = await repository.countByStatus(TripStatus.planning);
      expect(planningCount, 2);

      final activeCount = await repository.countByStatus(TripStatus.active);
      expect(activeCount, 1);
    });
  });
}
