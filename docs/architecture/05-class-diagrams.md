# Class Diagrams

This document provides detailed class diagrams for the VanVoyage application architecture, organized by architectural layer.

## Architecture Layers

VanVoyage follows a layered architecture pattern:

```
┌─────────────────────────────────────────┐
│      Presentation Layer (UI)            │
│  (Widgets, Screens, View Models)        │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│    Application Layer (BLoC/Logic)       │
│  (Business Logic, State Management)     │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      Domain Layer (Models)              │
│  (Entities, Value Objects, Enums)       │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│   Infrastructure Layer (Data)           │
│  (Repositories, Data Sources, APIs)     │
└─────────────────────────────────────────┘
```

---

## 1. Domain Layer Classes

### Core Entity Classes

```
┌─────────────────────────────────┐
│          <<Entity>>             │
│            Trip                 │
├─────────────────────────────────┤
│ - id: String                    │
│ - name: String                  │
│ - description: String?          │
│ - startDate: DateTime           │
│ - endDate: DateTime             │
│ - status: TripStatus            │
│ - createdAt: DateTime           │
│ - updatedAt: DateTime           │
├─────────────────────────────────┤
│ + Trip(...)                     │
│ + copyWith(...): Trip           │
│ + toMap(): Map<String, dynamic> │
│ + fromMap(map): Trip            │
│ + toJson(): String              │
│ + fromJson(json): Trip          │
│ + getTotalDistance(): double    │
│ + getTotalDuration(): Duration  │
│ + getWaypointCount(): int       │
└─────────────────────────────────┘
         △
         │ has many
         │
┌────────▼────────────────────────┐
│          <<Entity>>             │
│          TripPhase              │
├─────────────────────────────────┤
│ - id: String                    │
│ - tripId: String                │
│ - name: String                  │
│ - phaseType: PhaseType          │
│ - startDate: DateTime           │
│ - endDate: DateTime             │
│ - sequenceOrder: int            │
├─────────────────────────────────┤
│ + TripPhase(...)                │
│ + copyWith(...): TripPhase      │
│ + toMap(): Map<String, dynamic> │
│ + fromMap(map): TripPhase       │
│ + getDuration(): Duration       │
│ + isActive(): bool              │
└─────────────────────────────────┘


┌─────────────────────────────────┐
│          <<Entity>>             │
│          Waypoint               │
├─────────────────────────────────┤
│ - id: String                    │
│ - tripId: String                │
│ - phaseId: String?              │
│ - name: String                  │
│ - description: String?          │
│ - latitude: double              │
│ - longitude: double             │
│ - address: String?              │
│ - waypointType: WaypointType    │
│ - arrivalDate: DateTime?        │
│ - departureDate: DateTime?      │
│ - stayDuration: int?            │
│ - sequenceOrder: int            │
│ - estimatedDrivingTime: int?    │
│ - estimatedDistance: double?    │
├─────────────────────────────────┤
│ + Waypoint(...)                 │
│ + copyWith(...): Waypoint       │
│ + toMap(): Map<String, dynamic> │
│ + fromMap(map): Waypoint        │
│ + getLocation(): Location       │
│ + getStayDuration(): Duration?  │
│ + isOvernight(): bool           │
│ + isPOI(): bool                 │
└─────────────────────────────────┘
         △
         │ has many
         │
┌────────▼────────────────────────┐
│          <<Entity>>             │
│          Activity               │
├─────────────────────────────────┤
│ - id: String                    │
│ - waypointId: String            │
│ - name: String                  │
│ - description: String?          │
│ - category: ActivityCategory    │
│ - estimatedDuration: int?       │
│ - cost: double?                 │
│ - priority: Priority            │
│ - notes: String?                │
│ - isCompleted: bool             │
├─────────────────────────────────┤
│ + Activity(...)                 │
│ + copyWith(...): Activity       │
│ + toMap(): Map<String, dynamic> │
│ + fromMap(map): Activity        │
│ + toggleCompleted(): Activity   │
│ + getDuration(): Duration?      │
└─────────────────────────────────┘


┌─────────────────────────────────┐
│          <<Entity>>             │
│       TripPreferences           │
├─────────────────────────────────┤
│ - id: String                    │
│ - tripId: String                │
│ - maxDailyDrivingDistance: int  │
│ - maxDailyDrivingTime: int      │
│ - preferredDrivingSpeed: int    │
│ - includeRestStops: bool        │
│ - restStopInterval: int?        │
│ - avoidTolls: bool              │
│ - avoidHighways: bool           │
│ - preferScenicRoutes: bool      │
├─────────────────────────────────┤
│ + TripPreferences(...)          │
│ + copyWith(...): TripPreferences│
│ + toMap(): Map<String, dynamic> │
│ + fromMap(map): TripPreferences │
│ + defaults(tripId): static      │
└─────────────────────────────────┘


┌─────────────────────────────────┐
│          <<Entity>>             │
│            Route                │
├─────────────────────────────────┤
│ - id: String                    │
│ - tripId: String                │
│ - fromWaypointId: String        │
│ - toWaypointId: String          │
│ - geometry: String              │
│ - distance: double              │
│ - duration: int                 │
│ - calculatedAt: DateTime        │
│ - routeProvider: String         │
├─────────────────────────────────┤
│ + Route(...)                    │
│ + copyWith(...): Route          │
│ + toMap(): Map<String, dynamic> │
│ + fromMap(map): Route           │
│ + getGeometry(): LineString     │
│ + isExpired(): bool             │
│ + getDuration(): Duration       │
└─────────────────────────────────┘
```

