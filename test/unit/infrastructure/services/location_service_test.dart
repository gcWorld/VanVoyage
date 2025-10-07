import 'package:flutter_test/flutter_test.dart';
import 'package:vanvoyage/infrastructure/services/location_service.dart';

void main() {
  group('LocationService', () {
    late LocationService locationService;

    setUp(() {
      locationService = LocationService();
    });

    test('calculateDistance returns correct distance', () {
      // Test distance calculation between two known points
      // San Francisco to Los Angeles approximate distance
      final distance = locationService.calculateDistance(
        37.7749, // SF latitude
        -122.4194, // SF longitude
        34.0522, // LA latitude
        -118.2437, // LA longitude
      );

      // Distance should be approximately 559 km (559000 meters)
      // Allow for some variance in calculation
      expect(distance, greaterThan(550000));
      expect(distance, lessThan(570000));
    });

    test('calculateDistance returns zero for same coordinates', () {
      final distance = locationService.calculateDistance(
        37.7749,
        -122.4194,
        37.7749,
        -122.4194,
      );

      expect(distance, equals(0.0));
    });

    test('calculateDistance handles coordinates at different hemispheres', () {
      // Test with coordinates in different hemispheres
      final distance = locationService.calculateDistance(
        40.7128, // New York
        -74.0060,
        51.5074, // London
        -0.1278,
      );

      // Distance should be approximately 5570 km
      expect(distance, greaterThan(5500000));
      expect(distance, lessThan(5600000));
    });
  });
}
