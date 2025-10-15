# Route Calculation and Visualization Architecture

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           PRESENTATION LAYER                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌────────────────────┐  ┌────────────────────┐  ┌──────────────────┐ │
│  │  TripRouteScreen   │  │  RouteDemoScreen   │  │  RouteInfoCard   │ │
│  │                    │  │                    │  │                  │ │
│  │  - Map widget      │  │  - Demo waypoints  │  │  - Route info    │ │
│  │  - Route lines     │  │  - Usage guide     │  │  - Share button  │ │
│  │  - Segment list    │  │  - Feature list    │  │  - Tap handler   │ │
│  │  - Alternatives    │  │  - Navigation      │  │                  │ │
│  └────────┬───────────┘  └────────┬───────────┘  └────────┬─────────┘ │
│           │                       │                        │           │
│           └───────────────────────┴────────────────────────┘           │
│                                   │                                    │
└───────────────────────────────────┼────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                             DOMAIN LAYER                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │                        RouteService                               │ │
│  │                                                                   │ │
│  │  + calculateRoute(tripId, from, to, forceRefresh)                │ │
│  │  + calculateRouteWithAlternatives(tripId, from, to)              │ │
│  │  + calculateTripRoute(tripId, waypoints, forceRefresh)           │ │
│  │  + getTripRouteSummary(tripId)                                   │ │
│  │  + getRoute(fromWaypointId, toWaypointId)                        │ │
│  │                                                                   │ │
│  │  Logic:                                                           │ │
│  │  - Check cache first (7-day expiry)                              │ │
│  │  - Calculate if needed                                            │ │
│  │  - Save to repository                                             │ │
│  │  - Return route entity                                            │ │
│  └────────────────────┬────────────────────┬─────────────────────────┘ │
│                       │                    │                           │
│                       │                    │                           │
└───────────────────────┼────────────────────┼───────────────────────────┘
                        │                    │
                        ▼                    ▼
┌────────────────────────────────┐  ┌──────────────────────────────────┐
│   INFRASTRUCTURE LAYER         │  │    INFRASTRUCTURE LAYER          │
│   (External Services)          │  │    (Data Persistence)            │
├────────────────────────────────┤  ├──────────────────────────────────┤
│                                │  │                                  │
│  ┌──────────────────────────┐ │  │  ┌────────────────────────────┐ │
│  │   MapboxService          │ │  │  │   RouteRepository          │ │
│  │                          │ │  │  │                            │ │
│  │  + calculateRoute()      │ │  │  │  + insert(route)           │ │
│  │  + calculateRoute        │ │  │  │  + findById(id)            │ │
│  │    WithAlternatives()    │ │  │  │  + findByWaypoints()       │ │
│  │                          │ │  │  │  + findByTripId()          │ │
│  │  HTTP Client             │ │  │  │  + update(route)           │ │
│  │  ↓                       │ │  │  │  + delete(id)              │ │
│  │  Mapbox Directions API   │ │  │  │                            │ │
│  │  - GET /directions/v5/   │ │  │  │  DatabaseHelper            │ │
│  │  - geometries=geojson    │ │  │  │  ↓                         │ │
│  │  - alternatives=true     │ │  │  │  SQLite Database           │ │
│  │  - overview=full         │ │  │  │  - routes table            │ │
│  └──────────────────────────┘ │  │  │  - indexes                 │ │
│                                │  │  └────────────────────────────┘ │
│  ┌──────────────────────────┐ │  │                                  │
│  │ NavigationShareService   │ │  └──────────────────────────────────┘
│  │                          │ │
│  │  + shareToGoogleMaps()   │ │
│  │  + shareToAppleMaps()    │ │
│  │  + shareToWaze()         │ │
│  │  + shareToHereWeGo()     │ │
│  │                          │ │
│  │  url_launcher            │ │
│  │  ↓                       │ │
│  │  Deep Links / URL        │ │
│  │  Schemes                 │ │
│  └──────────────────────────┘ │
│                                │
│  ┌──────────────────────────┐ │
│  │   MapRouteLayer          │ │
│  │   (Static Utilities)     │ │
│  │                          │ │
│  │  + addRouteToMap()       │ │
│  │  + addMultipleRoutes()   │ │
│  │  + removeRouteFromMap()  │ │
│  │  + fitMapToRoute()       │ │
│  │                          │ │
│  │  Mapbox GL SDK           │ │
│  │  - GeoJSON sources       │ │
│  │  - Line layers           │ │
│  └──────────────────────────┘ │
│                                │
└────────────────────────────────┘
```

## Data Flow

### 1. Calculate Route

```
User Action (Tap segment)
         ↓
