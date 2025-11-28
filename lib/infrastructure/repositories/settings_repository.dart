import 'package:sqflite/sqflite.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/home_location.dart';

/// Repository for managing application settings.
class SettingsRepository {
  final Database _db;

  SettingsRepository(this._db);

  /// Gets the current app settings
  Future<AppSettings> getSettings() async {
    final results = await _db.query(
      'app_settings',
      where: 'id = ?',
      whereArgs: ['default'],
    );

    if (results.isEmpty) {
      // Return defaults if no settings exist
      return AppSettings.defaults();
    }
    return AppSettings.fromMap(results.first);
  }

  /// Updates the app settings
  Future<void> updateSettings(AppSettings settings) async {
    final settingsWithTimestamp = settings.copyWith(
      updatedAt: DateTime.now(),
    );
    
    await _db.update(
      'app_settings',
      settingsWithTimestamp.toMap(),
      where: 'id = ?',
      whereArgs: [settings.id],
    );
  }

  /// Updates the home location
  Future<void> updateHomeLocation(HomeLocation location) async {
    final now = DateTime.now();
    final data = {
      ...location.toMap(),
      'updated_at': now.millisecondsSinceEpoch,
    };
    
    await _db.update(
      'app_settings',
      data,
      where: 'id = ?',
      whereArgs: ['default'],
    );
  }

  /// Clears the home location
  Future<void> clearHomeLocation() async {
    final now = DateTime.now();
    await _db.update(
      'app_settings',
      {
        'home_location_name': null,
        'home_location_latitude': null,
        'home_location_longitude': null,
        'home_location_address': null,
        'updated_at': now.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: ['default'],
    );
  }

  /// Sets the default vehicle ID
  Future<void> setDefaultVehicle(String? vehicleId) async {
    final now = DateTime.now();
    await _db.update(
      'app_settings',
      {
        'default_vehicle_id': vehicleId,
        'updated_at': now.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: ['default'],
    );
  }

  /// Updates the distance unit preference
  Future<void> setDistanceUnit(String unit) async {
    if (unit != 'km' && unit != 'mi') {
      throw ArgumentError('Distance unit must be "km" or "mi"');
    }
    
    final now = DateTime.now();
    await _db.update(
      'app_settings',
      {
        'distance_unit': unit,
        'updated_at': now.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: ['default'],
    );
  }
}
