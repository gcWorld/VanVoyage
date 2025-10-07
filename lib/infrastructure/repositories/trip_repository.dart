import 'package:sqflite/sqflite.dart';
import '../../domain/entities/trip.dart';
import '../../domain/enums/trip_status.dart';
import 'repository.dart';

/// Repository for Trip entities with CRUD operations.
class TripRepository implements Repository<Trip> {
  final Database _db;

  TripRepository(this._db);

  @override
  Future<Trip?> findById(String id) async {
    final results = await _db.query(
      'trips',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return Trip.fromMap(results.first);
  }

  @override
  Future<List<Trip>> findAll() async {
    final results = await _db.query(
      'trips',
      orderBy: 'updated_at DESC',
    );

    return results.map((map) => Trip.fromMap(map)).toList();
  }

  /// Finds trips by status
  Future<List<Trip>> findByStatus(TripStatus status) async {
    final results = await _db.query(
      'trips',
      where: 'status = ?',
      whereArgs: [status.toDbString()],
      orderBy: 'start_date DESC',
    );

    return results.map((map) => Trip.fromMap(map)).toList();
  }

  /// Finds active trip (only one should exist per user)
  Future<Trip?> findActiveTrip() async {
    final results = await _db.query(
      'trips',
      where: 'status = ?',
      whereArgs: [TripStatus.active.toDbString()],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return Trip.fromMap(results.first);
  }

  @override
  Future<String> insert(Trip trip) async {
    await _db.insert(
      'trips',
      trip.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return trip.id;
  }

  @override
  Future<int> update(Trip trip) async {
    return await _db.update(
      'trips',
      trip.toMap(),
      where: 'id = ?',
      whereArgs: [trip.id],
    );
  }

  @override
  Future<int> delete(String id) async {
    return await _db.delete(
      'trips',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Counts total trips
  Future<int> count() async {
    final result = await _db.rawQuery('SELECT COUNT(*) as count FROM trips');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Counts trips by status
  Future<int> countByStatus(TripStatus status) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM trips WHERE status = ?',
      [status.toDbString()],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
