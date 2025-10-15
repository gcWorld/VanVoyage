# Route Calculation and Visualization Implementation

## Overview

This document describes the implementation of route calculation, visualization, and sharing features for VanVoyage.

## Issue Addressed

**Issue**: Route Calculation and Visualization

**Tasks Completed**:
- ✅ Integrate routing API (Mapbox Directions)
- ✅ Visualize routes on map
- ✅ Calculate and display driving times and distances
- ✅ Handle alternative routes
- ✅ Share individual trip legs to navigation apps
- ✅ Support different routing profiles (fastest, traffic-aware, walking, cycling)

## Files Added/Modified

### New Files Added

**Services** (3 files):
- `lib/domain/services/route_service.dart` - Route calculation business logic
- `lib/infrastructure/services/navigation_share_service.dart` - Share routes to navigation apps
- `lib/infrastructure/database/database_helper.dart` - Database helper singleton

**Repositories** (1 file):
- `lib/infrastructure/repositories/route_repository.dart` - Route data persistence

**Screens** (1 file):
- `lib/presentation/screens/trip_route_screen.dart` - Full route visualization screen

**Widgets** (2 files):
- `lib/presentation/widgets/map_route_layer.dart` - Map route visualization utilities
- `lib/presentation/widgets/route_info_card.dart` - Route information display widget

**Tests** (1 file):
- `test/unit/domain/services/route_service_test.dart` - Route service tests

**Documentation** (1 file):
- `ROUTE_IMPLEMENTATION.md` - This file

### Files Modified

- `lib/infrastructure/services/mapbox_service.dart` - Added alternative routes support
- `lib/providers.dart` - Added route service providers
- `pubspec.yaml` - Added url_launcher dependency
- `test/unit/infrastructure/services/mapbox_service_test.dart` - Added alternative route tests

## Implementation Details

### 1. RouteService

**Purpose**: Business logic for route calculation and management

**Features**:
- Calculate routes between waypoints with caching
- Calculate routes for entire trips
- Support for alternative route calculation
- Route caching with 7-day expiry
- Trip route summary with totals

**Key Methods**:
```dart
Future<Route?> calculateRoute(tripId, fromWaypoint, toWaypoint, {forceRefresh})
Future<List<Route>> calculateRouteWithAlternatives(tripId, fromWaypoint, toWaypoint)
Future<List<Route>> calculateTripRoute(tripId, waypoints, {forceRefresh})
Future<Route?> getRoute(fromWaypointId, toWaypointId)
Future<TripRouteSummary?> getTripRouteSummary(tripId)
```

**Classes**:
- `RouteService` - Main service class
- `TripRouteSummary` - Aggregated route statistics

### 2. MapboxService (Enhanced)

**Purpose**: Interface with Mapbox Directions API

**New Features**:
- Alternative routes support
- Step-by-step navigation data
- Multiple routing profiles (driving, traffic, walking, cycling)

**Routing Profiles**:
- `RoutingProfile.driving` - Fastest route by car (default)
- `RoutingProfile.drivingTraffic` - Route considering current traffic conditions
- `RoutingProfile.walking` - Walking route
- `RoutingProfile.cycling` - Cycling route

**Key Methods**:
```dart
Future<MapboxRoute?> calculateRoute(
  startLat, startLng, endLat, endLng, 
  {alternatives, profile}
)
Future<List<MapboxRoute>> calculateRouteWithAlternatives(
  startLat, startLng, endLat, endLng,
  {profile}
)
```

**Enhancement**: The route calculation methods now accept a `profile` parameter to specify the type of route desired. This allows users to choose between fastest driving routes, traffic-aware routes, walking paths, or cycling routes.

### 3. NavigationShareService

**Purpose**: Share routes to external navigation apps

**Features**:
- Share to Google Maps
- Share to Apple Maps
- Share to Waze
- Share to HERE WeGo
- Universal sharing interface

**Supported Apps**:
- **Google Maps**: Full route with origin and destination
- **Apple Maps**: Native iOS integration
- **Waze**: Direct navigation to destination
- **HERE WeGo**: Multi-platform support

**Key Methods**:
```dart
Future<bool> shareToGoogleMaps(from, to)
Future<bool> shareToAppleMaps(from, to)
Future<bool> shareToWaze(to)
Future<bool> shareToHereWeGo(from, to)
Future<bool> shareRoute(appId, from, to)
List<NavigationApp> getAvailableApps()
```

### 4. MapRouteLayer