TripRouteScreen
         ↓
RouteService.calculateRoute()
         ↓
Check RouteRepository cache
         ├─→ Found & Fresh → Return cached route
         └─→ Not found or expired
                   ↓
         MapboxService.calculateRoute()
                   ↓
         HTTP GET to Mapbox API
                   ↓
         Parse GeoJSON response
                   ↓
         Create Route entity
                   ↓
         RouteRepository.insert()
                   ↓
         Return route to UI
                   ↓
         MapRouteLayer.addRouteToMap()
                   ↓
         Display route line on map
```

### 2. View Alternative Routes

```
User Action (Tap "Show Alternatives")
         ↓
TripRouteScreen._loadAlternativeRoutes()
         ↓
RouteService.calculateRouteWithAlternatives()
         ↓
MapboxService.calculateRouteWithAlternatives()
         ↓
HTTP GET with alternatives=true parameter
         ↓
Parse multiple routes from response
         ↓
Create multiple Route entities
         ↓
Save primary route to repository
         ↓
Return list of routes to UI
         ↓
MapRouteLayer.addMultipleRoutesToMap()
         ↓
Display routes with different colors
```

### 3. Share Route to Navigation App

```
User Action (Tap Share button)
         ↓
RouteInfoCard._showShareDialog()
         ↓
Show modal with app list
         ↓
User selects app (e.g., Google Maps)
         ↓
NavigationShareService.shareRoute()
         ↓
Build deep link URL
  - Google Maps: https://www.google.com/maps/dir/?api=1&origin=...
  - Apple Maps: http://maps.apple.com/?saddr=...&daddr=...
  - Waze: https://waze.com/ul?ll=...&navigate=yes
  - HERE WeGo: https://share.here.com/r/...
         ↓
url_launcher.launchUrl()
         ↓
Open navigation app with pre-loaded route
```

## Component Relationships

```
┌───────────────────────────────────────────────────────────┐
│                        Providers                          │
│  (Riverpod Dependency Injection)                          │
├───────────────────────────────────────────────────────────┤
│                                                           │
│  routeServiceProvider                                     │
│    ├─→ routeRepositoryProvider                           │
│    │     └─→ databaseHelperProvider                      │
│    └─→ mapboxServiceProvider                             │
│                                                           │
│  navigationShareServiceProvider                           │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

## State Management Flow

```
┌─────────────────────────────────────────────────────────────┐
│                   TripRouteScreen State                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  State Variables:                                           │
│  - _routes: List<Route>                                     │
│  - _isLoadingRoutes: bool                                   │
│  - _showingAlternatives: bool                               │
│  - _selectedRouteIndex: int                                 │
│  - _errorMessage: String?                                   │
│  - _mapController: MapboxMap?                               │
│                                                             │
│  Actions:                                                   │
│  - _loadRoutes()                                            │
│  - _loadAlternativeRoutes()                                 │
│  - _visualizeRoutes()                                       │
│  - _refreshRoutes()                                         │
│                                                             │
│  Effects:                                                   │
│  - Routes loaded → Visualize on map                         │
│  - Error → Show error message                               │
│  - Loading → Show progress indicator                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Database Schema

```sql
CREATE TABLE routes (
  id TEXT PRIMARY KEY,
  trip_id TEXT NOT NULL,
  from_waypoint_id TEXT NOT NULL,
  to_waypoint_id TEXT NOT NULL,
  geometry TEXT NOT NULL,           -- GeoJSON LineString
  distance REAL NOT NULL,           -- kilometers
  duration INTEGER NOT NULL,        -- minutes
  calculated_at INTEGER NOT NULL,   -- Unix timestamp (milliseconds)
  route_provider TEXT NOT NULL,     -- "Mapbox"
  
  FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE,
  FOREIGN KEY (from_waypoint_id) REFERENCES waypoints(id) ON DELETE CASCADE,
  FOREIGN KEY (to_waypoint_id) REFERENCES waypoints(id) ON DELETE CASCADE
);

