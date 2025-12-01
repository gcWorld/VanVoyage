import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../enums/waypoint_type.dart';

/// Represents a location on the trip route.
class Waypoint extends Equatable {
  /// Unique identifier
  final String id;

  /// Foreign key to Trip
  final String tripId;

  /// Optional foreign key to TripPhase
  final String? phaseId;

  /// Location name
  final String name;

  /// Optional description
  final String? description;

  /// Geographic latitude
  final double latitude;

  /// Geographic longitude
  final double longitude;

  /// Human-readable address
  final String? address;

  /// Type of waypoint
  final WaypointType waypointType;

  /// Planned arrival
  final DateTime? arrivalDate;

  /// Planned departure
  final DateTime? departureDate;

  /// Duration in days (for overnight stays)
  final int? stayDuration;

  /// Order in route
  final int sequenceOrder;

  /// Minutes from previous waypoint
  final int? estimatedDrivingTime;

  /// Kilometers from previous waypoint
  final double? estimatedDistance;

  const Waypoint({
    required this.id,
    required this.tripId,
    this.phaseId,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.waypointType,
    this.arrivalDate,
    this.departureDate,
    this.stayDuration,
    required this.sequenceOrder,
    this.estimatedDrivingTime,
    this.estimatedDistance,
  });

  /// Creates a new Waypoint with generated ID
  factory Waypoint.create({
    required String tripId,
    String? phaseId,
    required String name,
    String? description,
    required double latitude,
    required double longitude,
    String? address,
    required WaypointType waypointType,
    DateTime? arrivalDate,
    DateTime? departureDate,
    int? stayDuration,
    required int sequenceOrder,
    int? estimatedDrivingTime,
    double? estimatedDistance,
  }) {
    return Waypoint(
      id: const Uuid().v4(),
      tripId: tripId,
      phaseId: phaseId,
      name: name,
      description: description,
      latitude: latitude,
      longitude: longitude,
      address: address,
      waypointType: waypointType,
      arrivalDate: arrivalDate,
      departureDate: departureDate,
      stayDuration: stayDuration,
      sequenceOrder: sequenceOrder,
      estimatedDrivingTime: estimatedDrivingTime,
      estimatedDistance: estimatedDistance,
    );
  }

  /// Creates Waypoint from database map
  factory Waypoint.fromMap(Map<String, dynamic> map) {
    return Waypoint(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      phaseId: map['phase_id'] as String?,
      name: map['name'] as String,
      description: map['description'] as String?,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      address: map['address'] as String?,
      waypointType: WaypointType.fromString(map['waypoint_type'] as String),
      arrivalDate: map['arrival_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['arrival_date'] as int)
          : null,
      departureDate: map['departure_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['departure_date'] as int)
          : null,
      stayDuration: map['stay_duration'] as int?,
      sequenceOrder: map['sequence_order'] as int,
      estimatedDrivingTime: map['estimated_driving_time'] as int?,
      estimatedDistance: map['estimated_distance'] as double?,
    );
  }

  /// Converts Waypoint to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'phase_id': phaseId,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'waypoint_type': waypointType.toDbString(),
      'arrival_date': arrivalDate?.millisecondsSinceEpoch,
      'departure_date': departureDate?.millisecondsSinceEpoch,
      'stay_duration': stayDuration,
      'sequence_order': sequenceOrder,
      'estimated_driving_time': estimatedDrivingTime,
      'estimated_distance': estimatedDistance,
    };
  }

  /// Creates a copy with updated fields
  Waypoint copyWith({
    String? id,
    String? tripId,
    String? phaseId,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    WaypointType? waypointType,
    DateTime? arrivalDate,
    DateTime? departureDate,
    int? stayDuration,
    int? sequenceOrder,
    int? estimatedDrivingTime,
    double? estimatedDistance,
  }) {
    return Waypoint(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      phaseId: phaseId ?? this.phaseId,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      waypointType: waypointType ?? this.waypointType,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      departureDate: departureDate ?? this.departureDate,
      stayDuration: stayDuration ?? this.stayDuration,
      sequenceOrder: sequenceOrder ?? this.sequenceOrder,
      estimatedDrivingTime: estimatedDrivingTime ?? this.estimatedDrivingTime,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
    );
  }

  /// Validates the waypoint invariants
  bool isValid() {
    if (departureDate != null && arrivalDate != null) {
      if (!departureDate!.isAfter(arrivalDate!)) {
        return false;
      }
    }

    if (waypointType == WaypointType.overnightStay) {
      if (stayDuration == null || stayDuration! < 1) {
        return false;
      }
    }

    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  @override
  List<Object?> get props => [
        id,
        tripId,
        phaseId,
        name,
        description,
        latitude,
        longitude,
        address,
        waypointType,
        arrivalDate,
        departureDate,
        stayDuration,
        sequenceOrder,
        estimatedDrivingTime,
        estimatedDistance,
      ];
}
