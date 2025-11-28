/// Fuel types for vehicles
enum FuelType {
  /// Gasoline/petrol fuel
  gasoline,
  
  /// Diesel fuel
  diesel,
  
  /// Electric vehicle
  electric,
  
  /// Hybrid (gasoline + electric)
  hybrid,
  
  /// Liquefied Petroleum Gas
  lpg,
}

/// Extension to convert fuel type to/from database string
extension FuelTypeExtension on FuelType {
  String toDbString() {
    switch (this) {
      case FuelType.gasoline:
        return 'GASOLINE';
      case FuelType.diesel:
        return 'DIESEL';
      case FuelType.electric:
        return 'ELECTRIC';
      case FuelType.hybrid:
        return 'HYBRID';
      case FuelType.lpg:
        return 'LPG';
    }
  }

  String get displayName {
    switch (this) {
      case FuelType.gasoline:
        return 'Gasoline';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.electric:
        return 'Electric';
      case FuelType.hybrid:
        return 'Hybrid';
      case FuelType.lpg:
        return 'LPG';
    }
  }

  static FuelType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'GASOLINE':
        return FuelType.gasoline;
      case 'DIESEL':
        return FuelType.diesel;
      case 'ELECTRIC':
        return FuelType.electric;
      case 'HYBRID':
        return FuelType.hybrid;
      case 'LPG':
        return FuelType.lpg;
      default:
        throw ArgumentError('Unknown fuel type: $value');
    }
  }
}
