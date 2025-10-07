# Map Integration Overview

## Implementation Summary

This document provides an overview of the Mapbox integration implemented for VanVoyage.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │        InteractiveMapScreen                        │    │
│  │  - MapWidget (Mapbox GL)                          │    │
│  │  - Zoom Controls (FABs)                           │    │
│  │  - Location Tracking Toggle                       │    │
│  │  - Center on Location Button                      │    │
│  │  - Location Info Card                             │    │
│  └────────────────────────────────────────────────────┘    │
│                          ▲                                   │
│                          │                                   │
│                          │ uses providers                    │
│                          │                                   │
└──────────────────────────┼───────────────────────────────────┘
                           │
                           │
┌──────────────────────────┼───────────────────────────────────┐
│                     Infrastructure Layer                      │
│                          │                                    │
│  ┌───────────────────────┴──────────────────┐               │
│  │        Riverpod Providers                │               │
│  │  - locationServiceProvider               │               │
│  │  - mapboxServiceProvider                 │               │
│  └───────────┬──────────────────┬───────────┘               │
│              │                  │                            │
│              ▼                  ▼                            │
│  ┌─────────────────┐  ┌─────────────────────┐              │
│  │ LocationService │  │   MapboxService      │              │
│  │                 │  │                      │              │
│  │ • getCurrentLoc │  │ • geocode()          │              │
│  │ • getStream()   │  │ • reverseGeocode()   │              │
│  │ • permissions   │  │ • searchPlaces()     │              │
│  │ • calculate     │  │ • calculateRoute()   │              │
│  │   Distance()    │  │                      │              │
│  └────────┬────────┘  └──────────┬───────────┘              │
│           │                      │                           │
└───────────┼──────────────────────┼───────────────────────────┘
            │                      │
            │                      │
            ▼                      ▼
┌────────────────────┐  ┌──────────────────────┐
│   Geolocator       │  │   Mapbox APIs        │
│   Package          │  │   (HTTP)             │
│                    │  │                      │
│ • GPS Hardware     │  │ • Geocoding API      │
│ • Permissions      │  │ • Directions API     │
│ • Location Stream  │  │ • Places API         │
└────────────────────┘  └──────────────────────┘
```

## Component Details

### InteractiveMapScreen

**Purpose**: Main map interface for visualizing and planning trips

**Features**:
- Full-screen Mapbox GL map
- Interactive controls (zoom, pan, rotate)
- Real-time location tracking
- Location permission management
- Error handling with user feedback

**Controls**:
1. **Zoom In** (+): Increase zoom level
2. **Zoom Out** (-): Decrease zoom level
3. **Center on Location** (target icon): Center map on current position
4. **Toggle Tracking** (location icon): Enable/disable continuous tracking

**State**:
- `_mapboxMap`: Reference to Mapbox map controller
- `_currentPosition`: Latest GPS position
- `_isTrackingLocation`: Whether continuous tracking is enabled

### LocationService

**Purpose**: Abstract GPS and location functionality

**Key Methods**:
```dart
Future<Position> getCurrentLocation()
Stream<Position> getLocationStream()
Future<bool> hasPermission()
Future<bool> requestPermission()
double calculateDistance(lat1, lng1, lat2, lng2)
```

**Dependencies**: `geolocator` package

### MapboxService

**Purpose**: Interface with Mapbox APIs for geocoding and routing

**Key Methods**:
```dart
Future<MapboxLocation?> geocode(String address)
Future<String?> reverseGeocode(double lat, double lng)
Future<List<MapboxLocation>> searchPlaces(String query)
Future<MapboxRoute?> calculateRoute(startLat, startLng, endLat, endLng)
```

**Dependencies**: 
- `http` package for API calls
- Requires valid Mapbox API key

## Map Styles

Currently using **Mapbox Outdoors** style:
- Optimized for outdoor activities
- Shows terrain and natural features
- Good for trip planning and hiking

Available styles in `mapbox_maps_flutter`:
- `MapboxStyles.OUTDOORS` - Current
- `MapboxStyles.STREETS` - Standard street map
- `MapboxStyles.SATELLITE_STREETS` - Satellite imagery with labels
- `MapboxStyles.LIGHT` - Light theme
- `MapboxStyles.DARK` - Dark theme

## Data Flow

### Location Tracking Flow

```
User opens map
     ↓
Request location permission
     ↓
Get current location
     ↓
Display map centered on location
     ↓
Enable location component (blue dot)
     ↓
[Optional] User enables tracking
     ↓
Stream location updates
     ↓
Update map camera position
     ↓
Update location info card
```

### Geocoding Flow

```
User enters address
     ↓
MapboxService.geocode(address)
     ↓
HTTP GET to Mapbox Geocoding API
     ↓
Parse JSON response
     ↓
Return MapboxLocation object
     ↓
Display on map / use coordinates
```

## Testing Strategy

### Unit Tests
- `location_service_test.dart`: Distance calculation accuracy
- `mapbox_service_test.dart`: API response parsing (mocked HTTP)

### Widget Tests
- `interactive_map_screen_test.dart`: UI component rendering

### Integration Tests (Future)
- End-to-end location tracking
- Map interaction flows
- Permission handling

## Configuration

### Required Setup

1. **Get Mapbox API Key**
   - Visit https://account.mapbox.com/
   - Create account and generate access token

2. **Configure Secrets**
   ```bash
   cp lib/secrets.dart.template lib/secrets.dart
   # Edit lib/secrets.dart and add your API key
   ```

3. **Platform Permissions**
   
   **Android** (`AndroidManifest.xml`):
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
   ```

   **iOS** (`Info.plist`):
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>We need your location to show it on the map</string>
   <key>NSLocationAlwaysUsageDescription</key>
   <string>We need your location for trip tracking</string>
   ```

## Future Enhancements

### Phase 1: Waypoint Display
- [ ] Display trip waypoints on map
- [ ] Color-coded markers by waypoint type
- [ ] Tap marker to show details
- [ ] Long press to add new waypoint

### Phase 2: Route Visualization
- [ ] Draw route lines between waypoints
- [ ] Calculate and display total distance
- [ ] Show estimated travel time
- [ ] Toggle route visibility

### Phase 3: Search & Discovery
- [ ] Location search bar
- [ ] Place suggestions as you type
- [ ] Filter by place type
- [ ] Save searched locations

### Phase 4: Advanced Features
- [ ] Offline map support
- [ ] Custom map styles
- [ ] Trip animation/replay
- [ ] Export route as GPX
- [ ] Share location/route

## Performance Considerations

### Location Updates
- Updates every 10 meters to balance accuracy and battery
- Only active when tracking is enabled
- Automatically stops when screen is disposed

### API Calls
- Mapbox API has rate limits
- Cache geocoding results when possible
- Use debouncing for search queries

### Memory Management
- Dispose services properly
- Clean up map controller
- Cancel streams on dispose

## Security

### API Key Protection
- `secrets.dart` is in `.gitignore`
- Never commit API keys to version control
- Use environment variables in CI/CD
- Consider using key restriction in production

### Location Privacy
- Request permissions explicitly
- Explain why location is needed
- Provide option to use without location
- Clear location data on logout (future)

## Resources

- [Mapbox GL Flutter Plugin](https://pub.dev/packages/mapbox_maps_flutter)
- [Geolocator Package](https://pub.dev/packages/geolocator)
- [Mapbox API Documentation](https://docs.mapbox.com/)
- [Clean Architecture in Flutter](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

**Last Updated**: December 2024
**Version**: 0.1.0
