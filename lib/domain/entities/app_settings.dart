import 'package:equatable/equatable.dart';
import 'home_location.dart';

/// Application-wide settings including home location and default vehicle.
class AppSettings extends Equatable {
  /// Unique identifier (typically 'default' as there's only one settings row)
  final String id;
  
  /// User's home location (default start/end for trips)
  final HomeLocation? homeLocation;
  
  /// Default vehicle ID for trips
  final String? defaultVehicleId;
  
  /// Distance unit preference ('km' or 'mi')
  final String distanceUnit;
  
  /// Last modification timestamp
  final DateTime updatedAt;

  const AppSettings({
    required this.id,
    this.homeLocation,
    this.defaultVehicleId,
    this.distanceUnit = 'km',
    required this.updatedAt,
  });

  /// Creates default app settings
  factory AppSettings.defaults() {
    return AppSettings(
      id: 'default',
      distanceUnit: 'km',
      updatedAt: DateTime.now(),
    );
  }

  /// Creates AppSettings from database map
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    HomeLocation? homeLocation;
    
    // Only create HomeLocation if coordinates are present
    if (map['home_location_latitude'] != null && 
        map['home_location_longitude'] != null) {
      homeLocation = HomeLocation.fromMap(map);
    }
    
    return AppSettings(
      id: map['id'] as String,
      homeLocation: homeLocation,
      defaultVehicleId: map['default_vehicle_id'] as String?,
      distanceUnit: map['distance_unit'] as String? ?? 'km',
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Converts AppSettings to database map
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'default_vehicle_id': defaultVehicleId,
      'distance_unit': distanceUnit,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
    
    if (homeLocation != null) {
      map.addAll(homeLocation!.toMap());
    } else {
      map['home_location_name'] = null;
      map['home_location_latitude'] = null;
      map['home_location_longitude'] = null;
      map['home_location_address'] = null;
    }
    
    return map;
  }

  /// Creates a copy with updated fields
  AppSettings copyWith({
    String? id,
    HomeLocation? homeLocation,
    String? defaultVehicleId,
    String? distanceUnit,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      id: id ?? this.id,
      homeLocation: homeLocation ?? this.homeLocation,
      defaultVehicleId: defaultVehicleId ?? this.defaultVehicleId,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Creates a copy with home location cleared
  AppSettings clearHomeLocation() {
    return AppSettings(
      id: id,
      homeLocation: null,
      defaultVehicleId: defaultVehicleId,
      distanceUnit: distanceUnit,
      updatedAt: DateTime.now(),
    );
  }

  /// Checks if home location is configured
  bool get hasHomeLocation => homeLocation != null;

  /// Checks if a default vehicle is set
  bool get hasDefaultVehicle => defaultVehicleId != null;

  @override
  List<Object?> get props => [
        id,
        homeLocation,
        defaultVehicleId,
        distanceUnit,
        updatedAt,
      ];
}