**Purpose**: Utilities for visualizing routes on Mapbox

**Features**:
- Add single route to map
- Add multiple routes with different colors
- Remove routes from map
- Fit map to route bounds

**Key Methods**:
```dart
static Future<void> addRouteToMap(mapController, route, {color, width})
static Future<void> addMultipleRoutesToMap(mapController, routes, {colors})
static Future<void> removeRouteFromMap(mapController)
static Future<void> fitMapToRoute(mapController, route, {padding})
```

### 5. RouteInfoCard Widget

**Purpose**: Display route information with sharing options

**Features**:
- Shows waypoint names
- Displays distance and duration
- Share button with app selector
- Tap to view alternatives

**Usage**:
```dart
RouteInfoCard(
  route: route,
  fromWaypoint: fromWaypoint,
  toWaypoint: toWaypoint,
  onTap: () => showAlternatives(),
)
```

### 6. TripRouteScreen

**Purpose**: Full-screen route visualization and management

**Features**:
- Map with route visualization
- Route summary card
- Route segments list
- Alternative routes display
- Share individual segments
- Refresh routes
- Route type selector (fastest, traffic, walking, cycling)

**Navigation**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TripRouteScreen(
      tripId: trip.id,
      waypoints: waypoints,
    ),
  ),
);
```

## Usage Examples

### Calculate Route

```dart
final routeService = ref.read(routeServiceProvider);

// Calculate single route with default (fastest driving) profile
final route = await routeService.calculateRoute(
  tripId,
  fromWaypoint,
  toWaypoint,
);

// Calculate route with traffic-aware profile
final trafficRoute = await routeService.calculateRoute(
  tripId,
  fromWaypoint,
  toWaypoint,
  profile: RoutingProfile.drivingTraffic,
);

// Get alternatives for a specific profile
final alternatives = await routeService.calculateRouteWithAlternatives(
  tripId,
  fromWaypoint,
  toWaypoint,
  profile: RoutingProfile.driving,
);

// Calculate entire trip route with cycling profile
final routes = await routeService.calculateTripRoute(
  tripId,
  waypoints,
  forceRefresh: false,
  profile: RoutingProfile.cycling,
);
```

### Visualize Route on Map

```dart
// Add single route
await MapRouteLayer.addRouteToMap(
  mapController,
  route,
  color: Colors.blue,
  width: 5.0,
);

// Add multiple alternative routes
await MapRouteLayer.addMultipleRoutesToMap(
  mapController,
  routes,
  colors: [Colors.blue, Colors.grey, Colors.grey],
);

// Remove routes
await MapRouteLayer.removeRouteFromMap(mapController);
```

### Share Route to Navigation App

```dart
final navigationService = NavigationShareService();

// Share to Google Maps
final success = await navigationService.shareToGoogleMaps(
  fromWaypoint,
  toWaypoint,
);

