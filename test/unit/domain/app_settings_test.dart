import 'package:flutter_test/flutter_test.dart';
import 'package:vanvoyage/domain/entities/app_settings.dart';
import 'package:vanvoyage/domain/entities/home_location.dart';

void main() {
  group('HomeLocation', () {
    test('should create a HomeLocation', () {
      const location = HomeLocation(
        name: 'Home',
        latitude: 48.8566,
        longitude: 2.3522,
        address: 'Paris, France',
      );

      expect(location.name, 'Home');
      expect(location.latitude, 48.8566);
      expect(location.longitude, 2.3522);
      expect(location.address, 'Paris, France');
    });

    test('should validate valid coordinates', () {
      const location = HomeLocation(
        name: 'Valid',
        latitude: 45.0,
        longitude: -90.0,
      );

      expect(location.isValid(), true);
    });

    test('should invalidate coordinates out of range', () {
      const invalidLat = HomeLocation(
        name: 'Invalid Lat',
        latitude: 100.0, // > 90
        longitude: 0.0,
      );

      const invalidLng = HomeLocation(
        name: 'Invalid Lng',
        latitude: 0.0,
        longitude: 200.0, // > 180
      );

      expect(invalidLat.isValid(), false);
      expect(invalidLng.isValid(), false);
    });

    test('should serialize to map correctly', () {
      const location = HomeLocation(
        name: 'Home',
        latitude: 48.8566,
        longitude: 2.3522,
        address: 'Paris, France',
      );

      final map = location.toMap();

      expect(map['home_location_name'], 'Home');
      expect(map['home_location_latitude'], 48.8566);
      expect(map['home_location_longitude'], 2.3522);
      expect(map['home_location_address'], 'Paris, France');
    });

    test('should deserialize from map correctly', () {
      final map = {
        'home_location_name': 'Home',
        'home_location_latitude': 48.8566,
        'home_location_longitude': 2.3522,
        'home_location_address': 'Paris, France',
      };

      final location = HomeLocation.fromMap(map);

      expect(location.name, 'Home');
      expect(location.latitude, 48.8566);
      expect(location.longitude, 2.3522);
      expect(location.address, 'Paris, France');
    });

    test('should be equal when all properties match', () {
      const location1 = HomeLocation(
        name: 'Home',
        latitude: 48.8566,
        longitude: 2.3522,
      );

      const location2 = HomeLocation(
        name: 'Home',
        latitude: 48.8566,
        longitude: 2.3522,
      );

      expect(location1, equals(location2));
    });
  });

  group('AppSettings', () {
    test('should create default settings', () {
      final settings = AppSettings.defaults();

      expect(settings.id, 'default');
      expect(settings.homeLocation, isNull);
      expect(settings.defaultVehicleId, isNull);
      expect(settings.distanceUnit, 'km');
    });

    test('should serialize to and from map correctly', () {
      final now = DateTime.now();
      final settings = AppSettings(
        id: 'default',
        homeLocation: const HomeLocation(
          name: 'Home',
          latitude: 48.8566,
          longitude: 2.3522,
          address: 'Paris, France',
        ),
        defaultVehicleId: 'vehicle-123',
        distanceUnit: 'mi',
        updatedAt: now,
      );

      final map = settings.toMap();
      final deserialized = AppSettings.fromMap(map);

      expect(deserialized.id, settings.id);
      expect(deserialized.homeLocation?.name, 'Home');
      expect(deserialized.homeLocation?.latitude, 48.8566);
      expect(deserialized.homeLocation?.longitude, 2.3522);
      expect(deserialized.defaultVehicleId, 'vehicle-123');
      expect(deserialized.distanceUnit, 'mi');
    });

    test('should handle null home location in serialization', () {
      final settings = AppSettings(
        id: 'default',
        homeLocation: null,
        distanceUnit: 'km',
        updatedAt: DateTime.now(),
      );

      final map = settings.toMap();

      expect(map['home_location_name'], isNull);
      expect(map['home_location_latitude'], isNull);
      expect(map['home_location_longitude'], isNull);
    });

    test('should deserialize without home location', () {
      final map = {
        'id': 'default',
        'home_location_latitude': null,
        'home_location_longitude': null,
        'default_vehicle_id': null,
        'distance_unit': 'km',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };

      final settings = AppSettings.fromMap(map);

      expect(settings.homeLocation, isNull);
      expect(settings.hasHomeLocation, false);
    });

    test('should create a copy with updated fields', () {
      final original = AppSettings.defaults();

      final updated = original.copyWith(
        homeLocation: const HomeLocation(
          name: 'New Home',
          latitude: 40.7128,
          longitude: -74.0060,
        ),
        defaultVehicleId: 'new-vehicle',
        distanceUnit: 'mi',
      );

      expect(updated.id, original.id);
      expect(updated.homeLocation?.name, 'New Home');
      expect(updated.defaultVehicleId, 'new-vehicle');
      expect(updated.distanceUnit, 'mi');
    });

    test('should clear home location', () {
      final settings = AppSettings(
        id: 'default',
        homeLocation: const HomeLocation(
          name: 'Home',
          latitude: 48.8566,
          longitude: 2.3522,
        ),
        distanceUnit: 'km',
        updatedAt: DateTime.now(),
      );

      final cleared = settings.clearHomeLocation();

      expect(cleared.homeLocation, isNull);
      expect(cleared.hasHomeLocation, false);
      expect(cleared.id, settings.id);
    });

    test('should correctly report hasHomeLocation', () {
      final withHome = AppSettings(
        id: 'default',
        homeLocation: const HomeLocation(
          name: 'Home',
          latitude: 48.8566,
          longitude: 2.3522,
        ),
        distanceUnit: 'km',
        updatedAt: DateTime.now(),
      );

      final withoutHome = AppSettings.defaults();

      expect(withHome.hasHomeLocation, true);
      expect(withoutHome.hasHomeLocation, false);
    });

    test('should correctly report hasDefaultVehicle', () {
      final withVehicle = AppSettings(
        id: 'default',
        defaultVehicleId: 'vehicle-123',
        distanceUnit: 'km',
        updatedAt: DateTime.now(),
      );

      final withoutVehicle = AppSettings.defaults();

      expect(withVehicle.hasDefaultVehicle, true);
      expect(withoutVehicle.hasDefaultVehicle, false);
    });

    test('should be equal when all properties match', () {
      final now = DateTime.now();
      final settings1 = AppSettings(
        id: 'default',
        distanceUnit: 'km',
        updatedAt: now,
      );

      final settings2 = AppSettings(
        id: 'default',
        distanceUnit: 'km',
        updatedAt: now,
      );

      expect(settings1, equals(settings2));
    });
  });
}
