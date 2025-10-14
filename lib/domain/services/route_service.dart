import '../../infrastructure/repositories/route_repository.dart';
import '../../infrastructure/services/mapbox_service.dart';
import '../entities/route.dart' as domain;
import '../entities/waypoint.dart';

/// Service for calculating and managing routes
class RouteService {
  final RouteRepository _routeRepository;
  final MapboxService _mapboxService;

  RouteService(this._routeRepository, this._mapboxService);

  /// Calculate route between two waypoints
  Future<domain.Route?> calculateRoute(
    String tripId,
    Waypoint fromWaypoint,
    Waypoint toWaypoint, {
    bool forceRefresh = false,
    RoutingProfile profile = RoutingProfile.driving,
  }) async {
    // Check cache first if not forcing refresh
    if (!forceRefresh) {
      final cachedRoute = await _routeRepository.findByWaypoints(
        fromWaypoint.id,
        toWaypoint.id,
      );

      // Return cached route if it's less than 7 days old
      if (cachedRoute != null) {
        final age = DateTime.now().difference(cachedRoute.calculatedAt);
        if (age.inDays < 7) {
          return cachedRoute;
        }
      }
    }

    // Calculate new route
    final mapboxRoute = await _mapboxService.calculateRoute(
      fromWaypoint.latitude,
      fromWaypoint.longitude,
      toWaypoint.latitude,
      toWaypoint.longitude,
      profile: profile,
    );

    if (mapboxRoute == null) {
      return null;
    }

    // Create and save route entity
    final route = domain.Route.create(
      tripId: tripId,
      fromWaypointId: fromWaypoint.id,
      toWaypointId: toWaypoint.id,
      geometry: mapboxRoute.geometry,
      distance: mapboxRoute.distanceKm,
      duration: mapboxRoute.durationMinutes,
    );

    await _routeRepository.insert(route);
    return route;
  }

  /// Calculate route with alternatives
  Future<List<domain.Route>> calculateRouteWithAlternatives(
    String tripId,
    Waypoint fromWaypoint,
    Waypoint toWaypoint, {
    RoutingProfile profile = RoutingProfile.driving,
  }) async {
    final mapboxRoutes = await _mapboxService.calculateRouteWithAlternatives(
      fromWaypoint.latitude,
      fromWaypoint.longitude,
      toWaypoint.latitude,
      toWaypoint.longitude,
      profile: profile,
    );

    final routes = <domain.Route>[];
    for (final mapboxRoute in mapboxRoutes) {
      final route = domain.Route.create(
        tripId: tripId,
        fromWaypointId: fromWaypoint.id,
        toWaypointId: toWaypoint.id,
        geometry: mapboxRoute.geometry,
        distance: mapboxRoute.distanceKm,
        duration: mapboxRoute.durationMinutes,
      );
      routes.add(route);
    }

    // Save the primary (first) route
    if (routes.isNotEmpty) {
      await _routeRepository.insert(routes.first);
    }

    return routes;
  }

  /// Calculate routes for entire trip
  Future<List<domain.Route>> calculateTripRoute(
    String tripId,
    List<Waypoint> waypoints, {
    bool forceRefresh = false,
    RoutingProfile profile = RoutingProfile.driving,
  }) async {
    if (waypoints.length < 2) {
      return [];
    }

    final routes = <domain.Route>[];
    for (int i = 0; i < waypoints.length - 1; i++) {
      final route = await calculateRoute(
        tripId,
        waypoints[i],
        waypoints[i + 1],
        forceRefresh: forceRefresh,
        profile: profile,
      );

      if (route != null) {
        routes.add(route);
      }
    }

    return routes;
  }

  /// Get route between waypoints
  Future<domain.Route?> getRoute(String fromWaypointId, String toWaypointId) async {
    return await _routeRepository.findByWaypoints(fromWaypointId, toWaypointId);
  }

  /// Get all routes for a trip
  Future<List<domain.Route>> getTripRoutes(String tripId) async {
    return await _routeRepository.findByTripId(tripId);
  }

  /// Delete route
  Future<void> deleteRoute(String routeId) async {
    await _routeRepository.delete(routeId);
  }

  /// Delete all routes for a trip
  Future<void> deleteTripRoutes(String tripId) async {
    await _routeRepository.deleteByTripId(tripId);
  }

  /// Get total distance and duration for trip
  Future<TripRouteSummary?> getTripRouteSummary(String tripId) async {
    final routes = await _routeRepository.findByTripId(tripId);
    
    if (routes.isEmpty) {
      return null;
    }

    double totalDistance = 0;
    int totalDuration = 0;

    for (final route in routes) {
      totalDistance += route.distance;
      totalDuration += route.duration;
    }

    return TripRouteSummary(
      totalDistanceKm: totalDistance,
      totalDurationMinutes: totalDuration,
      routeCount: routes.length,
    );
  }
}

/// Summary of trip route
class TripRouteSummary {
  final double totalDistanceKm;
  final int totalDurationMinutes;
  final int routeCount;

  TripRouteSummary({
    required this.totalDistanceKm,
    required this.totalDurationMinutes,
    required this.routeCount,
  });

  int get totalDurationHours => (totalDurationMinutes / 60).floor();
  int get remainingMinutes => totalDurationMinutes % 60;

  String get formattedDuration {
    if (totalDurationHours > 0) {
      return '$totalDurationHours hr ${remainingMinutes} min';
    }
    return '$totalDurationMinutes min';
  }

  String get formattedDistance {
    if (totalDistanceKm >= 1) {
      return '${totalDistanceKm.toStringAsFixed(1)} km';
    }
    return '${(totalDistanceKm * 1000).toStringAsFixed(0)} m';
  }
}
