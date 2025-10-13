// This file will contain all Riverpod provider definitions
// Providers will be added as features are implemented

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'infrastructure/services/location_service.dart';
import 'infrastructure/services/mapbox_service.dart';
import 'infrastructure/database/database_provider.dart';
import 'infrastructure/repositories/trip_repository.dart';
import 'infrastructure/repositories/waypoint_repository.dart';
import 'secrets.dart';

// Database provider
final databaseProvider = FutureProvider<Database>((ref) async {
  return await DatabaseProvider.database;
});

// Repository providers
final tripRepositoryProvider = FutureProvider<TripRepository>((ref) async {
  final db = await ref.read(databaseProvider.future);
  return TripRepository(db);
});

final waypointRepositoryProvider = FutureProvider<WaypointRepository>((ref) async {
  final db = await ref.read(databaseProvider.future);
  return WaypointRepository(db);
});

// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Mapbox service provider
final mapboxServiceProvider = Provider<MapboxService>((ref) {
  return MapboxService(apiKey: mapboxApiKey);
});