---

### Value Objects

```
┌─────────────────────────────────┐
│       <<Value Object>>          │
│           Location              │
├─────────────────────────────────┤
│ - latitude: double              │
│ - longitude: double             │
│ - address: String?              │
├─────────────────────────────────┤
│ + Location(lat, lng, [address]) │
│ + distanceTo(other): double     │
│ + bearingTo(other): double      │
│ + toLatLng(): LatLng            │
│ + toJson(): Map<String, dynamic>│
│ + fromJson(map): Location       │
│ + equals(other): bool           │
│ + hashCode: int                 │
└─────────────────────────────────┘


┌─────────────────────────────────┐
│       <<Value Object>>          │
│          DateRange              │
├─────────────────────────────────┤
│ - startDate: DateTime           │
│ - endDate: DateTime             │
├─────────────────────────────────┤
│ + DateRange(start, end)         │
│ + duration(): Duration          │
│ + contains(date): bool          │
│ + overlaps(other): bool         │
│ + isValid(): bool               │
│ + equals(other): bool           │
│ + hashCode: int                 │
└─────────────────────────────────┘


┌─────────────────────────────────┐
│       <<Value Object>>          │
│          Distance               │
├─────────────────────────────────┤
│ - kilometers: double            │
├─────────────────────────────────┤
│ + Distance.fromKm(km)           │
│ + Distance.fromMiles(miles)     │
│ + toKilometers(): double        │
│ + toMiles(): double             │
│ + toMeters(): double            │
│ + add(other): Distance          │
│ + compareTo(other): int         │
│ + toString(): String            │
└─────────────────────────────────┘
```

---

### Enumerations

```
┌─────────────────────────────────┐
│         <<Enumeration>>         │
│          TripStatus             │
├─────────────────────────────────┤
│ + PLANNING                      │
│ + ACTIVE                        │
│ + COMPLETED                     │
│ + ARCHIVED                      │
└─────────────────────────────────┘


┌─────────────────────────────────┐
│         <<Enumeration>>         │
│          PhaseType              │
├─────────────────────────────────┤
│ + OUTBOUND                      │
│ + EXPLORATION                   │
│ + RETURN                        │
└─────────────────────────────────┘


┌─────────────────────────────────┐
│         <<Enumeration>>         │
│        WaypointType             │
├─────────────────────────────────┤
│ + OVERNIGHT_STAY                │
│ + POI                           │
│ + TRANSIT                       │
└─────────────────────────────────┘


┌─────────────────────────────────┐
│         <<Enumeration>>         │
│       ActivityCategory          │
├─────────────────────────────────┤
│ + SIGHTSEEING                   │
│ + HIKING                        │
│ + DINING                        │
│ + SHOPPING                      │
│ + CULTURAL                      │
│ + OUTDOOR                       │
│ + RELAXATION                    │
│ + OTHER                         │
└─────────────────────────────────┘


┌─────────────────────────────────┐
│         <<Enumeration>>         │
│           Priority              │
├─────────────────────────────────┤
│ + HIGH                          │
│ + MEDIUM                        │
│ + LOW                           │
└─────────────────────────────────┘
```

