import 'package:sqflite/sqflite.dart';
import '../../domain/entities/route.dart';
import '../database/database_helper.dart';

/// Repository for managing Route entities
class RouteRepository {
  final DatabaseHelper _dbHelper;

  RouteRepository(this._dbHelper);

  /// Insert a new route
  Future<void> insert(Route route) async {
    final db = await _dbHelper.database;
    await db.insert(
      'routes',
      route.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Find route by ID
  Future<Route?> findById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'routes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Route.fromMap(maps.first);
    }
    return null;
  }

  /// Find routes for a trip
  Future<List<Route>> findByTripId(String tripId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'routes',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'calculated_at DESC',
    );

    return maps.map((map) => Route.fromMap(map)).toList();
  }

  /// Find route between two waypoints
  Future<Route?> findByWaypoints(String fromWaypointId, String toWaypointId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'routes',
      where: 'from_waypoint_id = ? AND to_waypoint_id = ?',
      whereArgs: [fromWaypointId, toWaypointId],
      orderBy: 'calculated_at DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Route.fromMap(maps.first);
    }
    return null;
  }

  /// Update an existing route
  Future<void> update(Route route) async {
    final db = await _dbHelper.database;
    await db.update(
      'routes',
      route.toMap(),
      where: 'id = ?',
      whereArgs: [route.id],
    );
  }

  /// Delete a route
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'routes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all routes for a trip
  Future<void> deleteByTripId(String tripId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'routes',
      where: 'trip_id = ?',
      whereArgs: [tripId],
    );
  }

  /// Get all routes
  Future<List<Route>> findAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('routes', orderBy: 'calculated_at DESC');
    return maps.map((map) => Route.fromMap(map)).toList();
  }
}
