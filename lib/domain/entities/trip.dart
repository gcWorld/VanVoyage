import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../enums/trip_status.dart';

/// Represents a complete van travel journey with associated metadata and schedule.
class Trip extends Equatable {
  /// Unique identifier
  final String id;
  
  /// User-defined trip name
  final String name;
  
  /// Optional trip description
  final String? description;
  
  /// Trip start date (overall trip including transit)
  final DateTime startDate;
  
  /// Trip end date (overall trip including transit)
  final DateTime endDate;
  
  /// Optional transit start date (outbound transit begins)
  final DateTime? transitStartDate;
  
  /// Optional transit end date (return transit ends)
  final DateTime? transitEndDate;
  
  /// Optional location start date (vacation on location begins)
  final DateTime? locationStartDate;
  
  /// Optional location end date (vacation on location ends)
  final DateTime? locationEndDate;
  
  /// Current trip status
  final TripStatus status;
  
  /// Creation timestamp
  final DateTime createdAt;
  
  /// Last modification timestamp
  final DateTime updatedAt;

  const Trip({
    required this.id,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    this.transitStartDate,
    this.transitEndDate,
    this.locationStartDate,
    this.locationEndDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a new Trip with generated ID and timestamps
  factory Trip.create({
    required String name,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    DateTime? transitStartDate,
    DateTime? transitEndDate,
    DateTime? locationStartDate,
    DateTime? locationEndDate,
    TripStatus status = TripStatus.planning,
  }) {
    final now = DateTime.now();
    return Trip(
      id: const Uuid().v4(),
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      transitStartDate: transitStartDate,
      transitEndDate: transitEndDate,
      locationStartDate: locationStartDate,
      locationEndDate: locationEndDate,
      status: status,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates Trip from database map
  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int),
      transitStartDate: map['transit_start_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['transit_start_date'] as int)
          : null,
      transitEndDate: map['transit_end_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['transit_end_date'] as int)
          : null,
      locationStartDate: map['location_start_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['location_start_date'] as int)
          : null,
      locationEndDate: map['location_end_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['location_end_date'] as int)
          : null,
      status: TripStatus.fromString(map['status'] as String),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Converts Trip to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate.millisecondsSinceEpoch,
      'transit_start_date': transitStartDate?.millisecondsSinceEpoch,
      'transit_end_date': transitEndDate?.millisecondsSinceEpoch,
      'location_start_date': locationStartDate?.millisecondsSinceEpoch,
      'location_end_date': locationEndDate?.millisecondsSinceEpoch,
      'status': status.toDbString(),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Creates a copy with updated fields
  Trip copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? transitStartDate,
    DateTime? transitEndDate,
    DateTime? locationStartDate,
    DateTime? locationEndDate,
    TripStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      transitStartDate: transitStartDate ?? this.transitStartDate,
      transitEndDate: transitEndDate ?? this.transitEndDate,
      locationStartDate: locationStartDate ?? this.locationStartDate,
      locationEndDate: locationEndDate ?? this.locationEndDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Validates the trip invariants
  bool isValid() {
    return endDate.isAfter(startDate);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        startDate,
        endDate,
        transitStartDate,
        transitEndDate,
        locationStartDate,
        locationEndDate,
        status,
        createdAt,
        updatedAt,
      ];
}