---

## 2. Application Layer Classes (BLoC/State Management)

### BLoC Pattern Classes

```
┌─────────────────────────────────────────┐
│       <<StateNotifier>>                 │
│         TripListBloc                    │
├─────────────────────────────────────────┤
│ - _repository: TripRepository           │
│ - state: TripListState                  │
├─────────────────────────────────────────┤
│ + TripListBloc(repository)              │
│ + loadTrips(): Future<void>             │
│ + createTrip(trip): Future<void>        │
│ + deleteTrip(id): Future<void>          │
│ + filterByStatus(status): Future<void>  │
│ + searchTrips(query): Future<void>      │
└─────────────────────────────────────────┘
         │ manages
         ▼
┌─────────────────────────────────────────┐
│          <<State>>                      │
│        TripListState                    │
├─────────────────────────────────────────┤
│ + when<T>(...)                          │
│ + maybeWhen<T>(...)                     │
│ + map<T>(...)                           │
└─────────────────────────────────────────┘
         △
         │ implements
    ┌────┼────┬────────┬────────┐
    │    │    │        │        │
┌───▼────▼────▼────────▼────────▼───┐
│  TripListInitial                  │
│  TripListLoading                  │
│  TripListLoaded                   │
│  ├─ trips: List<Trip>             │
│  ├─ filter: TripStatus?           │
│  └─ searchQuery: String?          │
│  TripListError                    │
│  └─ message: String               │
└───────────────────────────────────┘


┌─────────────────────────────────────────┐
│       <<StateNotifier>>                 │
│        TripDetailBloc                   │
├─────────────────────────────────────────┤
│ - _repository: TripRepository           │
│ - _waypointRepo: WaypointRepository     │
│ - state: TripDetailState                │
├─────────────────────────────────────────┤
│ + TripDetailBloc(repos)                 │
│ + loadTrip(id): Future<void>            │
│ + updateTrip(trip): Future<void>        │
│ + addWaypoint(waypoint): Future<void>   │
│ + removeWaypoint(id): Future<void>      │
│ + reorderWaypoints(ids): Future<void>   │
│ + calculateRoute(): Future<void>        │
└─────────────────────────────────────────┘
         │ manages
         ▼
┌─────────────────────────────────────────┐
│          <<State>>                      │
│       TripDetailState                   │
└─────────────────────────────────────────┘
         △
         │ implements
    ┌────┼────┬────────┬────────┐
    │    │    │        │        │
┌───▼────▼────▼────────▼────────▼───┐
│  TripDetailInitial                │
│  TripDetailLoading                │
│  TripDetailLoaded                 │
│  ├─ trip: Trip                    │
│  ├─ waypoints: List<Waypoint>    │
│  ├─ preferences: TripPreferences? │
│  └─ routes: List<Route>          │
│  TripDetailError                  │
│  └─ message: String               │
└───────────────────────────────────┘


┌─────────────────────────────────────────┐
│       <<StateNotifier>>                 │
│           MapBloc                       │
├─────────────────────────────────────────┤
│ - state: MapState                       │
├─────────────────────────────────────────┤
│ + MapBloc()                             │
│ + updateCamera(position): void          │
│ + selectWaypoint(id): void              │
│ + showRoute(route): void                │
│ + hideRoute(): void                     │
│ + addMarker(waypoint): void             │
│ + removeMarker(id): void                │
│ + centerOnTrip(trip): void              │
└─────────────────────────────────────────┘
         │ manages
         ▼
┌─────────────────────────────────────────┐
│          <<State>>                      │
│          MapState                       │
├─────────────────────────────────────────┤
│ + cameraPosition: CameraPosition        │
│ + selectedWaypointId: String?           │
│ + visibleRoute: Route?                  │
│ + markers: List<WaypointMarker>        │
│ + showSatellite: bool                   │
└─────────────────────────────────────────┘


┌─────────────────────────────────────────┐
│       <<StateNotifier>>                 │
│     RouteCalculationBloc                │
├─────────────────────────────────────────┤
│ - _routeService: RouteService           │
│ - _repository: RouteRepository          │
│ - state: RouteCalculationState          │
├─────────────────────────────────────────┤
│ + RouteCalculationBloc(service, repo)   │
│ + calculateRoute(from, to): Future<void>│
│ + calculateTripRoute(trip): Future<void>│
│ + optimizeWaypoints(trip): Future<void> │
└─────────────────────────────────────────┘
```