// Universal share with app selection
final apps = navigationService.getAvailableApps();
// Show selection dialog
final success = await navigationService.shareRoute(
  selectedApp.id,
  fromWaypoint,
  toWaypoint,
);
```

### Display Route Information

```dart
RouteInfoCard(
  route: route,
  fromWaypoint: fromWaypoint,
  toWaypoint: toWaypoint,
  onTap: () {
    // Handle tap - e.g., show alternatives
  },
)
```

## Database Schema

Routes are stored in the `routes` table:

```sql
CREATE TABLE routes (
  id TEXT PRIMARY KEY,
  trip_id TEXT NOT NULL,
  from_waypoint_id TEXT NOT NULL,
  to_waypoint_id TEXT NOT NULL,
  geometry TEXT NOT NULL,
  distance REAL NOT NULL,
  duration INTEGER NOT NULL,
  calculated_at INTEGER NOT NULL,
  route_provider TEXT NOT NULL,
  FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE,
  FOREIGN KEY (from_waypoint_id) REFERENCES waypoints(id) ON DELETE CASCADE,
  FOREIGN KEY (to_waypoint_id) REFERENCES waypoints(id) ON DELETE CASCADE
)
```

**Fields**:
- `geometry`: GeoJSON LineString encoded as JSON string
- `distance`: Distance in kilometers
- `duration`: Duration in minutes
- `calculated_at`: Timestamp for cache expiry
- `route_provider`: Service used (e.g., "Mapbox")

## Route Caching Strategy

Routes are cached in the database to reduce API calls and improve performance:

1. **Cache Duration**: Routes are considered fresh for 7 days
2. **Cache Key**: Routes are indexed by `from_waypoint_id` and `to_waypoint_id`
3. **Force Refresh**: Users can force route recalculation
4. **Automatic Expiry**: Old routes are ignored based on `calculated_at` timestamp

## Routing Profiles

Different routing profiles optimize routes for different travel modes:

### Profile Types

1. **Fastest (Driving)** - `RoutingProfile.driving`
   - Default profile for car travel
   - Optimizes for fastest time
   - Uses highways and main roads
   - Best for: Road trips, general travel

2. **Traffic-Aware (Driving)** - `RoutingProfile.drivingTraffic`
   - Considers real-time traffic conditions
   - Avoids congested areas
   - Updates based on current traffic data
   - Best for: Urban travel, time-sensitive trips

3. **Walking** - `RoutingProfile.walking`
   - Pedestrian-friendly routes
   - Uses sidewalks and walking paths
   - Shorter distances preferred
   - Best for: City exploration, hiking trails

4. **Cycling** - `RoutingProfile.cycling`
   - Bike-friendly routes
   - Uses bike lanes and paths
   - Considers elevation and road types
   - Best for: Bike tours, cycling adventures

### Selecting Profiles

Users can select routing profiles in the TripRouteScreen:
1. Tap the route type icon in the app bar
2. Choose from Fastest, Traffic, Walking, or Cycling
3. Routes automatically recalculate with the new profile

**Note**: For scenic routes, use the `driving` profile as it tends to favor well-maintained roads. Mapbox does not have a dedicated "scenic" profile, but you can combine route alternatives with manual selection to find more scenic options.

## Alternative Routes

Alternative routes provide users with options:

1. **API Request**: Mapbox returns up to 3 alternative routes for the selected profile
2. **Visualization**: Routes are displayed with different colors:
   - Primary (fastest): Blue
   - Alternative 1: Dark grey
   - Alternative 2: Light grey
3. **Selection**: Users can tap to select preferred route
4. **Metadata**: Each route shows distance and duration
5. **Profile-Specific**: Alternatives are calculated based on the selected routing profile

## Testing

### Unit Tests

**RouteService Tests**:
- Route calculation and caching
- Alternative routes
- Trip route calculation
- Route summary aggregation

**MapboxService Tests**:
- Single route calculation
- Alternative routes API
- Error handling

### Integration Testing

To test the complete flow:

1. Create a trip with multiple waypoints
2. Navigate to TripRouteScreen
3. Routes should be calculated and displayed
4. Tap a route segment to see alternatives
5. Use share button to test navigation app integration

## Dependencies

### Added
- `url_launcher: ^6.3.1` - For opening navigation apps

### Used
- `mapbox_maps_flutter: ^2.3.0` - Map widget and route visualization
- `http: ^1.2.2` - Mapbox API calls
- `sqflite: ^2.4.1` - Route caching
- `flutter_riverpod: ^2.6.1` - State management

## Future Enhancements

### Phase 1: Advanced Route Options
- Route optimization (reorder waypoints)
- Avoid highways/tolls options
- Scenic route preference
- Fuel cost estimation

### Phase 2: Offline Support
- Cache route geometry for offline access
- Offline route calculation fallback
- Pre-download routes for trip

### Phase 3: Real-time Navigation
- Turn-by-turn directions
- Traffic-aware rerouting
- Voice guidance integration
- ETA updates

### Phase 4: Route Export
- Export routes as GPX files
- Share routes with other users
- Print route directions
- Integration with RV-specific route planners

## Troubleshooting

### Routes Not Displaying

1. Check Mapbox API key is valid
2. Verify waypoints have valid coordinates
3. Check network connectivity
4. Review console for error messages

### Sharing Not Working

1. Verify url_launcher permissions in AndroidManifest.xml and Info.plist
2. Check if target navigation app is installed
3. Test with alternative apps

### Performance Issues

1. Use cached routes when possible
2. Limit alternative route requests
3. Consider route simplification for very long trips
4. Implement pagination for route segments list

## API Rate Limits

Mapbox Directions API has rate limits:
- Free tier: 60,000 requests/month
- Route caching reduces API calls
- Consider implementing request throttling for production

## Security Considerations

1. **API Keys**: Store Mapbox API key securely (not in version control)
2. **Input Validation**: Validate coordinates before API calls
3. **Error Handling**: Handle API errors gracefully
4. **Cache Management**: Implement cache cleanup for old data

---

**Last Updated**: 2025-10-14
**Version**: 1.0.0
