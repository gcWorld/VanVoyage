import 'package:flutter_test/flutter_test.dart';
import 'package:vanvoyage/domain/entities/vehicle.dart';
import 'package:vanvoyage/domain/enums/fuel_type.dart';

void main() {
  group('Vehicle', () {
    test('should create a Vehicle with factory constructor', () {
      final vehicle = Vehicle.create(
        name: 'My Camper Van',
        fuelType: FuelType.diesel,
        fuelConsumption: 10.5,
        height: 2.8,
        width: 2.2,
        weight: 3.5,
      );

      expect(vehicle.name, 'My Camper Van');
      expect(vehicle.fuelType, FuelType.diesel);
      expect(vehicle.fuelConsumption, 10.5);
      expect(vehicle.height, 2.8);
      expect(vehicle.width, 2.2);
      expect(vehicle.weight, 3.5);
      expect(vehicle.id, isNotEmpty);
      expect(vehicle.isDefault, false);
    });

    test('should validate vehicle with valid data', () {
      final vehicle = Vehicle.create(
        name: 'Test Van',
        fuelType: FuelType.diesel,
        fuelConsumption: 10.0,
        height: 3.0,
        width: 2.5,
        weight: 3.5,
        maxSpeed: 100,
      );

      expect(vehicle.isValid(), true);
    });

    test('should invalidate vehicle with empty name', () {
      final vehicle = Vehicle.create(
        name: '',
        fuelType: FuelType.diesel,
        fuelConsumption: 10.0,
      );

      expect(vehicle.isValid(), false);
    });

    test('should invalidate vehicle with zero fuel consumption', () {
      final vehicle = Vehicle.create(
        name: 'Test Van',
        fuelType: FuelType.diesel,
        fuelConsumption: 0,
      );

      expect(vehicle.isValid(), false);
    });

    test('should invalidate vehicle with height out of range', () {
      final vehicle = Vehicle.create(
        name: 'Test Van',
        fuelType: FuelType.diesel,
        fuelConsumption: 10.0,
        height: 15.0, // Max is 10
      );

      expect(vehicle.isValid(), false);
    });

    test('should invalidate vehicle with weight out of range', () {
      final vehicle = Vehicle.create(
        name: 'Test Van',
        fuelType: FuelType.diesel,
        fuelConsumption: 10.0,
        weight: 150.0, // Max is 100
      );

      expect(vehicle.isValid(), false);
    });

    test('should serialize to and from map correctly', () {
      final originalVehicle = Vehicle.create(
        name: 'Test Van',
        fuelType: FuelType.hybrid,
        fuelConsumption: 8.5,
        height: 2.5,
        width: 2.0,
        length: 6.0,
        weight: 3.0,
        maxSpeed: 110,
        isDefault: true,
      );

      final map = originalVehicle.toMap();
      final deserializedVehicle = Vehicle.fromMap(map);

      expect(deserializedVehicle.id, originalVehicle.id);
      expect(deserializedVehicle.name, originalVehicle.name);
      expect(deserializedVehicle.fuelType, originalVehicle.fuelType);
      expect(deserializedVehicle.fuelConsumption, originalVehicle.fuelConsumption);
      expect(deserializedVehicle.height, originalVehicle.height);
      expect(deserializedVehicle.width, originalVehicle.width);
      expect(deserializedVehicle.length, originalVehicle.length);
      expect(deserializedVehicle.weight, originalVehicle.weight);
      expect(deserializedVehicle.maxSpeed, originalVehicle.maxSpeed);
      expect(deserializedVehicle.isDefault, originalVehicle.isDefault);
    });

    test('should create a copy with updated fields', () {
      final originalVehicle = Vehicle.create(
        name: 'Original Van',
        fuelType: FuelType.diesel,
        fuelConsumption: 10.0,
      );

      final updatedVehicle = originalVehicle.copyWith(
        name: 'Updated Van',
        fuelType: FuelType.electric,
        isDefault: true,
      );

      expect(updatedVehicle.name, 'Updated Van');
      expect(updatedVehicle.fuelType, FuelType.electric);
      expect(updatedVehicle.isDefault, true);
      expect(updatedVehicle.id, originalVehicle.id);
      expect(updatedVehicle.fuelConsumption, originalVehicle.fuelConsumption);
    });

    test('should correctly report hasDimensionConstraints', () {
      final vehicleWithConstraints = Vehicle.create(
        name: 'With Constraints',
        fuelType: FuelType.diesel,
        fuelConsumption: 10.0,
        height: 3.0,
      );

      final vehicleWithoutConstraints = Vehicle.create(
        name: 'Without Constraints',
        fuelType: FuelType.diesel,
        fuelConsumption: 10.0,
      );

      expect(vehicleWithConstraints.hasDimensionConstraints, true);
      expect(vehicleWithoutConstraints.hasDimensionConstraints, false);
    });

    test('should be equal when all properties match', () {
      final now = DateTime.now();
      final vehicle1 = Vehicle(
        id: '123',
        name: 'Test Van',
        fuelType: FuelType.diesel,
        fuelConsumption: 10.0,
        isDefault: false,
        createdAt: now,
        updatedAt: now,
      );

      final vehicle2 = Vehicle(
        id: '123',
        name: 'Test Van',
        fuelType: FuelType.diesel,
        fuelConsumption: 10.0,
        isDefault: false,
        createdAt: now,
        updatedAt: now,
      );

      expect(vehicle1, equals(vehicle2));
    });
  });

  group('FuelType', () {
    test('should convert from string correctly', () {
      expect(FuelTypeExtension.fromString('GASOLINE'), FuelType.gasoline);
      expect(FuelTypeExtension.fromString('DIESEL'), FuelType.diesel);
      expect(FuelTypeExtension.fromString('ELECTRIC'), FuelType.electric);
      expect(FuelTypeExtension.fromString('HYBRID'), FuelType.hybrid);
      expect(FuelTypeExtension.fromString('LPG'), FuelType.lpg);
    });

    test('should convert to database string correctly', () {
      expect(FuelType.gasoline.toDbString(), 'GASOLINE');
      expect(FuelType.diesel.toDbString(), 'DIESEL');
      expect(FuelType.electric.toDbString(), 'ELECTRIC');
      expect(FuelType.hybrid.toDbString(), 'HYBRID');
      expect(FuelType.lpg.toDbString(), 'LPG');
    });

    test('should have display names', () {
      expect(FuelType.gasoline.displayName, 'Gasoline');
      expect(FuelType.diesel.displayName, 'Diesel');
      expect(FuelType.electric.displayName, 'Electric');
      expect(FuelType.hybrid.displayName, 'Hybrid');
      expect(FuelType.lpg.displayName, 'LPG');
    });

    test('should throw on unknown fuel type', () {
      expect(
        () => FuelTypeExtension.fromString('UNKNOWN'),
        throwsArgumentError,
      );
    });
  });
}