---

## 3. Infrastructure Layer Classes

### Repository Classes

```
┌─────────────────────────────────────────┐
│        <<Interface>>                    │
│        Repository<T>                    │
├─────────────────────────────────────────┤
│ + findById(id): Future<T?>              │
│ + findAll(): Future<List<T>>            │
│ + insert(entity): Future<String>        │
│ + update(entity): Future<int>           │
│ + delete(id): Future<int>               │
└─────────────────────────────────────────┘
         △
         │ implements
    ┌────┼────┬────────────────┬─────────┐
    │    │    │                │         │
┌───▼────▼────▼────────────────▼─────────▼───┐
│  TripRepository                            │
│  WaypointRepository                        │
│  ActivityRepository                        │
│  RouteRepository                           │
│  TripPreferencesRepository                 │
└────────────────────────────────────────────┘


┌─────────────────────────────────────────┐
│        <<Repository>>                   │
│       TripRepository                    │
├─────────────────────────────────────────┤
│ - _db: Database                         │
├─────────────────────────────────────────┤
│ + TripRepository(db)                    │
│ + findById(id): Future<Trip?>           │
│ + findAll(): Future<List<Trip>>         │
│ + findByStatus(status): Future<List>    │
│ + insert(trip): Future<String>          │
│ + update(trip): Future<int>             │
│ + delete(id): Future<int>               │
│ + findTripWithDetails(id): Future<Trip?>│
│ + searchTrips(query): Future<List<Trip>>│
├─────────────────────────────────────────┤
│ - _loadPhases(tripId): Future<List>     │
│ - _loadWaypoints(tripId): Future<List>  │
│ - _loadPreferences(tripId): Future<T>   │
└─────────────────────────────────────────┘


┌─────────────────────────────────────────┐
│        <<Repository>>                   │
│     WaypointRepository                  │
├─────────────────────────────────────────┤
│ - _db: Database                         │
├─────────────────────────────────────────┤
│ + WaypointRepository(db)                │
│ + findById(id): Future<Waypoint?>       │
│ + findAll(): Future<List<Waypoint>>     │
│ + findByTripId(tripId): Future<List>    │
│ + findByPhaseId(phaseId): Future<List>  │
│ + insert(waypoint): Future<String>      │
│ + update(waypoint): Future<int>         │
│ + delete(id): Future<int>               │
│ + reorderWaypoints(tripId, ids): Future │
│ + getNextSequenceOrder(tripId): Future  │
└─────────────────────────────────────────┘
```

---

### Service Classes

