#!/usr/bin/env dart

/// Simple validation script to test domain models
/// Run with: dart run scripts/validate_models.dart

import '../lib/domain/entities/trip.dart';
import '../lib/domain/entities/waypoint.dart';
import '../lib/domain/entities/trip_phase.dart';
import '../lib/domain/entities/activity.dart';
import '../lib/domain/entities/trip_preferences.dart';
import '../lib/domain/entities/route.dart';
import '../lib/domain/enums/trip_status.dart';
import '../lib/domain/enums/waypoint_type.dart';
import '../lib/domain/enums/phase_type.dart';
import '../lib/domain/enums/activity_category.dart';
import '../lib/domain/enums/priority.dart';

void main() {
  print('🚀 Validating VanVoyage Domain Models...\n');

  // Test Trip creation and serialization
  print('✅ Testing Trip entity...');
  final trip = Trip.create(
    name: 'Summer Road Trip',
    description: 'A wonderful summer adventure',
    startDate: DateTime(2024, 6, 1),
    endDate: DateTime(2024, 6, 15),
    status: TripStatus.planning,
  );
  
  assert(trip.name == 'Summer Road Trip');
  assert(trip.isValid(), 'Trip should be valid');
  
  final tripMap = trip.toMap();
  final deserializedTrip = Trip.fromMap(tripMap);
  assert(deserializedTrip.id == trip.id);
  print('   ✓ Trip creation, validation, and serialization work correctly');

  // Test Waypoint creation and serialization
  print('✅ Testing Waypoint entity...');
  final waypoint = Waypoint.create(
    tripId: trip.id,
    name: 'Grand Canyon',
    latitude: 36.1069,
    longitude: -112.1129,
    waypointType: WaypointType.poi,
    sequenceOrder: 0,
  );
  
  assert(waypoint.name == 'Grand Canyon');
  assert(waypoint.isValid(), 'Waypoint should be valid');
  
  final waypointMap = waypoint.toMap();
  final deserializedWaypoint = Waypoint.fromMap(waypointMap);
  assert(deserializedWaypoint.id == waypoint.id);
  print('   ✓ Waypoint creation, validation, and serialization work correctly');

  // Test TripPhase creation and serialization
  print('✅ Testing TripPhase entity...');
  final phase = TripPhase.create(
    tripId: trip.id,
    name: 'Outbound Journey',
    phaseType: PhaseType.outbound,
    startDate: DateTime(2024, 6, 1),
    endDate: DateTime(2024, 6, 5),
    sequenceOrder: 0,
  );
  
  assert(phase.name == 'Outbound Journey');
  
  final phaseMap = phase.toMap();
  final deserializedPhase = TripPhase.fromMap(phaseMap);
  assert(deserializedPhase.id == phase.id);
  print('   ✓ TripPhase creation and serialization work correctly');

  // Test Activity creation and serialization
  print('✅ Testing Activity entity...');
  final activity = Activity.create(
    waypointId: waypoint.id,
    name: 'Hiking Bright Angel Trail',
    category: ActivityCategory.hiking,
    priority: Priority.high,
    estimatedDuration: 240,
  );
  
  assert(activity.name == 'Hiking Bright Angel Trail');
  
  final activityMap = activity.toMap();
  final deserializedActivity = Activity.fromMap(activityMap);
  assert(deserializedActivity.id == activity.id);
  print('   ✓ Activity creation and serialization work correctly');

  // Test TripPreferences creation and serialization
  print('✅ Testing TripPreferences entity...');
  final prefs = TripPreferences.create(
    tripId: trip.id,
    maxDailyDrivingDistance: 300,
    preferScenicRoutes: true,
  );
  
  assert(prefs.maxDailyDrivingDistance == 300);
  assert(prefs.preferScenicRoutes == true);
  
  final prefsMap = prefs.toMap();
  final deserializedPrefs = TripPreferences.fromMap(prefsMap);
  assert(deserializedPrefs.id == prefs.id);
  print('   ✓ TripPreferences creation and serialization work correctly');

  // Test Route creation and serialization
  print('✅ Testing Route entity...');
  final route = Route.create(
    tripId: trip.id,
    fromWaypointId: 'waypoint-1',
    toWaypointId: 'waypoint-2',
    geometry: '{"type":"LineString","coordinates":[[-112.1,36.1],[-111.9,36.2]]}',
    distance: 125.5,
    duration: 90,
  );
  
  assert(route.isValid(), 'Route should be valid');
  
  final routeMap = route.toMap();
  final deserializedRoute = Route.fromMap(routeMap);
  assert(deserializedRoute.id == route.id);
  print('   ✓ Route creation, validation, and serialization work correctly');

  // Test enum conversions
  print('✅ Testing enum conversions...');
  assert(TripStatus.fromString('PLANNING') == TripStatus.planning);
  assert(TripStatus.active.toDbString() == 'ACTIVE');
  
  assert(WaypointType.fromString('OVERNIGHT_STAY') == WaypointType.overnightStay);
  assert(WaypointType.poi.toDbString() == 'POI');
  
  assert(PhaseType.fromString('OUTBOUND') == PhaseType.outbound);
  assert(PhaseType.exploration.toDbString() == 'EXPLORATION');
  
  assert(ActivityCategory.fromString('HIKING') == ActivityCategory.hiking);
  assert(ActivityCategory.sightseeing.toDbString() == 'SIGHTSEEING');
  
  assert(Priority.fromString('HIGH') == Priority.high);
  assert(Priority.medium.toDbString() == 'MEDIUM');
  print('   ✓ All enum conversions work correctly');

  // Test validation edge cases
  print('✅ Testing validation edge cases...');
  
  final invalidTrip = Trip.create(
    name: 'Invalid Trip',
    startDate: DateTime(2024, 6, 15),
    endDate: DateTime(2024, 6, 1), // End before start
  );
  assert(!invalidTrip.isValid(), 'Invalid trip should fail validation');
  
  final invalidWaypoint = Waypoint.create(
    tripId: trip.id,
    name: 'Invalid Location',
    latitude: 91.0, // Invalid latitude
    longitude: -100.0,
    waypointType: WaypointType.poi,
    sequenceOrder: 0,
  );
  assert(!invalidWaypoint.isValid(), 'Invalid waypoint should fail validation');
  
  final invalidRoute = Route.create(
    tripId: trip.id,
    fromWaypointId: 'same-id',
    toWaypointId: 'same-id', // Same waypoint
    geometry: '{}',
    distance: 0,
    duration: 0,
  );
  assert(!invalidRoute.isValid(), 'Invalid route should fail validation');
  print('   ✓ Validation edge cases handled correctly');

  print('\n✨ All validations passed! Domain models are working correctly.\n');
}
