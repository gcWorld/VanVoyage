/// Waypoint type enumeration representing the type of location.
enum WaypointType {
  /// Location where traveler will sleep
  overnightStay,
  
  /// Point of interest to visit
  poi,
  
  /// Waypoint for routing purposes only
  transit;

  /// Converts string to WaypointType enum
  static WaypointType fromString(String value) {
    final normalized = value.toUpperCase().replaceAll('_', '');
    
    switch (normalized) {
      case 'OVERNIGHTSTAY':
        return WaypointType.overnightStay;
      case 'POI':
        return WaypointType.poi;
      case 'TRANSIT':
        return WaypointType.transit;
      default:
        return WaypointType.poi;
    }
  }

  /// Converts enum to database string representation
  String toDbString() {
    switch (this) {
      case WaypointType.overnightStay:
        return 'OVERNIGHT_STAY';
      case WaypointType.poi:
        return 'POI';
      case WaypointType.transit:
        return 'TRANSIT';
    }
  }
}