```
┌─────────────────────────────────────────┐
│        <<Service>>                      │
│        MapboxService                    │
├─────────────────────────────────────────┤
│ - _apiKey: String                       │
│ - _httpClient: HttpClient               │
├─────────────────────────────────────────┤
│ + MapboxService(apiKey)                 │
│ + geocode(address): Future<Location?>   │
│ + reverseGeocode(location): Future<Addr>│
│ + searchPlaces(query): Future<List>     │
│ + calculateRoute(from, to, options):    │
│   Future<Route>                         │
└─────────────────────────────────────────┘


┌─────────────────────────────────────────┐
│        <<Service>>                      │
│       LocationService                   │
├─────────────────────────────────────────┤
│ - _geolocator: Geolocator               │
│ - _locationStream: Stream<Location>     │
├─────────────────────────────────────────┤
│ + LocationService()                     │
│ + getCurrentLocation(): Future<Location>│
│ + getLocationStream(): Stream<Location> │
│ + hasPermission(): Future<bool>         │
│ + requestPermission(): Future<bool>     │
│ + isLocationServiceEnabled(): Future    │
└─────────────────────────────────────────┘


┌─────────────────────────────────────────┐
│        <<Service>>                      │
│        RouteService                     │
├─────────────────────────────────────────┤
│ - _mapboxService: MapboxService         │
│ - _routeRepository: RouteRepository     │
├─────────────────────────────────────────┤
│ + RouteService(mapbox, repo)            │
│ + calculateRoute(from, to, prefs):      │
│   Future<Route>                         │
│ + calculateTripRoute(trip, prefs):      │
│   Future<List<Route>>                   │
│ + optimizeWaypoints(waypoints, prefs):  │
│   Future<List<Waypoint>>                │
│ + getCachedRoute(from, to): Route?      │
└─────────────────────────────────────────┘


┌─────────────────────────────────────────┐
│        <<Service>>                      │
│      ValidationService                  │
├─────────────────────────────────────────┤
│ + validateTrip(trip): ValidationResult  │
│ + validateWaypoint(waypoint): Result    │
│ + validateDateRange(start, end): Result │
│ + validateSequence(waypoints): Result   │
└─────────────────────────────────────────┘
```

---

### Data Source Classes

```
┌─────────────────────────────────────────┐
│        <<Provider>>                     │
│      DatabaseProvider                   │
├─────────────────────────────────────────┤
│ - _database: Database?                  │
│ + DB_NAME: String = "vanvoyage.db"      │
│ + DB_VERSION: int = 1                   │
├─────────────────────────────────────────┤
│ + database: Future<Database> (getter)   │
│ - _initDatabase(): Future<Database>     │
│ - _onCreate(db, version): Future<void>  │
│ - _onUpgrade(db, old, new): Future<void>│
│ - _onConfigure(db): Future<void>        │
│ - _createTablesV1(db): Future<void>     │
└─────────────────────────────────────────┘


┌─────────────────────────────────────────┐
│        <<Client>>                       │
│        HttpClient                       │
├─────────────────────────────────────────┤
│ - _dio: Dio                             │
│ - _baseUrl: String                      │
│ - _apiKey: String                       │
├─────────────────────────────────────────┤
│ + HttpClient(baseUrl, apiKey)           │
│ + get(path, params): Future<Response>   │
│ + post(path, data): Future<Response>    │
│ + put(path, data): Future<Response>     │
│ + delete(path): Future<Response>        │
└─────────────────────────────────────────┘
```

---

## 4. Presentation Layer Classes

### Screen Widgets

```
┌─────────────────────────────────────────┐
│      <<ConsumerWidget>>                 │
│       TripListScreen                    │
├─────────────────────────────────────────┤
│ + build(context, ref): Widget           │
│ - _buildTripCard(trip): Widget          │
│ - _buildEmptyState(): Widget            │
│ - _buildFilterChips(): Widget           │
│ - _showCreateTripDialog(): Future<void> │
└─────────────────────────────────────────┘


┌─────────────────────────────────────────┐
│      <<ConsumerWidget>>                 │
│      TripDetailScreen                   │
├─────────────────────────────────────────┤
│ + tripId: String                        │
├─────────────────────────────────────────┤
│ + TripDetailScreen(tripId)              │
│ + build(context, ref): Widget           │
│ - _buildHeader(trip): Widget            │
│ - _buildSummaryCard(trip): Widget       │
│ - _buildWaypointsList(waypoints): Widget│
│ - _showEditDialog(trip): Future<void>   │
└─────────────────────────────────────────┘


┌─────────────────────────────────────────┐
│      <<ConsumerStatefulWidget>>         │
│     InteractiveMapScreen                │
├─────────────────────────────────────────┤
│ + createState(): State                  │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│      <<State>>                          │
│  _InteractiveMapScreenState             │
├─────────────────────────────────────────┤
│ - _mapController: MapController         │
│ - _selectedWaypoint: Waypoint?          │
├─────────────────────────────────────────┤
│ + initState(): void                     │
│ + dispose(): void                       │
│ + build(context): Widget                │
│ - _buildMap(): Widget                   │
│ - _buildMarkers(): List<Marker>         │
│ - _buildBottomSheet(): Widget           │
│ - _onMarkerTap(waypoint): void          │
│ - _onMapLongPress(position): void       │
└─────────────────────────────────────────┘
```

