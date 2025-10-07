// This file will contain all Riverpod provider definitions
// Providers will be added as features are implemented

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'infrastructure/services/location_service.dart';
import 'infrastructure/services/mapbox_service.dart';
import 'secrets.dart';

// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Mapbox service provider
final mapboxServiceProvider = Provider<MapboxService>((ref) {
  return MapboxService(apiKey: mapboxApiKey);
});

// Example provider structure (to be implemented):
// final tripRepositoryProvider = Provider<TripRepository>((ref) {
//   return TripRepositoryImpl();
// });
