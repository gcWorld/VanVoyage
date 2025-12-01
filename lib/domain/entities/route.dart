import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Represents the calculated route between waypoints.
class Route extends Equatable {
  /// Unique identifier
  final String id;

  /// Foreign key to Trip
  final String tripId;

  /// Starting waypoint
  final String fromWaypointId;

  /// Ending waypoint
  final String toWaypointId;

  /// Encoded polyline (GeoJSON LineString)
  final String geometry;

  /// Total distance in kilometers
  final double distance;

  /// Estimated duration in minutes
  final int duration;

  /// When route was calculated
  final DateTime calculatedAt;

  /// Service used (e.g., "Mapbox")
  final String routeProvider;

  const Route({
    required this.id,
    required this.tripId,
    required this.fromWaypointId,
    required this.toWaypointId,
    required this.geometry,
    required this.distance,
    required this.duration,
    required this.calculatedAt,
    required this.routeProvider,
  });

  /// Creates a new Route with generated ID
  factory Route.create({
    required String tripId,
    required String fromWaypointId,
    required String toWaypointId,
    required String geometry,
    required double distance,
    required int duration,
    String routeProvider = 'Mapbox',
  }) {
    return Route(
      id: const Uuid().v4(),
      tripId: tripId,
      fromWaypointId: fromWaypointId,
      toWaypointId: toWaypointId,
      geometry: geometry,
      distance: distance,
      duration: duration,
      calculatedAt: DateTime.now(),
      routeProvider: routeProvider,
    );
  }

  /// Creates Route from database map
  factory Route.fromMap(Map<String, dynamic> map) {
    return Route(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      fromWaypointId: map['from_waypoint_id'] as String,
      toWaypointId: map['to_waypoint_id'] as String,
      geometry: map['geometry'] as String,
      distance: map['distance'] as double,
      duration: map['duration'] as int,
      calculatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['calculated_at'] as int),
      routeProvider: map['route_provider'] as String,
    );
  }

  /// Converts Route to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'from_waypoint_id': fromWaypointId,
      'to_waypoint_id': toWaypointId,
      'geometry': geometry,
      'distance': distance,
      'duration': duration,
      'calculated_at': calculatedAt.millisecondsSinceEpoch,
      'route_provider': routeProvider,
    };
  }

  /// Creates a copy with updated fields
  Route copyWith({
    String? id,
    String? tripId,
    String? fromWaypointId,
    String? toWaypointId,
    String? geometry,
    double? distance,
    int? duration,
    DateTime? calculatedAt,
    String? routeProvider,
  }) {
    return Route(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      fromWaypointId: fromWaypointId ?? this.fromWaypointId,
      toWaypointId: toWaypointId ?? this.toWaypointId,
      geometry: geometry ?? this.geometry,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      routeProvider: routeProvider ?? this.routeProvider,
    );
  }

  /// Validates the route invariants
  bool isValid() {
    return fromWaypointId != toWaypointId;
  }

  @override
  List<Object?> get props => [
        id,
        tripId,
        fromWaypointId,
        toWaypointId,
        geometry,
        distance,
        duration,
        calculatedAt,
        routeProvider,
      ];
}
