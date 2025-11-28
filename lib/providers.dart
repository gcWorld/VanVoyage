// This file will contain all Riverpod provider definitions
// Providers will be added as features are implemented

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'infrastructure/services/location_service.dart';
import 'infrastructure/services/mapbox_service.dart';
import 'infrastructure/services/navigation_share_service.dart';
import 'infrastructure/database/database_provider.dart';
import 'infrastructure/database/database_helper.dart';
import 'infrastructure/repositories/trip_repository.dart';
import 'infrastructure/repositories/waypoint_repository.dart';
import 'infrastructure/repositories/route_repository.dart';
import 'infrastructure/repositories/settings_repository.dart';
import 'infrastructure/repositories/vehicle_repository.dart';
import 'domain/services/route_service.dart';
import 'secrets.dart';

// Database provider
final databaseProvider = FutureProvider<Database>((ref) async {
  return await DatabaseProvider.database;
});

// Database helper provider
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
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

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  final dbHelper = ref.read(databaseHelperProvider);
  return RouteRepository(dbHelper);
});

// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Mapbox service provider
final mapboxServiceProvider = Provider<MapboxService>((ref) {
  return MapboxService(apiKey: mapboxApiKey);
});

// Navigation share service provider
final navigationShareServiceProvider = Provider<NavigationShareService>((ref) {
  return NavigationShareService();
});

// Route service provider
final routeServiceProvider = Provider<RouteService>((ref) {
  final routeRepository = ref.read(routeRepositoryProvider);
  final mapboxService = ref.read(mapboxServiceProvider);
  return RouteService(routeRepository, mapboxService);
});

// Settings repository provider
final settingsRepositoryProvider = FutureProvider<SettingsRepository>((ref) async {
  final db = await ref.read(databaseProvider.future);
  return SettingsRepository(db);
});

// Vehicle repository provider
final vehicleRepositoryProvider = FutureProvider<VehicleRepository>((ref) async {
  final db = await ref.read(databaseProvider.future);
  return VehicleRepository(db);
});
