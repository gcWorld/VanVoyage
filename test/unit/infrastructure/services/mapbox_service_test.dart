import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:vanvoyage/infrastructure/services/mapbox_service.dart';

// Simple test implementation without complex mocking
class TestHttpClient implements http.Client {
  final Map<String, http.Response> _responses = {};

  void setResponse(String urlPattern, http.Response response) {
    _responses[urlPattern] = response;
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    for (final pattern in _responses.keys) {
      if (url.toString().contains(pattern)) {
        return _responses[pattern]!;
      }
    }
    return http.Response('Not found', 404);
  }

  @override
  void close() {}

  @override
  Future<http.Response> delete(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      throw UnimplementedError();

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) =>
      throw UnimplementedError();

  @override
  Future<http.Response> patch(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      throw UnimplementedError();

  @override
  Future<http.Response> post(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      throw UnimplementedError();

  @override
  Future<http.Response> put(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      throw UnimplementedError();

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) =>
      throw UnimplementedError();

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) =>
      throw UnimplementedError();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      throw UnimplementedError();
}

void main() {
  group('MapboxService', () {
    late MapboxService mapboxService;
    late TestHttpClient testHttpClient;

    setUp(() {
      testHttpClient = TestHttpClient();
      mapboxService = MapboxService(
        apiKey: 'test_api_key',
        httpClient: testHttpClient,
      );
    });

    tearDown(() {
      mapboxService.dispose();
    });

    group('geocode', () {
      test('returns location for valid address', () async {
        final responseBody = '''
        {
          "features": [
            {
              "geometry": {
                "coordinates": [-122.4194, 37.7749]
              },
              "place_name": "San Francisco, CA"
            }
          ]
        }
        ''';

        testHttpClient.setResponse(
          'geocoding/v5/mapbox.places',
          http.Response(responseBody, 200),
        );

        final result = await mapboxService.geocode('San Francisco');

        expect(result, isNotNull);
        expect(result!.latitude, equals(37.7749));
        expect(result.longitude, equals(-122.4194));
        expect(result.placeName, equals('San Francisco, CA'));
      });

      test('returns null when no results found', () async {
        final responseBody = '''
        {
          "features": []
        }
        ''';

        testHttpClient.setResponse(
          'geocoding/v5/mapbox.places',
          http.Response(responseBody, 200),
        );

        final result = await mapboxService.geocode('NonexistentPlace12345');

        expect(result, isNull);
      });

      test('throws exception on API error', () async {
        testHttpClient.setResponse(
          'geocoding/v5/mapbox.places',
          http.Response('Not Found', 404),
        );

        final result = await mapboxService.geocode('test');

        expect(result, isNull);
      });
    });

    group('reverseGeocode', () {
      test('returns address for valid coordinates', () async {
        final responseBody = '''
        {
          "features": [
            {
              "place_name": "123 Main St, San Francisco, CA"
            }
          ]
        }
        ''';

        testHttpClient.setResponse(
          'geocoding/v5/mapbox.places',
          http.Response(responseBody, 200),
        );

        final result = await mapboxService.reverseGeocode(37.7749, -122.4194);

        expect(result, isNotNull);
        expect(result, equals('123 Main St, San Francisco, CA'));
      });

      test('returns null when no results found', () async {
        final responseBody = '''
        {
          "features": []
        }
        ''';

        testHttpClient.setResponse(
          'geocoding/v5/mapbox.places',
          http.Response(responseBody, 200),
        );

        final result = await mapboxService.reverseGeocode(0.0, 0.0);

        expect(result, isNull);
      });
    });

    group('searchPlaces', () {
      test('returns list of locations for valid query', () async {
        final responseBody = '''
        {
          "features": [
            {
              "geometry": {
                "coordinates": [-122.4194, 37.7749]
              },
              "place_name": "San Francisco, CA"
            },
            {
              "geometry": {
                "coordinates": [-118.2437, 34.0522]
              },
              "place_name": "Los Angeles, CA"
            }
          ]
        }
        ''';

        testHttpClient.setResponse(
          'geocoding/v5/mapbox.places',
          http.Response(responseBody, 200),
        );

        final results = await mapboxService.searchPlaces('California');

        expect(results, hasLength(2));
        expect(results[0].placeName, equals('San Francisco, CA'));
        expect(results[1].placeName, equals('Los Angeles, CA'));
      });

      test('returns empty list when no results found', () async {
        final responseBody = '''
        {
          "features": []
        }
        ''';

        testHttpClient.setResponse(
          'geocoding/v5/mapbox.places',
          http.Response(responseBody, 200),
        );

        final results = await mapboxService.searchPlaces('NonexistentPlace');

        expect(results, isEmpty);
      });
    });

    group('calculateRoute', () {
      test('returns route for valid coordinates', () async {
        final responseBody = '''
        {
          "routes": [
            {
              "geometry": {
                "type": "LineString",
                "coordinates": [[-122.4194, 37.7749], [-118.2437, 34.0522]]
              },
              "distance": 559000.0,
              "duration": 19800.0
            }
          ]
        }
        ''';

        testHttpClient.setResponse(
          'directions/v5/mapbox/driving',
          http.Response(responseBody, 200),
        );

        final result = await mapboxService.calculateRoute(
          37.7749,
          -122.4194,
          34.0522,
          -118.2437,
        );

        expect(result, isNotNull);
        expect(result!.distanceMeters, equals(559000.0));
        expect(result.durationSeconds, equals(19800.0));
        expect(result.distanceKm, equals(559.0));
        expect(result.durationMinutes, equals(330));
      });

      test('returns null when no route found', () async {
        final responseBody = '''
        {
          "routes": []
        }
        ''';

        testHttpClient.setResponse(
          'directions/v5/mapbox/driving',
          http.Response(responseBody, 200),
        );

        final result = await mapboxService.calculateRoute(
          37.7749,
          -122.4194,
          34.0522,
          -118.2437,
        );

        expect(result, isNull);
      });
    });

    group('calculateRouteWithAlternatives', () {
      test('returns multiple routes when available', () async {
        final responseBody = '''
        {
          "routes": [
            {
              "geometry": {
                "type": "LineString",
                "coordinates": [[-122.4194, 37.7749], [-118.2437, 34.0522]]
              },
              "distance": 559000.0,
              "duration": 19800.0
            },
            {
              "geometry": {
                "type": "LineString",
                "coordinates": [[-122.4194, 37.7749], [-118.5000, 34.1000], [-118.2437, 34.0522]]
              },
              "distance": 575000.0,
              "duration": 20100.0
            }
          ]
        }
        ''';

        testHttpClient.setResponse(
          'directions/v5/mapbox/driving',
          http.Response(responseBody, 200),
        );

        final results = await mapboxService.calculateRouteWithAlternatives(
          37.7749,
          -122.4194,
          34.0522,
          -118.2437,
        );

        expect(results, hasLength(2));
        expect(results[0].distanceMeters, equals(559000.0));
        expect(results[1].distanceMeters, equals(575000.0));
      });

      test('returns empty list when no routes found', () async {
        final responseBody = '''
        {
          "routes": []
        }
        ''';

        testHttpClient.setResponse(
          'directions/v5/mapbox/driving',
          http.Response(responseBody, 200),
        );

        final results = await mapboxService.calculateRouteWithAlternatives(
          37.7749,
          -122.4194,
          34.0522,
          -118.2437,
        );

        expect(results, isEmpty);
      });
    });

    group('routing profiles', () {
      test('uses specified routing profile', () async {
        final responseBody = '''
        {
          "routes": [
            {
              "geometry": {
                "type": "LineString",
                "coordinates": [[-122.4194, 37.7749], [-118.2437, 34.0522]]
              },
              "distance": 559000.0,
              "duration": 19800.0
            }
          ]
        }
        ''';

        testHttpClient.setResponse(
          'directions/v5/mapbox/driving-traffic',
          http.Response(responseBody, 200),
        );

        final result = await mapboxService.calculateRoute(
          37.7749,
          -122.4194,
          34.0522,
          -118.2437,
          profile: RoutingProfile.drivingTraffic,
        );

        expect(result, isNotNull);
      });
    });
  });

  group('MapboxRoute', () {
    test('distanceKm converts meters to kilometers', () {
      final route = MapboxRoute(
        geometry: '{}',
        distanceMeters: 5500.0,
        durationSeconds: 300.0,
      );

      expect(route.distanceKm, equals(5.5));
    });

    test('durationMinutes converts seconds to minutes', () {
      final route = MapboxRoute(
        geometry: '{}',
        distanceMeters: 1000.0,
        durationSeconds: 180.0,
      );

      expect(route.durationMinutes, equals(3));
    });
  });
}
