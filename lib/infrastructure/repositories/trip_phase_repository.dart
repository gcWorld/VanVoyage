import 'package:sqflite/sqflite.dart';
import '../../domain/entities/trip_phase.dart';
import 'repository.dart';

/// Repository for TripPhase entities with CRUD operations.
class TripPhaseRepository implements Repository<TripPhase> {
  final Database _db;

  TripPhaseRepository(this._db);

  @override
  Future<TripPhase?> findById(String id) async {
    final results = await _db.query(
      'trip_phases',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return TripPhase.fromMap(results.first);
  }

  @override
  Future<List<TripPhase>> findAll() async {
    final results = await _db.query(
      'trip_phases',
      orderBy: 'trip_id, sequence_order',
    );

    return results.map((map) => TripPhase.fromMap(map)).toList();
  }

  /// Finds phases by trip ID
  Future<List<TripPhase>> findByTripId(String tripId) async {
    final results = await _db.query(
      'trip_phases',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'sequence_order ASC',
    );

    return results.map((map) => TripPhase.fromMap(map)).toList();
  }

  @override
  Future<String> insert(TripPhase phase) async {
    await _db.insert(
      'trip_phases',
      phase.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return phase.id;
  }

  @override
  Future<int> update(TripPhase phase) async {
    return await _db.update(
      'trip_phases',
      phase.toMap(),
      where: 'id = ?',
      whereArgs: [phase.id],
    );
  }

  @override
  Future<int> delete(String id) async {
    return await _db.delete(
      'trip_phases',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes all phases for a trip
  Future<int> deleteByTripId(String tripId) async {
    return await _db.delete(
      'trip_phases',
      where: 'trip_id = ?',
      whereArgs: [tripId],
    );
  }

  /// Gets the next sequence order for a trip
  Future<int> getNextSequenceOrder(String tripId) async {
    final result = await _db.rawQuery(
      'SELECT MAX(sequence_order) as max_order FROM trip_phases WHERE trip_id = ?',
      [tripId],
    );
    final maxOrder = Sqflite.firstIntValue(result);
    return (maxOrder ?? -1) + 1;
  }
}
