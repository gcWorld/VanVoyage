// This file will contain all Riverpod provider definitions
// Providers will be added as features are implemented

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'infrastructure/services/location_service.dart';
import 'infrastructure/services/mapbox_service.dart';
import 'infrastructure/database/database_provider.dart';
import 'secrets.dart';

// Database provider
final databaseProvider = Provider<Future<Database>>((ref) {
  return DatabaseProvider.database;
});

// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Mapbox service provider
final mapboxServiceProvider = Provider<MapboxService>((ref) {
  return MapboxService(apiKey: mapboxApiKey);
});
