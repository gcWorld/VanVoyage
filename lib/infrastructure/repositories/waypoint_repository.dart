import 'package:sqflite/sqflite.dart';
import '../../domain/entities/waypoint.dart';
import '../../domain/enums/waypoint_type.dart';
import 'repository.dart';

/// Repository for Waypoint entities with CRUD operations.
class WaypointRepository implements Repository<Waypoint> {
  final Database _db;

  WaypointRepository(this._db);

  @override
  Future<Waypoint?> findById(String id) async {
    final results = await _db.query(
      'waypoints',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return Waypoint.fromMap(results.first);
  }

  @override
  Future<List<Waypoint>> findAll() async {
    final results = await _db.query(
      'waypoints',
      orderBy: 'trip_id, sequence_order',
    );

    return results.map((map) => Waypoint.fromMap(map)).toList();
  }

  /// Finds waypoints by trip ID
  Future<List<Waypoint>> findByTripId(String tripId) async {
    final results = await _db.query(
      'waypoints',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'sequence_order ASC',
    );

    return results.map((map) => Waypoint.fromMap(map)).toList();
  }

  /// Finds waypoints by phase ID
  Future<List<Waypoint>> findByPhaseId(String phaseId) async {
    final results = await _db.query(
      'waypoints',
      where: 'phase_id = ?',
      whereArgs: [phaseId],
      orderBy: 'sequence_order ASC',
    );

    return results.map((map) => Waypoint.fromMap(map)).toList();
  }

  /// Finds waypoints by type
  Future<List<Waypoint>> findByType(String tripId, WaypointType type) async {
    final results = await _db.query(
      'waypoints',
      where: 'trip_id = ? AND waypoint_type = ?',
      whereArgs: [tripId, type.toDbString()],
      orderBy: 'sequence_order ASC',
    );

    return results.map((map) => Waypoint.fromMap(map)).toList();
  }

  /// Finds overnight stays for a trip
  Future<List<Waypoint>> findOvernightStays(String tripId) async {
    return findByType(tripId, WaypointType.overnightStay);
  }

  @override
  Future<String> insert(Waypoint waypoint) async {
    await _db.insert(
      'waypoints',
      waypoint.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return waypoint.id;
  }

  @override
  Future<int> update(Waypoint waypoint) async {
    return await _db.update(
      'waypoints',
      waypoint.toMap(),
      where: 'id = ?',
      whereArgs: [waypoint.id],
    );
  }

  @override
  Future<int> delete(String id) async {
    return await _db.delete(
      'waypoints',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes all waypoints for a trip
  Future<int> deleteByTripId(String tripId) async {
    return await _db.delete(
      'waypoints',
      where: 'trip_id = ?',
      whereArgs: [tripId],
    );
  }

  /// Counts waypoints for a trip
  Future<int> countByTripId(String tripId) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM waypoints WHERE trip_id = ?',
      [tripId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Gets the next sequence order for a trip
  Future<int> getNextSequenceOrder(String tripId) async {
    final result = await _db.rawQuery(
      'SELECT MAX(sequence_order) as max_order FROM waypoints WHERE trip_id = ?',
      [tripId],
    );
    final maxOrder = Sqflite.firstIntValue(result);
    return (maxOrder ?? -1) + 1;
  }
}
