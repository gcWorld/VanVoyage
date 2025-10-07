# Infrastructure Services

This directory contains service classes that interact with external systems and APIs.

## LocationService

Manages GPS location tracking and permissions using the `geolocator` package.

### Key Methods

- `getCurrentLocation()`: Get one-time location fix
- `getLocationStream()`: Stream of location updates (updates every 10 meters)
- `hasPermission()`: Check if location permissions are granted
- `requestPermission()`: Request location permissions from user
- `isLocationServiceEnabled()`: Check if device location services are on
- `calculateDistance()`: Calculate distance between two coordinates in meters

### Usage Example

```dart
final locationService = LocationService();

// Get current location
final position = await locationService.getCurrentLocation();
print('Lat: ${position.latitude}, Lng: ${position.longitude}');

// Track location changes
locationService.getLocationStream().listen((position) {
  print('Moved to: ${position.latitude}, ${position.longitude}');
});

// Calculate distance
final distance = locationService.calculateDistance(
  startLat, startLng,
  endLat, endLng,
);
print('Distance: ${distance}m');
```

## MapboxService

Interfaces with Mapbox APIs for geocoding, search, and routing.

### Key Methods

- `geocode(address)`: Convert address string to coordinates
- `reverseGeocode(lat, lng)`: Convert coordinates to address
- `searchPlaces(query)`: Search for locations by name
- `calculateRoute(startLat, startLng, endLat, endLng)`: Get driving directions

### Usage Example

```dart
final mapboxService = MapboxService(apiKey: 'your_api_key');

// Geocode an address
final location = await mapboxService.geocode('San Francisco, CA');
if (location != null) {
  print('Found: ${location.placeName}');
  print('At: ${location.latitude}, ${location.longitude}');
}

// Search for places
final results = await mapboxService.searchPlaces('coffee shops');
for (var place in results) {
  print('${place.placeName}: ${place.latitude}, ${place.longitude}');
}

// Calculate a route
final route = await mapboxService.calculateRoute(
  37.7749, -122.4194, // San Francisco
  34.0522, -118.2437, // Los Angeles
);
if (route != null) {
  print('Distance: ${route.distanceKm}km');
  print('Duration: ${route.durationMinutes}min');
}

// Clean up when done
mapboxService.dispose();
```

## Providers

Services are available as Riverpod providers in `lib/providers.dart`:

```dart
// In your widget
final locationService = ref.watch(locationServiceProvider);
final mapboxService = ref.watch(mapboxServiceProvider);
```

## API Keys

The `MapboxService` requires a valid Mapbox API key:

1. Get your key at https://account.mapbox.com/
2. Copy `lib/secrets.dart.template` to `lib/secrets.dart`
3. Add your key to the file

**Note:** `secrets.dart` is git-ignored to prevent accidental key exposure.

## Testing

Mock implementations are provided for testing:

```dart
// Use mockito to mock services
final mockHttpClient = MockClient();
final mapboxService = MapboxService(
  apiKey: 'test_key',
  httpClient: mockHttpClient,
);
```

See `test/unit/infrastructure/services/` for examples.

## Error Handling

Services throw exceptions when:
- Location permissions are denied
- Location services are disabled
- Network requests fail
- API responses are invalid

Always wrap service calls in try-catch blocks:

```dart
try {
  final position = await locationService.getCurrentLocation();
  // Use position
} catch (e) {
  print('Failed to get location: $e');
  // Handle error
}
```

## Dependencies

- **geolocator** (^10.1.0): GPS and location services
- **http** (^1.1.0): HTTP client for API requests
- **mapbox_maps_flutter** (^1.1.0): Mapbox GL map widget