---

### Reusable Component Widgets

```
┌─────────────────────────────────────────┐
│        <<StatelessWidget>>              │
│          TripCard                       │
├─────────────────────────────────────────┤
│ + trip: Trip                            │
│ + onTap: VoidCallback?                  │
│ + onLongPress: VoidCallback?            │
├─────────────────────────────────────────┤
│ + TripCard(trip, onTap, onLongPress)    │
│ + build(context): Widget                │
└─────────────────────────────────────────┘


┌─────────────────────────────────────────┐
│        <<StatelessWidget>>              │
│        WaypointListItem                 │
├─────────────────────────────────────────┤
│ + waypoint: Waypoint                    │
│ + onTap: VoidCallback?                  │
│ + onReorder: Function?                  │
├─────────────────────────────────────────┤
│ + WaypointListItem(waypoint, onTap)     │
│ + build(context): Widget                │
│ - _buildTypeIcon(): Widget              │
│ - _buildDetails(): Widget               │
└─────────────────────────────────────────┘


┌─────────────────────────────────────────┐
│        <<StatelessWidget>>              │
│         MapMarker                       │
├─────────────────────────────────────────┤
│ + waypoint: Waypoint                    │
│ + isSelected: bool                      │
│ + onTap: VoidCallback?                  │
├─────────────────────────────────────────┤
│ + MapMarker(waypoint, selected, onTap)  │
│ + build(context): Widget                │
└─────────────────────────────────────────┘
```

---

## Class Relationships Summary

### Key Relationships

1. **Trip → Waypoint**: One-to-Many
2. **Trip → TripPhase**: One-to-Many
3. **Trip → TripPreferences**: One-to-One
4. **TripPhase → Waypoint**: One-to-Many
5. **Waypoint → Activity**: One-to-Many
6. **Trip → Route**: One-to-Many
7. **Waypoint → Route**: Many-to-Many (as from/to)

### Dependency Flow

```
Presentation Layer
    ↓ uses
Application Layer (BLoC)
    ↓ uses
Domain Layer (Entities)
    ↑ implements
Infrastructure Layer (Repos/Services)
```

---

## Design Patterns Used

1. **Repository Pattern**: Data access abstraction
2. **BLoC Pattern**: State management and business logic
3. **Provider Pattern**: Dependency injection (Riverpod)
4. **Factory Pattern**: Entity creation from JSON/Map
5. **Strategy Pattern**: Route calculation strategies
6. **Observer Pattern**: State change notifications
7. **Value Object Pattern**: Immutable domain primitives

---

## Testing Class Structure

```
┌─────────────────────────────────────────┐
│      <<Test Helper>>                    │
│       MockTripRepository                │
├─────────────────────────────────────────┤
│ extends Mock implements TripRepository  │
└─────────────────────────────────────────┘


┌─────────────────────────────────────────┐
│      <<Test Helper>>                    │
│        TestDataFactory                  │
├─────────────────────────────────────────┤
│ + createTrip(overrides): Trip           │
│ + createWaypoint(overrides): Waypoint   │
│ + createActivity(overrides): Activity   │
│ + createRoute(overrides): Route         │
└─────────────────────────────────────────┘
```

---

## Future Class Additions

### Planned for Phase 2
- `User` entity for authentication
- `SharedTrip` for collaboration
- `Weather` value object
- `Expense` entity for budget tracking
- `Photo` entity for trip memories

### Planned for Phase 3
- `SyncService` for cloud synchronization
- `NotificationService` for reminders
- `ExportService` for data export
- `AnalyticsService` for usage tracking
