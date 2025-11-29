import 'dart:convert';
import 'package:http/http.dart' as http;

/// Routing profile for route calculations
enum RoutingProfile {
  /// Standard driving route (fastest route considering traffic)
  driving,

  /// Driving route with real-time traffic data
  drivingTraffic,

  /// Walking route
  walking,

  /// Cycling route
  cycling,
}

/// Extension to convert routing profile to API string
extension RoutingProfileExtension on RoutingProfile {
  String toApiString() {
    switch (this) {
      case RoutingProfile.driving:
        return 'driving';
      case RoutingProfile.drivingTraffic:
        return 'driving-traffic';
      case RoutingProfile.walking:
        return 'walking';
      case RoutingProfile.cycling:
        return 'cycling';
    }
  }
}

/// Service for interacting with Mapbox APIs
class MapboxService {
  final String _apiKey;
  final http.Client _httpClient;

  MapboxService({
    required String apiKey,
    http.Client? httpClient,
  })  : _apiKey = apiKey,
        _httpClient = httpClient ?? http.Client();

  /// Geocode an address to coordinates
  Future<MapboxLocation?> geocode(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$encodedAddress.json?access_token=$_apiKey',
    );

    try {
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;

        if (features.isNotEmpty) {
          final feature = features.first;
          final coordinates = feature['geometry']['coordinates'] as List;
          final placeName = feature['place_name'] as String;

          return MapboxLocation(
            longitude: coordinates[0] as double,
            latitude: coordinates[1] as double,
            placeName: placeName,
          );
        }
      }
    } catch (e) {
      throw Exception('Failed to geocode address: $e');
    }

    return null;
  }

  /// Reverse geocode coordinates to address
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude,$latitude.json?access_token=$_apiKey',
    );

    try {
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;

        if (features.isNotEmpty) {
          final feature = features.first;
          return feature['place_name'] as String;
        }
      }
    } catch (e) {
      throw Exception('Failed to reverse geocode: $e');
    }

    return null;
  }

  /// Search for places matching a query
  Future<List<MapboxLocation>> searchPlaces(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$encodedQuery.json?access_token=$_apiKey&limit=10',
    );

    try {
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;

        return features.map((feature) {
          final coordinates = feature['geometry']['coordinates'] as List;
          final placeName = feature['place_name'] as String;

          return MapboxLocation(
            longitude: coordinates[0] as double,
            latitude: coordinates[1] as double,
            placeName: placeName,
          );
        }).toList();
      }
    } catch (e) {
      throw Exception('Failed to search places: $e');
    }

    return [];
  }

  /// Calculate route between two points
  Future<MapboxRoute?> calculateRoute(
    double startLat,
    double startLng,
    double endLat,
    double endLng, {
    bool alternatives = false,
    RoutingProfile profile = RoutingProfile.driving,
  }) async {
    final alternativesParam = alternatives ? '&alternatives=true' : '';
    final profileString = profile.toApiString();
    final url = Uri.parse(
      'https://api.mapbox.com/directions/v5/mapbox/$profileString/$startLng,$startLat;$endLng,$endLat?'
      'geometries=geojson&overview=full&steps=true$alternativesParam&access_token=$_apiKey',
    );

    try {
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List;

        if (routes.isNotEmpty) {
          final route = routes.first;
          final geometry = route['geometry'];
          final distance = route['distance'] as num;
          final duration = route['duration'] as num;

          return MapboxRoute(
            geometry: json.encode(geometry),
            distanceMeters: distance.toDouble(),
            durationSeconds: duration.toDouble(),
          );
        }
      }
    } catch (e) {
      throw Exception('Failed to calculate route: $e');
    }

    return null;
  }

  /// Calculate route with alternative routes
  Future<List<MapboxRoute>> calculateRouteWithAlternatives(
    double startLat,
    double startLng,
    double endLat,
    double endLng, {
    RoutingProfile profile = RoutingProfile.driving,
  }) async {
    final profileString = profile.toApiString();
    final url = Uri.parse(
      'https://api.mapbox.com/directions/v5/mapbox/$profileString/$startLng,$startLat;$endLng,$endLat?'
      'geometries=geojson&overview=full&steps=true&alternatives=true&access_token=$_apiKey',
    );

    try {
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List;

        return routes.map((route) {
          final geometry = route['geometry'];
          final distance = route['distance'] as num;
          final duration = route['duration'] as num;

          return MapboxRoute(
            geometry: json.encode(geometry),
            distanceMeters: distance.toDouble(),
            durationSeconds: duration.toDouble(),
          );
        }).toList();
      }
    } catch (e) {
      throw Exception('Failed to calculate routes: $e');
    }

    return [];
  }

  void dispose() {
    _httpClient.close();
  }
}

/// Represents a location from Mapbox geocoding
class MapboxLocation {
  final double latitude;
  final double longitude;
  final String placeName;

  MapboxLocation({
    required this.latitude,
    required this.longitude,
    required this.placeName,
  });
}

/// Represents a route calculated by Mapbox
class MapboxRoute {
  final String geometry;
  final double distanceMeters;
  final double durationSeconds;

  MapboxRoute({
    required this.geometry,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  double get distanceKm => distanceMeters / 1000;
  int get durationMinutes => (durationSeconds / 60).round();
}
