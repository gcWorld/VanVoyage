import 'package:sqflite/sqflite.dart';
import '../../domain/entities/activity.dart';
import '../../domain/enums/priority.dart';
import 'repository.dart';

/// Repository for Activity entities with CRUD operations.
class ActivityRepository implements Repository<Activity> {
  final Database _db;

  ActivityRepository(this._db);

  @override
  Future<Activity?> findById(String id) async {
    final results = await _db.query(
      'activities',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return Activity.fromMap(results.first);
  }

  @override
  Future<List<Activity>> findAll() async {
    final results = await _db.query(
      'activities',
      orderBy: 'priority DESC',
    );

    return results.map((map) => Activity.fromMap(map)).toList();
  }

  /// Finds activities by waypoint ID
  Future<List<Activity>> findByWaypointId(String waypointId) async {
    final results = await _db.query(
      'activities',
      where: 'waypoint_id = ?',
      whereArgs: [waypointId],
      orderBy: 'priority DESC',
    );

    return results.map((map) => Activity.fromMap(map)).toList();
  }

  /// Finds activities by priority
  Future<List<Activity>> findByPriority(Priority priority) async {
    final results = await _db.query(
      'activities',
      where: 'priority = ?',
      whereArgs: [priority.toDbString()],
      orderBy: 'waypoint_id',
    );

    return results.map((map) => Activity.fromMap(map)).toList();
  }

  /// Finds completed activities
  Future<List<Activity>> findCompleted(String waypointId) async {
    final results = await _db.query(
      'activities',
      where: 'waypoint_id = ? AND is_completed = 1',
      whereArgs: [waypointId],
    );

    return results.map((map) => Activity.fromMap(map)).toList();
  }

  /// Finds incomplete activities
  Future<List<Activity>> findIncomplete(String waypointId) async {
    final results = await _db.query(
      'activities',
      where: 'waypoint_id = ? AND is_completed = 0',
      whereArgs: [waypointId],
      orderBy: 'priority DESC',
    );

    return results.map((map) => Activity.fromMap(map)).toList();
  }

  @override
  Future<String> insert(Activity activity) async {
    await _db.insert(
      'activities',
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return activity.id;
  }

  @override
  Future<int> update(Activity activity) async {
    return await _db.update(
      'activities',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  @override
  Future<int> delete(String id) async {
    return await _db.delete(
      'activities',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes all activities for a waypoint
  Future<int> deleteByWaypointId(String waypointId) async {
    return await _db.delete(
      'activities',
      where: 'waypoint_id = ?',
      whereArgs: [waypointId],
    );
  }

  /// Marks activity as completed
  Future<int> markAsCompleted(String id) async {
    return await _db.update(
      'activities',
      {'is_completed': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Marks activity as incomplete
  Future<int> markAsIncomplete(String id) async {
    return await _db.update(
      'activities',
      {'is_completed': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
