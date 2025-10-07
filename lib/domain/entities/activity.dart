import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../enums/activity_category.dart';
import '../enums/priority.dart';

/// Represents things to do or see at a waypoint.
class Activity extends Equatable {
  /// Unique identifier
  final String id;
  
  /// Foreign key to Waypoint
  final String waypointId;
  
  /// Activity name
  final String name;
  
  /// Activity details
  final String? description;
  
  /// Category
  final ActivityCategory category;
  
  /// Duration in minutes
  final int? estimatedDuration;
  
  /// Estimated cost
  final double? cost;
  
  /// Importance
  final Priority priority;
  
  /// User notes
  final String? notes;
  
  /// Completion status
  final bool isCompleted;

  const Activity({
    required this.id,
    required this.waypointId,
    required this.name,
    this.description,
    required this.category,
    this.estimatedDuration,
    this.cost,
    required this.priority,
    this.notes,
    this.isCompleted = false,
  });

  /// Creates a new Activity with generated ID
  factory Activity.create({
    required String waypointId,
    required String name,
    String? description,
    required ActivityCategory category,
    int? estimatedDuration,
    double? cost,
    Priority priority = Priority.medium,
    String? notes,
    bool isCompleted = false,
  }) {
    return Activity(
      id: const Uuid().v4(),
      waypointId: waypointId,
      name: name,
      description: description,
      category: category,
      estimatedDuration: estimatedDuration,
      cost: cost,
      priority: priority,
      notes: notes,
      isCompleted: isCompleted,
    );
  }

  /// Creates Activity from database map
  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as String,
      waypointId: map['waypoint_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      category: ActivityCategory.fromString(map['category'] as String),
      estimatedDuration: map['estimated_duration'] as int?,
      cost: map['cost'] as double?,
      priority: Priority.fromString(map['priority'] as String),
      notes: map['notes'] as String?,
      isCompleted: (map['is_completed'] as int) == 1,
    );
  }

  /// Converts Activity to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'waypoint_id': waypointId,
      'name': name,
      'description': description,
      'category': category.toDbString(),
      'estimated_duration': estimatedDuration,
      'cost': cost,
      'priority': priority.toDbString(),
      'notes': notes,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  /// Creates a copy with updated fields
  Activity copyWith({
    String? id,
    String? waypointId,
    String? name,
    String? description,
    ActivityCategory? category,
    int? estimatedDuration,
    double? cost,
    Priority? priority,
    String? notes,
    bool? isCompleted,
  }) {
    return Activity(
      id: id ?? this.id,
      waypointId: waypointId ?? this.waypointId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      cost: cost ?? this.cost,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        waypointId,
        name,
        description,
        category,
        estimatedDuration,
        cost,
        priority,
        notes,
        isCompleted,
      ];
}
