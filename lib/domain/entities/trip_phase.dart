import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../enums/phase_type.dart';

/// Represents a distinct phase of a trip.
class TripPhase extends Equatable {
  /// Unique identifier
  final String id;

  /// Foreign key to Trip
  final String tripId;

  /// Phase name
  final String name;

  /// Type of phase
  final PhaseType phaseType;

  /// Phase start date
  final DateTime startDate;

  /// Phase end date
  final DateTime endDate;

  /// Order within trip (0-based)
  final int sequenceOrder;

  const TripPhase({
    required this.id,
    required this.tripId,
    required this.name,
    required this.phaseType,
    required this.startDate,
    required this.endDate,
    required this.sequenceOrder,
  });

  /// Creates a new TripPhase with generated ID
  factory TripPhase.create({
    required String tripId,
    required String name,
    required PhaseType phaseType,
    required DateTime startDate,
    required DateTime endDate,
    required int sequenceOrder,
  }) {
    return TripPhase(
      id: const Uuid().v4(),
      tripId: tripId,
      name: name,
      phaseType: phaseType,
      startDate: startDate,
      endDate: endDate,
      sequenceOrder: sequenceOrder,
    );
  }

  /// Creates TripPhase from database map
  factory TripPhase.fromMap(Map<String, dynamic> map) {
    return TripPhase(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      name: map['name'] as String,
      phaseType: PhaseType.fromString(map['phase_type'] as String),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int),
      sequenceOrder: map['sequence_order'] as int,
    );
  }

  /// Converts TripPhase to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'name': name,
      'phase_type': phaseType.toDbString(),
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate.millisecondsSinceEpoch,
      'sequence_order': sequenceOrder,
    };
  }

  /// Creates a copy with updated fields
  TripPhase copyWith({
    String? id,
    String? tripId,
    String? name,
    PhaseType? phaseType,
    DateTime? startDate,
    DateTime? endDate,
    int? sequenceOrder,
  }) {
    return TripPhase(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      phaseType: phaseType ?? this.phaseType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sequenceOrder: sequenceOrder ?? this.sequenceOrder,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tripId,
        name,
        phaseType,
        startDate,
        endDate,
        sequenceOrder,
      ];
}
