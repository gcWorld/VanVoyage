/// Pre-calculated demo route data for offline/demo usage
/// These routes represent the California adventure demo trip:
/// San Francisco -> Yosemite -> Lake Tahoe -> Sacramento

/// Represents a demo route segment with all its data
class _DemoRouteSegment {
  final String geometry;
  final double distanceKm;
  final int durationMinutes;

  const _DemoRouteSegment({
    required this.geometry,
    required this.distanceKm,
    required this.durationMinutes,
  });
}

/// Identifies a route by checking if both locations match
class _RouteKey {
  final String fromPattern;
  final String toPattern;

  const _RouteKey(this.fromPattern, this.toPattern);

  bool matches(String fromName, String toName) {
    final from = fromName.toLowerCase();
    final to = toName.toLowerCase();
    return from.contains(fromPattern) && to.contains(toPattern);
  }
}

class DemoRouteData {
  /// Route from San Francisco to Yosemite National Park
  /// Approximate distance: 280 km, duration: 3.5 hours
  static const String _sanFranciscoToYosemiteGeometry = '''
{
  "type": "LineString",
  "coordinates": [
    [-122.4194, 37.7749],
    [-122.3894, 37.7649],
    [-122.2794, 37.7849],
    [-122.1494, 37.8249],
    [-121.9194, 37.8549],
    [-121.6894, 37.8549],
    [-121.4594, 37.7849],
    [-121.2294, 37.7549],
    [-120.9994, 37.7649],
    [-120.7694, 37.7749],
    [-120.5394, 37.7949],
    [-120.2094, 37.8049],
    [-119.9394, 37.8349],
    [-119.7383, 37.8451],
    [-119.5383, 37.8651]
  ]
}
''';

  /// Route from Yosemite National Park to Lake Tahoe
  /// Approximate distance: 160 km, duration: 2.5 hours
  static const String _yosemiteToLakeTahoeGeometry = '''
{
  "type": "LineString",
  "coordinates": [
    [-119.5383, 37.8651],
    [-119.6083, 37.9251],
    [-119.6783, 38.0151],
    [-119.7483, 38.1251],
    [-119.8183, 38.2351],
    [-119.8883, 38.3651],
    [-119.9383, 38.4951],
    [-119.9683, 38.6251],
    [-119.9883, 38.7551],
    [-120.0024, 38.8851],
    [-120.0224, 39.0168],
    [-120.0324, 39.0968]
  ]
}
''';

  /// Route from Lake Tahoe to Sacramento
  /// Approximate distance: 165 km, duration: 2 hours
  static const String _lakeTahoeToSacramentoGeometry = '''
{
  "type": "LineString",
  "coordinates": [
    [-120.0324, 39.0968],
    [-120.1524, 39.0168],
    [-120.2924, 38.9368],
    [-120.4524, 38.8568],
    [-120.6324, 38.7768],
    [-120.8124, 38.6968],
    [-120.9924, 38.6468],
    [-121.1524, 38.6168],
    [-121.2944, 38.5968],
    [-121.4944, 38.5816]
  ]
}
''';

  /// Distance in km for each demo route segment
  static const double sfToYosemiteDistanceKm = 280.0;
  static const double yosemiteToTahoeDistanceKm = 160.0;
  static const double tahoeToSacramentoDistanceKm = 165.0;

  /// Duration in minutes for each demo route segment
  static const int sfToYosemiteDurationMinutes = 210; // 3.5 hours
  static const int yosemiteToTahoeDurationMinutes = 150; // 2.5 hours
  static const int tahoeToSacramentoDurationMinutes = 120; // 2 hours

  /// Map of route patterns to their data
  static final List<MapEntry<_RouteKey, _DemoRouteSegment>> _demoRoutes = [
    MapEntry(
      const _RouteKey('francisco', 'yosemite'),
      _DemoRouteSegment(
        geometry: _sanFranciscoToYosemiteGeometry.trim(),
        distanceKm: sfToYosemiteDistanceKm,
        durationMinutes: sfToYosemiteDurationMinutes,
      ),
    ),
    MapEntry(
      const _RouteKey('yosemite', 'tahoe'),
      _DemoRouteSegment(
        geometry: _yosemiteToLakeTahoeGeometry.trim(),
        distanceKm: yosemiteToTahoeDistanceKm,
        durationMinutes: yosemiteToTahoeDurationMinutes,
      ),
    ),
    MapEntry(
      const _RouteKey('tahoe', 'sacramento'),
      _DemoRouteSegment(
        geometry: _lakeTahoeToSacramentoGeometry.trim(),
        distanceKm: tahoeToSacramentoDistanceKm,
        durationMinutes: tahoeToSacramentoDurationMinutes,
      ),
    ),
  ];

  /// Find demo route data for the given waypoint names
  static _DemoRouteSegment? _findRoute(String fromName, String toName) {
    for (final entry in _demoRoutes) {
      if (entry.key.matches(fromName, toName)) {
        return entry.value;
      }
    }
    return null;
  }

  /// Get demo route geometry by waypoint names
  static String? getRouteGeometry(String fromName, String toName) {
    return _findRoute(fromName, toName)?.geometry;
  }

  /// Get demo route distance by waypoint names
  static double? getRouteDistance(String fromName, String toName) {
    return _findRoute(fromName, toName)?.distanceKm;
  }

  /// Get demo route duration by waypoint names
  static int? getRouteDuration(String fromName, String toName) {
    return _findRoute(fromName, toName)?.durationMinutes;
  }

  /// Check if this is a known demo route
  static bool isDemoRoute(String fromName, String toName) {
    return _findRoute(fromName, toName) != null;
  }
}

