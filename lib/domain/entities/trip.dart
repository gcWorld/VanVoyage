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
  
  /// Trip start date
  final DateTime startDate;
  
  /// Trip end date
  final DateTime endDate;
  
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
    TripStatus status = TripStatus.planning,
  }) {
    final now = DateTime.now();
    return Trip(
      id: const Uuid().v4(),
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
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
        status,
        createdAt,
        updatedAt,
      ];
}
