import 'package:flutter_test/flutter_test.dart';
import 'package:vanvoyage/domain/entities/route.dart';
import 'package:vanvoyage/domain/entities/waypoint.dart';
import 'package:vanvoyage/domain/enums/waypoint_type.dart';
import 'package:vanvoyage/domain/services/route_service.dart';
import 'package:vanvoyage/infrastructure/repositories/route_repository.dart';
import 'package:vanvoyage/infrastructure/services/mapbox_service.dart';

// Mock classes
class MockRouteRepository implements RouteRepository {
  final Map<String, Route> _routes = {};

  @override
  Future<void> insert(Route route) async {
    _routes[route.id] = route;
  }

  @override
  Future<Route?> findById(String id) async {
    return _routes[id];
  }

  @override
  Future<List<Route>> findByTripId(String tripId) async {
    return _routes.values.where((r) => r.tripId == tripId).toList();
  }

  @override
  Future<Route?> findByWaypoints(
      String fromWaypointId, String toWaypointId) async {
    try {
      return _routes.values.firstWhere(
        (r) =>
            r.fromWaypointId == fromWaypointId &&
            r.toWaypointId == toWaypointId,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> update(Route route) async {
    _routes[route.id] = route;
  }

  @override
  Future<void> delete(String id) async {
    _routes.remove(id);
  }

  @override
  Future<void> deleteByTripId(String tripId) async {
    _routes.removeWhere((key, route) => route.tripId == tripId);
  }

  @override
  Future<List<Route>> findAll() async {
    return _routes.values.toList();
  }
}

class MockMapboxService implements MapboxService {
  @override
  Future<MapboxRoute?> calculateRoute(
    double startLat,
    double startLng,
    double endLat,
    double endLng, {
    bool alternatives = false,
    RoutingProfile profile = RoutingProfile.driving,
  }) async {
    return MapboxRoute(
      geometry:
          '{"type":"LineString","coordinates":[[$startLng,$startLat],[$endLng,$endLat]]}',
      distanceMeters: 10000.0,
      durationSeconds: 600.0,
    );
  }

  @override
  Future<List<MapboxRoute>> calculateRouteWithAlternatives(
    double startLat,
    double startLng,
    double endLat,
    double endLng, {
    RoutingProfile profile = RoutingProfile.driving,
  }) async {
    return [
      MapboxRoute(
        geometry:
            '{"type":"LineString","coordinates":[[$startLng,$startLat],[$endLng,$endLat]]}',
        distanceMeters: 10000.0,
        durationSeconds: 600.0,
      ),
      MapboxRoute(
        geometry:
            '{"type":"LineString","coordinates":[[$startLng,$startLat],[$endLng,$endLat]]}',
        distanceMeters: 11000.0,
        durationSeconds: 660.0,
      ),
    ];
  }

  @override
  void dispose() {}

  @override
  Future<MapboxLocation?> geocode(String address) => throw UnimplementedError();

  @override
  Future<String?> reverseGeocode(double latitude, double longitude) =>
      throw UnimplementedError();

  @override
  Future<List<MapboxLocation>> searchPlaces(String query) =>
      throw UnimplementedError();
}

void main() {
  group('RouteService', () {
    late RouteService routeService;
    late MockRouteRepository mockRepository;
    late MockMapboxService mockMapboxService;

    setUp(() {
      mockRepository = MockRouteRepository();
      mockMapboxService = MockMapboxService();
      routeService = RouteService(mockRepository, mockMapboxService);
    });

    test('calculateRoute creates and saves route', () async {
      final waypoint1 = Waypoint.create(
        tripId: 'trip-1',
        name: 'Start',
        latitude: 37.7749,
        longitude: -122.4194,
        waypointType: WaypointType.overnightStay,
        sequenceOrder: 0,
      );

      final waypoint2 = Waypoint.create(
        tripId: 'trip-1',
        name: 'End',
        latitude: 34.0522,
        longitude: -118.2437,
        waypointType: WaypointType.overnightStay,
        sequenceOrder: 1,
      );

      final route = await routeService.calculateRoute(
        'trip-1',
        waypoint1,
        waypoint2,
      );

      expect(route, isNotNull);
      expect(route!.tripId, equals('trip-1'));
      expect(route.fromWaypointId, equals(waypoint1.id));
      expect(route.toWaypointId, equals(waypoint2.id));
      expect(route.distance, equals(10.0)); // 10000m = 10km
      expect(route.duration, equals(10)); // 600s = 10min
    });

    test('calculateRouteWithAlternatives returns multiple routes', () async {
      final waypoint1 = Waypoint.create(
        tripId: 'trip-1',
        name: 'Start',
        latitude: 37.7749,
        longitude: -122.4194,
        waypointType: WaypointType.overnightStay,
        sequenceOrder: 0,
      );

      final waypoint2 = Waypoint.create(
        tripId: 'trip-1',
        name: 'End',
        latitude: 34.0522,
        longitude: -118.2437,
        waypointType: WaypointType.overnightStay,
        sequenceOrder: 1,
      );

      final routes = await routeService.calculateRouteWithAlternatives(
        'trip-1',
        waypoint1,
        waypoint2,
      );

      expect(routes, hasLength(2));
      expect(routes[0].distance, equals(10.0));
      expect(routes[1].distance, equals(11.0));
    });

    test('getTripRouteSummary calculates total distance and duration',
        () async {
      final route1 = Route.create(
        tripId: 'trip-1',
        fromWaypointId: 'wp-1',
        toWaypointId: 'wp-2',
        geometry: '{}',
        distance: 100.0,
        duration: 60,
      );

      final route2 = Route.create(
        tripId: 'trip-1',
        fromWaypointId: 'wp-2',
        toWaypointId: 'wp-3',
        geometry: '{}',
        distance: 150.0,
        duration: 90,
      );

      await mockRepository.insert(route1);
      await mockRepository.insert(route2);

      final summary = await routeService.getTripRouteSummary('trip-1');

      expect(summary, isNotNull);
      expect(summary!.totalDistanceKm, equals(250.0));
      expect(summary.totalDurationMinutes, equals(150));
      expect(summary.routeCount, equals(2));
    });
  });

  group('TripRouteSummary', () {
    test('formats duration correctly', () {
      final summary = TripRouteSummary(
        totalDistanceKm: 100.0,
        totalDurationMinutes: 125,
        routeCount: 2,
      );

      expect(summary.totalDurationHours, equals(2));
      expect(summary.remainingMinutes, equals(5));
      expect(summary.formattedDuration, equals('2 hr 5 min'));
    });

    test('formats distance correctly', () {
      final summary1 = TripRouteSummary(
        totalDistanceKm: 123.5,
        totalDurationMinutes: 120,
        routeCount: 1,
      );

      expect(summary1.formattedDistance, equals('123.5 km'));

      final summary2 = TripRouteSummary(
        totalDistanceKm: 0.5,
        totalDurationMinutes: 10,
        routeCount: 1,
      );

      expect(summary2.formattedDistance, equals('500 m'));
    });
  });
}