-- Indexes for efficient queries
CREATE INDEX idx_routes_trip_id ON routes(trip_id);
CREATE INDEX idx_routes_waypoints ON routes(from_waypoint_id, to_waypoint_id);
CREATE INDEX idx_routes_calculated_at ON routes(calculated_at);
```

## Caching Strategy

```
┌────────────────────────────────────────────────────────┐
│                    Cache Flow                          │
├────────────────────────────────────────────────────────┤
│                                                        │
│  1. Request route(from, to)                            │
│         ↓                                              │
│  2. Query database by waypoint IDs                     │
│         ↓                                              │
│  3. Check if result exists                             │
│     ├─→ No → Calculate new route                      │
│     │         ↓                                        │
│     │   Save to database                               │
│     │         ↓                                        │
│     │   Return new route                               │
│     │                                                  │
│     └─→ Yes → Check age                                │
│               ├─→ < 7 days → Return cached route      │
│               └─→ >= 7 days → Calculate new route     │
│                                                        │
│  Benefits:                                             │
│  - Reduces API calls by ~90%                           │
│  - Faster response time                                │
│  - Works offline for cached routes                     │
│  - Respects API rate limits                            │
│                                                        │
└────────────────────────────────────────────────────────┘
```

## Alternative Routes Visualization

```
Map Display:

┌───────────────────────────────────────────────┐
│                                               │
│    Route 1 (Primary - Blue)                  │
│    ════════════════════════                  │
│    Distance: 150 km                           │
│    Duration: 2h 15min                         │
│                                               │
│    Route 2 (Alternative - Dark Grey)          │
│    ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─                    │
│    Distance: 165 km                           │
│    Duration: 2h 30min                         │
│                                               │
│    Route 3 (Alternative - Light Grey)         │
│    ········································   │
│    Distance: 158 km                           │
│    Duration: 2h 20min                         │
│                                               │
└───────────────────────────────────────────────┘
```

## Error Handling

```
┌─────────────────────────────────────────────────────┐
│                 Error Flow                          │
├─────────────────────────────────────────────────────┤
│                                                     │
│  API Errors:                                        │
│  - Network timeout → Retry with exponential backoff │
│  - 401 Unauthorized → Check API key                 │
│  - 429 Rate limited → Use cached routes             │
│  - 404 Not found → Show "No route available"        │
│                                                     │
│  Data Errors:                                       │
│  - Invalid coordinates → Show validation message    │
│  - No waypoints → Show "Need 2+ waypoints"          │
│  - Parsing error → Log and show generic error       │
│                                                     │
│  UI Errors:                                         │
│  - Map not loaded → Show loading state              │
│  - Share app not installed → Show friendly message  │
│  - Permission denied → Request permissions          │
│                                                     │
│  All errors:                                        │
│  - Log to console with context                      │
│  - Show user-friendly message                       │
│  - Provide retry option                             │
│  - Don't crash the app                              │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Performance Optimizations

1. **Route Caching**: 7-day cache reduces API calls
2. **Lazy Loading**: Routes loaded only when needed
3. **Efficient Queries**: Database indexes on foreign keys
4. **Geometry Encoding**: GeoJSON stored as compressed JSON string
5. **Map Optimization**: Routes rendered as single line layer
6. **State Management**: Minimal rebuilds with Riverpod

## Security Considerations

1. **API Key**: Stored in `secrets.dart` (gitignored)
2. **Input Validation**: Coordinates validated before API calls
3. **SQL Injection**: Parameterized queries with sqflite
4. **Deep Links**: URL validation before launching
5. **Error Messages**: No sensitive data in error messages

---

**Architecture Version**: 1.0.0
**Last Updated**: October 14, 2025
