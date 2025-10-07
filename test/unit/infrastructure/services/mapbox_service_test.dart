import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vanvoyage/infrastructure/services/mapbox_service.dart';

import 'mapbox_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('MapboxService', () {
    late MapboxService mapboxService;
    late MockClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockClient();
      mapboxService = MapboxService(
        apiKey: 'test_api_key',
        httpClient: mockHttpClient,
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

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(responseBody, 200),
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

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(responseBody, 200),
        );

        final result = await mapboxService.geocode('NonexistentPlace12345');

        expect(result, isNull);
      });

      test('throws exception on API error', () async {
        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response('Not Found', 404),
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

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(responseBody, 200),
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

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(responseBody, 200),
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

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(responseBody, 200),
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

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(responseBody, 200),
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

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(responseBody, 200),
        );

        final result = await mapboxService.calculateRoute(
          37.7749, -122.4194,
          34.0522, -118.2437,
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

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(responseBody, 200),
        );

        final result = await mapboxService.calculateRoute(
          37.7749, -122.4194,
          34.0522, -118.2437,
        );

        expect(result, isNull);
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
