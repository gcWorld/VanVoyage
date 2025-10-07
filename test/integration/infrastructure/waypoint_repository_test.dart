import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vanvoyage/domain/entities/trip.dart';
import 'package:vanvoyage/domain/entities/waypoint.dart';
import 'package:vanvoyage/domain/enums/waypoint_type.dart';
import 'package:vanvoyage/infrastructure/database/database_provider.dart';
import 'package:vanvoyage/infrastructure/repositories/trip_repository.dart';
import 'package:vanvoyage/infrastructure/repositories/waypoint_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TripRepository tripRepository;
  late WaypointRepository waypointRepository;
  late Trip testTrip;

  setUp(() async {
    // Initialize sqflite for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Clean up and initialize database
    await DatabaseProvider.deleteDb();
    final db = await DatabaseProvider.database;
    tripRepository = TripRepository(db);
    waypointRepository = WaypointRepository(db);

    // Create a test trip
    testTrip = Trip.create(
      name: 'Test Trip',
      startDate: DateTime(2024, 6, 1),
      endDate: DateTime(2024, 6, 15),
    );
    await tripRepository.insert(testTrip);
  });

  tearDown(() async {
    await DatabaseProvider.close();
    await DatabaseProvider.deleteDb();
  });

  group('WaypointRepository', () {
    test('should insert and retrieve a waypoint', () async {
      final waypoint = Waypoint.create(
        tripId: testTrip.id,
        name: 'Grand Canyon',
        latitude: 36.1069,
        longitude: -112.1129,
        waypointType: WaypointType.poi,
        sequenceOrder: 0,
      );

      final id = await waypointRepository.insert(waypoint);
      expect(id, waypoint.id);

      final retrieved = await waypointRepository.findById(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Grand Canyon');
      expect(retrieved.latitude, 36.1069);
      expect(retrieved.longitude, -112.1129);
    });

    test('should update an existing waypoint', () async {
      final waypoint = Waypoint.create(
        tripId: testTrip.id,
        name: 'Original Location',
        latitude: 36.1069,
        longitude: -112.1129,
        waypointType: WaypointType.poi,
        sequenceOrder: 0,
      );

      await waypointRepository.insert(waypoint);

      final updatedWaypoint = waypoint.copyWith(
        name: 'Updated Location',
        description: 'New description',
      );

      final rowsAffected = await waypointRepository.update(updatedWaypoint);
      expect(rowsAffected, 1);

      final retrieved = await waypointRepository.findById(waypoint.id);
      expect(retrieved!.name, 'Updated Location');
      expect(retrieved.description, 'New description');
    });

    test('should delete a waypoint', () async {
      final waypoint = Waypoint.create(
        tripId: testTrip.id,
        name: 'Location to Delete',
        latitude: 36.1069,
        longitude: -112.1129,
        waypointType: WaypointType.poi,
        sequenceOrder: 0,
      );

      await waypointRepository.insert(waypoint);

      final rowsAffected = await waypointRepository.delete(waypoint.id);
      expect(rowsAffected, 1);

      final retrieved = await waypointRepository.findById(waypoint.id);
      expect(retrieved, isNull);
    });

    test('should find waypoints by trip ID', () async {
      final waypoint1 = Waypoint.create(
        tripId: testTrip.id,
        name: 'Location 1',
        latitude: 36.1069,
        longitude: -112.1129,
        waypointType: WaypointType.poi,
        sequenceOrder: 0,
      );

      final waypoint2 = Waypoint.create(
        tripId: testTrip.id,
        name: 'Location 2',
        latitude: 37.7749,
        longitude: -122.4194,
        waypointType: WaypointType.poi,
        sequenceOrder: 1,
      );

      await waypointRepository.insert(waypoint1);
      await waypointRepository.insert(waypoint2);

      final waypoints = await waypointRepository.findByTripId(testTrip.id);
      expect(waypoints.length, 2);
      expect(waypoints.first.sequenceOrder, 0);
      expect(waypoints.last.sequenceOrder, 1);
    });

    test('should find waypoints by type', () async {
      final poi = Waypoint.create(
        tripId: testTrip.id,
        name: 'POI',
        latitude: 36.1069,
        longitude: -112.1129,
        waypointType: WaypointType.poi,
        sequenceOrder: 0,
      );

      final overnight = Waypoint.create(
        tripId: testTrip.id,
        name: 'Campsite',
        latitude: 37.7749,
        longitude: -122.4194,
        waypointType: WaypointType.overnightStay,
        stayDuration: 2,
        sequenceOrder: 1,
      );

      await waypointRepository.insert(poi);
      await waypointRepository.insert(overnight);

      final pois = await waypointRepository.findByType(
        testTrip.id,
        WaypointType.poi,
      );
      expect(pois.length, 1);
      expect(pois.first.name, 'POI');

      final overnights = await waypointRepository.findOvernightStays(testTrip.id);
      expect(overnights.length, 1);
      expect(overnights.first.name, 'Campsite');
    });

    test('should count waypoints by trip ID', () async {
      final waypoint1 = Waypoint.create(
        tripId: testTrip.id,
        name: 'Location 1',
        latitude: 36.1069,
        longitude: -112.1129,
        waypointType: WaypointType.poi,
        sequenceOrder: 0,
      );

      final waypoint2 = Waypoint.create(
        tripId: testTrip.id,
        name: 'Location 2',
        latitude: 37.7749,
        longitude: -122.4194,
        waypointType: WaypointType.poi,
        sequenceOrder: 1,
      );

      await waypointRepository.insert(waypoint1);
      await waypointRepository.insert(waypoint2);

      final count = await waypointRepository.countByTripId(testTrip.id);
      expect(count, 2);
    });

    test('should get next sequence order', () async {
      final waypoint1 = Waypoint.create(
        tripId: testTrip.id,
        name: 'Location 1',
        latitude: 36.1069,
        longitude: -112.1129,
        waypointType: WaypointType.poi,
        sequenceOrder: 0,
      );

      await waypointRepository.insert(waypoint1);

      final nextOrder = await waypointRepository.getNextSequenceOrder(testTrip.id);
      expect(nextOrder, 1);
    });

    test('should cascade delete waypoints when trip is deleted', () async {
      final waypoint = Waypoint.create(
        tripId: testTrip.id,
        name: 'Location',
        latitude: 36.1069,
        longitude: -112.1129,
        waypointType: WaypointType.poi,
        sequenceOrder: 0,
      );

      await waypointRepository.insert(waypoint);

      // Delete the trip
      await tripRepository.delete(testTrip.id);

      // Waypoint should be deleted due to foreign key constraint
      final retrieved = await waypointRepository.findById(waypoint.id);
      expect(retrieved, isNull);
    });
  });
}
