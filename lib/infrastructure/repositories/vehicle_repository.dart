import 'package:sqflite/sqflite.dart';
import '../../domain/entities/vehicle.dart';
import 'repository.dart';

/// Repository for Vehicle entities with CRUD operations.
class VehicleRepository implements Repository<Vehicle> {
  final Database _db;

  VehicleRepository(this._db);

  @override
  Future<Vehicle?> findById(String id) async {
    final results = await _db.query(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return Vehicle.fromMap(results.first);
  }

  @override
  Future<List<Vehicle>> findAll() async {
    final results = await _db.query(
      'vehicles',
      orderBy: 'name ASC',
    );

    return results.map((map) => Vehicle.fromMap(map)).toList();
  }

  /// Finds the default vehicle
  Future<Vehicle?> findDefault() async {
    final results = await _db.query(
      'vehicles',
      where: 'is_default = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return Vehicle.fromMap(results.first);
  }

  @override
  Future<String> insert(Vehicle vehicle) async {
    // If this vehicle is set as default, clear other defaults first
    if (vehicle.isDefault) {
      await _clearDefaults();
    }

    await _db.insert(
      'vehicles',
      vehicle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return vehicle.id;
  }

  @override
  Future<int> update(Vehicle vehicle) async {
    // If this vehicle is being set as default, clear other defaults first
    if (vehicle.isDefault) {
      await _clearDefaults();
    }

    final updatedVehicle = vehicle.copyWith(
      updatedAt: DateTime.now(),
    );

    return await _db.update(
      'vehicles',
      updatedVehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  @override
  Future<int> delete(String id) async {
    return await _db.delete(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Sets a vehicle as the default
  Future<void> setAsDefault(String vehicleId) async {
    await _clearDefaults();

    final now = DateTime.now();
    await _db.update(
      'vehicles',
      {
        'is_default': 1,
        'updated_at': now.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [vehicleId],
    );
  }

  /// Clears the default flag from all vehicles
  Future<void> _clearDefaults() async {
    final now = DateTime.now();
    await _db.update(
      'vehicles',
      {
        'is_default': 0,
        'updated_at': now.millisecondsSinceEpoch,
      },
      where: 'is_default = ?',
      whereArgs: [1],
    );
  }

  /// Counts total vehicles
  Future<int> count() async {
    final result = await _db.rawQuery('SELECT COUNT(*) as count FROM vehicles');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
