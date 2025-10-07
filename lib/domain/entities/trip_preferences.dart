import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Configuration settings for trip planning behavior.
class TripPreferences extends Equatable {
  /// Unique identifier
  final String id;
  
  /// Foreign key to Trip (one-to-one)
  final String tripId;
  
  /// Maximum km per day
  final int maxDailyDrivingDistance;
  
  /// Maximum minutes per day
  final int maxDailyDrivingTime;
  
  /// Average km/h for calculations
  final int preferredDrivingSpeed;
  
  /// Factor in rest stops
  final bool includeRestStops;
  
  /// Minutes between rest stops
  final int? restStopInterval;
  
  /// Avoid toll roads
  final bool avoidTolls;
  
  /// Avoid highways
  final bool avoidHighways;
  
  /// Prefer scenic routes
  final bool preferScenicRoutes;

  const TripPreferences({
    required this.id,
    required this.tripId,
    this.maxDailyDrivingDistance = 300,
    this.maxDailyDrivingTime = 240,
    this.preferredDrivingSpeed = 80,
    this.includeRestStops = true,
    this.restStopInterval = 120,
    this.avoidTolls = false,
    this.avoidHighways = false,
    this.preferScenicRoutes = false,
  });

  /// Creates a new TripPreferences with generated ID
  factory TripPreferences.create({
    required String tripId,
    int maxDailyDrivingDistance = 300,
    int maxDailyDrivingTime = 240,
    int preferredDrivingSpeed = 80,
    bool includeRestStops = true,
    int? restStopInterval = 120,
    bool avoidTolls = false,
    bool avoidHighways = false,
    bool preferScenicRoutes = false,
  }) {
    return TripPreferences(
      id: const Uuid().v4(),
      tripId: tripId,
      maxDailyDrivingDistance: maxDailyDrivingDistance,
      maxDailyDrivingTime: maxDailyDrivingTime,
      preferredDrivingSpeed: preferredDrivingSpeed,
      includeRestStops: includeRestStops,
      restStopInterval: restStopInterval,
      avoidTolls: avoidTolls,
      avoidHighways: avoidHighways,
      preferScenicRoutes: preferScenicRoutes,
    );
  }

  /// Creates TripPreferences from database map
  factory TripPreferences.fromMap(Map<String, dynamic> map) {
    return TripPreferences(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      maxDailyDrivingDistance: map['max_daily_driving_distance'] as int,
      maxDailyDrivingTime: map['max_daily_driving_time'] as int,
      preferredDrivingSpeed: map['preferred_driving_speed'] as int,
      includeRestStops: (map['include_rest_stops'] as int) == 1,
      restStopInterval: map['rest_stop_interval'] as int?,
      avoidTolls: (map['avoid_tolls'] as int) == 1,
      avoidHighways: (map['avoid_highways'] as int) == 1,
      preferScenicRoutes: (map['prefer_scenic_routes'] as int) == 1,
    );
  }

  /// Converts TripPreferences to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'max_daily_driving_distance': maxDailyDrivingDistance,
      'max_daily_driving_time': maxDailyDrivingTime,
      'preferred_driving_speed': preferredDrivingSpeed,
      'include_rest_stops': includeRestStops ? 1 : 0,
      'rest_stop_interval': restStopInterval,
      'avoid_tolls': avoidTolls ? 1 : 0,
      'avoid_highways': avoidHighways ? 1 : 0,
      'prefer_scenic_routes': preferScenicRoutes ? 1 : 0,
    };
  }

  /// Creates a copy with updated fields
  TripPreferences copyWith({
    String? id,
    String? tripId,
    int? maxDailyDrivingDistance,
    int? maxDailyDrivingTime,
    int? preferredDrivingSpeed,
    bool? includeRestStops,
    int? restStopInterval,
    bool? avoidTolls,
    bool? avoidHighways,
    bool? preferScenicRoutes,
  }) {
    return TripPreferences(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      maxDailyDrivingDistance: maxDailyDrivingDistance ?? this.maxDailyDrivingDistance,
      maxDailyDrivingTime: maxDailyDrivingTime ?? this.maxDailyDrivingTime,
      preferredDrivingSpeed: preferredDrivingSpeed ?? this.preferredDrivingSpeed,
      includeRestStops: includeRestStops ?? this.includeRestStops,
      restStopInterval: restStopInterval ?? this.restStopInterval,
      avoidTolls: avoidTolls ?? this.avoidTolls,
      avoidHighways: avoidHighways ?? this.avoidHighways,
      preferScenicRoutes: preferScenicRoutes ?? this.preferScenicRoutes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tripId,
        maxDailyDrivingDistance,
        maxDailyDrivingTime,
        preferredDrivingSpeed,
        includeRestStops,
        restStopInterval,
        avoidTolls,
        avoidHighways,
        preferScenicRoutes,
      ];
}
