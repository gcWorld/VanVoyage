import 'package:flutter_test/flutter_test.dart';
import 'package:vanvoyage/domain/entities/waypoint.dart';
import 'package:vanvoyage/domain/enums/waypoint_type.dart';

void main() {
  group('Waypoint', () {
    test('should create a Waypoint with factory constructor', () {
      final waypoint = Waypoint.create(
        tripId: 'trip-123',
        name: 'Grand Canyon',
        latitude: 36.1069,
        longitude: -112.1129,
        waypointType: WaypointType.poi,
        sequenceOrder: 0,
      );

      expect(waypoint.name, 'Grand Canyon');
      expect(waypoint.tripId, 'trip-123');
      expect(waypoint.waypointType, WaypointType.poi);
      expect(waypoint.id, isNotEmpty);
    });

    test('should validate waypoint with valid coordinates', () {
      final waypoint = Waypoint.create(
        tripId: 'trip-123',
        name: 'Valid Location',
        latitude: 45.0,
        longitude: -100.0,
        waypointType: WaypointType.poi,
        sequenceOrder: 0,
      );

      expect(waypoint.isValid(), true);
    });

    test('should invalidate waypoint with invalid latitude', () {
      final waypoint = Waypoint.create(
        tripId: 'trip-123',
        name: 'Invalid Location',
        latitude: 91.0, // Invalid latitude
        longitude: -100.0,
        waypointType: WaypointType.poi,
        sequenceOrder: 0,
      );

      expect(waypoint.isValid(), false);
    });

    test('should invalidate waypoint with invalid longitude', () {
      final waypoint = Waypoint.create(
        tripId: 'trip-123',
        name: 'Invalid Location',
        latitude: 45.0,
        longitude: -181.0, // Invalid longitude
        waypointType: WaypointType.poi,
        sequenceOrder: 0,
      );

      expect(waypoint.isValid(), false);
    });

    test('should validate overnight stay with stay duration', () {
      final waypoint = Waypoint.create(
        tripId: 'trip-123',
        name: 'Campsite',
        latitude: 45.0,
        longitude: -100.0,
        waypointType: WaypointType.overnightStay,
        stayDuration: 2,
        sequenceOrder: 0,
      );

      expect(waypoint.isValid(), true);
    });

    test('should invalidate overnight stay without stay duration', () {
      final waypoint = Waypoint.create(
        tripId: 'trip-123',
        name: 'Campsite',
        latitude: 45.0,
        longitude: -100.0,
        waypointType: WaypointType.overnightStay,
        sequenceOrder: 0,
      );

      expect(waypoint.isValid(), false);
    });

    test('should serialize to and from map correctly', () {
      final originalWaypoint = Waypoint.create(
        tripId: 'trip-123',
        phaseId: 'phase-456',
        name: 'Test Location',
        description: 'A test location',
        latitude: 36.1069,
        longitude: -112.1129,
        address: '123 Test St',
        waypointType: WaypointType.poi,
        sequenceOrder: 1,
        estimatedDrivingTime: 120,
        estimatedDistance: 150.5,
      );

      final map = originalWaypoint.toMap();
      final deserializedWaypoint = Waypoint.fromMap(map);

      expect(deserializedWaypoint.id, originalWaypoint.id);
      expect(deserializedWaypoint.tripId, originalWaypoint.tripId);
      expect(deserializedWaypoint.phaseId, originalWaypoint.phaseId);
      expect(deserializedWaypoint.name, originalWaypoint.name);
      expect(deserializedWaypoint.latitude, originalWaypoint.latitude);
      expect(deserializedWaypoint.longitude, originalWaypoint.longitude);
      expect(deserializedWaypoint.waypointType, originalWaypoint.waypointType);
    });

    test('should create a copy with updated fields', () {
      final originalWaypoint = Waypoint.create(
        tripId: 'trip-123',
        name: 'Original Location',
        latitude: 36.1069,
        longitude: -112.1129,
        waypointType: WaypointType.poi,
        sequenceOrder: 0,
      );

      final updatedWaypoint = originalWaypoint.copyWith(
        name: 'Updated Location',
        description: 'New description',
      );

      expect(updatedWaypoint.name, 'Updated Location');
      expect(updatedWaypoint.description, 'New description');
      expect(updatedWaypoint.id, originalWaypoint.id);
      expect(updatedWaypoint.latitude, originalWaypoint.latitude);
    });
  });

  group('WaypointType', () {
    test('should convert from string correctly', () {
      expect(
        WaypointType.fromString('OVERNIGHT_STAY'),
        WaypointType.overnightStay,
      );
      expect(WaypointType.fromString('POI'), WaypointType.poi);
      expect(WaypointType.fromString('TRANSIT'), WaypointType.transit);
    });

    test('should convert to database string correctly', () {
      expect(WaypointType.overnightStay.toDbString(), 'OVERNIGHT_STAY');
      expect(WaypointType.poi.toDbString(), 'POI');
      expect(WaypointType.transit.toDbString(), 'TRANSIT');
    });
  });
}
