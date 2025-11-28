import 'package:equatable/equatable.dart';

/// Represents the user's home location used as default start/end for trips.
class HomeLocation extends Equatable {
  /// Location name (e.g., "Home", "My Apartment")
  final String name;
  
  /// Geographic latitude
  final double latitude;
  
  /// Geographic longitude
  final double longitude;
  
  /// Human-readable address
  final String? address;

  const HomeLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
  });

  /// Creates HomeLocation from database map
  factory HomeLocation.fromMap(Map<String, dynamic> map) {
    return HomeLocation(
      name: map['home_location_name'] as String? ?? 'Home',
      latitude: map['home_location_latitude'] as double,
      longitude: map['home_location_longitude'] as double,
      address: map['home_location_address'] as String?,
    );
  }

  /// Converts HomeLocation fields to a map (for app_settings table)
  Map<String, dynamic> toMap() {
    return {
      'home_location_name': name,
      'home_location_latitude': latitude,
      'home_location_longitude': longitude,
      'home_location_address': address,
    };
  }

  /// Validates the location coordinates
  bool isValid() {
    return latitude >= -90 && latitude <= 90 && 
           longitude >= -180 && longitude <= 180;
  }

  @override
  List<Object?> get props => [name, latitude, longitude, address];
}
