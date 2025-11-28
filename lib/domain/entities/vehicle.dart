import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../enums/fuel_type.dart';

/// Represents a vehicle with its specifications for route planning.
/// 
/// Vehicle dimensions are used by Mapbox Directions API to avoid roads
/// with restrictions (height, width, weight limits). Fuel consumption
/// is used for trip cost estimation.
class Vehicle extends Equatable {
  /// Unique identifier
  final String id;
  
  /// User-defined vehicle name (e.g., "My Camper Van")
  final String name;
  
  /// Vehicle fuel type
  final FuelType fuelType;
  
  /// Fuel consumption in liters per 100km (or kWh/100km for electric)
  final double fuelConsumption;
  
  /// Vehicle height in meters (used for route restrictions)
  final double? height;
  
  /// Vehicle width in meters (used for route restrictions)
  final double? width;
  
  /// Vehicle length in meters (informational)
  final double? length;
  
  /// Vehicle weight in metric tons (used for route restrictions)
  final double? weight;
  
  /// Maximum recommended speed in km/h
  final int? maxSpeed;
  
  /// Whether this is the default/active vehicle
  final bool isDefault;
  
  /// Creation timestamp
  final DateTime createdAt;
  
  /// Last modification timestamp
  final DateTime updatedAt;

  const Vehicle({
    required this.id,
    required this.name,
    required this.fuelType,
    required this.fuelConsumption,
    this.height,
    this.width,
    this.length,
    this.weight,
    this.maxSpeed,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a new Vehicle with generated ID and timestamps
  factory Vehicle.create({
    required String name,
    required FuelType fuelType,
    required double fuelConsumption,
    double? height,
    double? width,
    double? length,
    double? weight,
    int? maxSpeed,
    bool isDefault = false,
  }) {
    final now = DateTime.now();
    return Vehicle(
      id: const Uuid().v4(),
      name: name,
      fuelType: fuelType,
      fuelConsumption: fuelConsumption,
      height: height,
      width: width,
      length: length,
      weight: weight,
      maxSpeed: maxSpeed,
      isDefault: isDefault,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates Vehicle from database map
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as String,
      name: map['name'] as String,
      fuelType: FuelTypeExtension.fromString(map['fuel_type'] as String),
      fuelConsumption: map['fuel_consumption'] as double,
      height: map['height'] as double?,
      width: map['width'] as double?,
      length: map['length'] as double?,
      weight: map['weight'] as double?,
      maxSpeed: map['max_speed'] as int?,
      isDefault: (map['is_default'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Converts Vehicle to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'fuel_type': fuelType.toDbString(),
      'fuel_consumption': fuelConsumption,
      'height': height,
      'width': width,
      'length': length,
      'weight': weight,
      'max_speed': maxSpeed,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Creates a copy with updated fields
  Vehicle copyWith({
    String? id,
    String? name,
    FuelType? fuelType,
    double? fuelConsumption,
    double? height,
    double? width,
    double? length,
    double? weight,
    int? maxSpeed,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      fuelType: fuelType ?? this.fuelType,
      fuelConsumption: fuelConsumption ?? this.fuelConsumption,
      height: height ?? this.height,
      width: width ?? this.width,
      length: length ?? this.length,
      weight: weight ?? this.weight,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Validates the vehicle data
  bool isValid() {
    if (name.isEmpty) return false;
    if (fuelConsumption <= 0) return false;
    if (height != null && (height! <= 0 || height! > 10)) return false;
    if (width != null && (width! <= 0 || width! > 10)) return false;
    if (length != null && (length! <= 0 || length! > 30)) return false;
    if (weight != null && (weight! <= 0 || weight! > 100)) return false;
    if (maxSpeed != null && (maxSpeed! <= 0 || maxSpeed! > 200)) return false;
    return true;
  }

  /// Checks if vehicle has dimension constraints for routing
  bool get hasDimensionConstraints => 
      height != null || width != null || weight != null;

  @override
  List<Object?> get props => [
        id,
        name,
        fuelType,
        fuelConsumption,
        height,
        width,
        length,
        weight,
        maxSpeed,
        isDefault,
        createdAt,
        updatedAt,
      ];
}
