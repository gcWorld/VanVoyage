# Data Flow Architecture

This document describes how data flows through the VanVoyage application, including user interactions, state changes, and data persistence.

## Overview

VanVoyage follows a unidirectional data flow pattern where:
1. User interactions trigger events
2. Events are handled by BLoCs
3. BLoCs update application state
4. UI reacts to state changes
5. Data is persisted to local database

```
┌─────────────┐
│    User     │
│ Interaction │
└──────┬──────┘
       │ 1. Event/Action
       ▼
┌─────────────┐
│     UI      │
│   Widget    │
└──────┬──────┘
       │ 2. Dispatch Action
       ▼
┌─────────────┐
│    BLoC     │
│   (Logic)   │
└──────┬──────┘
       │ 3. Call Repository
       ▼
┌─────────────┐
│ Repository  │
│   (Data)    │
└──────┬──────┘
       │ 4. Database Query
       ▼
┌─────────────┐
│   SQLite    │
│  Database   │
└──────┬──────┘
       │ 5. Return Data
       ▼
┌─────────────┐
│ Repository  │
│   (Data)    │
└──────┬──────┘
       │ 6. Transform to Entity
       ▼
┌─────────────┐
│    BLoC     │
│   (Logic)   │
└──────┬──────┘
       │ 7. Update State
       ▼
┌─────────────┐
│     UI      │
│   Widget    │ ← 8. Rebuild with new state
└─────────────┘
```

---

## 1. Create Trip Flow

### User Action → Database Persistence

```
User fills form → Tap "Create" button
                       │
                       ▼
              TripListScreen
              ┌──────────────────┐
              │ onCreateTrip()   │
              └────────┬─────────┘
                       │
                       ▼
              TripListBloc
              ┌──────────────────┐
              │ createTrip(trip) │
              │ - Validate trip  │
              │ - Generate UUID  │
              └────────┬─────────┘
                       │
                       ▼
              TripRepository
              ┌──────────────────┐
              │ insert(trip)     │
              │ - toMap()        │
              │ - db.insert()    │
              └────────┬─────────┘
                       │
                       ▼
              SQLite Database
              ┌──────────────────┐
              │ INSERT INTO trips│
              │ RETURNING id     │
              └────────┬─────────┘
                       │
                       ▼
              TripRepository
              ┌──────────────────┐
              │ Return Trip ID   │
              └────────┬─────────┘
                       │
                       ▼
              TripListBloc
              ┌──────────────────┐
              │ Update State:    │
              │ TripListLoaded   │
              │ + new trip       │
              └────────┬─────────┘
                       │
                       ▼
              TripListScreen
              ┌──────────────────┐
              │ Rebuild UI       │
              │ Show new trip    │
              │ Navigate to      │
              │ TripDetailScreen │
              └──────────────────┘
```

---

## 2. Load Trip Details Flow

### Screen Navigation → Data Loading

```
User taps trip card
       │
       ▼
TripListScreen
┌─────────────────────┐
│ onTripTap(tripId)   │
│ Navigator.push()    │
└──────────┬──────────┘
           │
           ▼
TripDetailScreen
┌─────────────────────┐
│ initState()         │
│ Watch provider      │
└──────────┬──────────┘
           │
           ▼
TripDetailBloc
┌─────────────────────┐
│ loadTrip(tripId)    │
│ Set Loading state   │
└──────────┬──────────┘
           │
           ├─────────────────┬─────────────────┬──────────────────┐
           │                 │                 │                  │
           ▼                 ▼                 ▼                  ▼
TripRepository      WaypointRepository   RouteRepository   PreferencesRepo
┌───────────────┐   ┌──────────────────┐ ┌──────────────┐ ┌──────────────┐
│ findById()    │   │ findByTripId()   │ │ findByTrip() │ │ findByTrip() │
└───────┬───────┘   └────────┬─────────┘ └──────┬───────┘ └──────┬───────┘
        │                    │                  │                 │
        ▼                    ▼                  ▼                 ▼
    SQLite DB           SQLite DB          SQLite DB         SQLite DB
┌───────────────┐   ┌──────────────────┐ ┌──────────────┐ ┌──────────────┐
│ SELECT * FROM │   │ SELECT * FROM    │ │ SELECT * FROM│ │ SELECT * FROM│
│ trips         │   │ waypoints        │ │ routes       │ │ trip_prefs   │
│ WHERE id=?    │   │ WHERE trip_id=?  │ │ WHERE...     │ │ WHERE...     │
└───────┬───────┘   └────────┬─────────┘ └──────┬───────┘ └──────┬───────┘
        │                    │                  │                 │
        ▼                    ▼                  ▼                 ▼
Trip.fromMap()      List<Waypoint>     List<Route>      TripPreferences
        │                    │                  │                 │
        └────────────────────┴──────────────────┴─────────────────┘
                             │
                             ▼
                    TripDetailBloc
                    ┌──────────────────────┐
                    │ Combine all data     │
                    │ Update State:        │
                    │ TripDetailLoaded     │
                    │ - trip               │
                    │ - waypoints (sorted) │
                    │ - routes             │
                    │ - preferences        │
                    └──────────┬───────────┘
                               │
                               ▼
                    TripDetailScreen
                    ┌──────────────────────┐
                    │ Rebuild with data    │
                    │ - Show trip info     │
                    │ - Render waypoints   │
                    │ - Display map        │
                    └──────────────────────┘
```

---

## 3. Add Waypoint Flow

### User Input → Multi-Step Process

```
User taps "Add Waypoint" button
           │
           ▼
TripDetailScreen
┌─────────────────────────┐
│ showModalBottomSheet()  │
│ AddWaypointScreen       │
└──────────┬──────────────┘
           │
           ▼
AddWaypointScreen
┌─────────────────────────┐
│ User searches location  │
└──────────┬──────────────┘
           │
           ▼
MapboxService
┌─────────────────────────┐
│ searchPlaces(query)     │
│ HTTP GET to Mapbox API  │
└──────────┬──────────────┘
           │
           ▼
Mapbox API Response
┌─────────────────────────┐
│ JSON: List of places    │
│ - name, coordinates     │
│ - address, etc.         │
└──────────┬──────────────┘
           │
           ▼
AddWaypointScreen
┌─────────────────────────┐
│ Display search results  │
│ User selects location   │
│ User fills form fields  │
│ - Name                  │
│ - Type                  │
│ - Dates                 │
└──────────┬──────────────┘
           │ User taps "Save"
           ▼
AddWaypointScreen
┌─────────────────────────┐
│ Validate input          │
│ Create Waypoint entity  │
└──────────┬──────────────┘
           │
           ▼
TripDetailBloc
┌─────────────────────────┐
│ addWaypoint(waypoint)   │
│ - Calculate sequence    │
│ - Invalidate routes     │
└──────────┬──────────────┘
           │
           ▼
WaypointRepository
┌─────────────────────────┐
│ getNextSequence()       │
└──────────┬──────────────┘
           │
           ▼
SQLite Database
┌─────────────────────────┐
│ SELECT MAX(sequence)    │
│ FROM waypoints          │
└──────────┬──────────────┘
           │ Returns: n
           ▼
WaypointRepository
┌─────────────────────────┐
│ insert(waypoint)        │
│ with sequence = n+1     │
└──────────┬──────────────┘
           │
           ▼
SQLite Database (Transaction)
┌─────────────────────────┐
│ BEGIN TRANSACTION       │
│ INSERT INTO waypoints   │
│ DELETE FROM routes      │
│   WHERE trip_id = ?     │
│ COMMIT                  │
└──────────┬──────────────┘
           │ Success
           ▼
TripDetailBloc
┌─────────────────────────┐
│ Reload trip data        │
│ Update State            │
└──────────┬──────────────┘
           │
           ▼
TripDetailScreen
┌─────────────────────────┐
│ Rebuild UI              │
│ Show new waypoint       │
│ Dismiss modal           │
│ Show success snackbar   │
└─────────────────────────┘
```

---

## 4. Calculate Route Flow

### User Request → External API → Cache

```
User taps "Calculate Route" button
              │
              ▼
TripDetailScreen
┌─────────────────────────────┐
│ Dispatch action             │
└──────────┬──────────────────┘
           │
           ▼
RouteCalculationBloc
┌─────────────────────────────┐
│ calculateTripRoute(trip)    │
│ Set State: Calculating      │
└──────────┬──────────────────┘
           │
           ▼
RouteService
┌─────────────────────────────┐
│ calculateTripRoute(trip)    │
│ - Get waypoints in order    │
│ - For each pair:            │
│   - Check cache             │
│   - Or call Mapbox API      │
└──────────┬──────────────────┘
           │
           ├─► For each waypoint pair:
           │
           ▼
RouteRepository
┌─────────────────────────────┐
│ getCachedRoute(from, to)    │
└──────────┬──────────────────┘
           │
           ▼
SQLite Database
┌─────────────────────────────┐
│ SELECT * FROM routes        │
│ WHERE from_waypoint_id = ?  │
│   AND to_waypoint_id = ?    │
│   AND calculated_at >       │
│       NOW() - 7 days        │
└──────────┬──────────────────┘
           │
     ┌─────┴─────┐
     │           │
     ▼           ▼
   Found      Not Found
     │           │
     │           ▼
     │    MapboxService
     │    ┌─────────────────────────────┐
     │    │ calculateRoute(from, to)    │
     │    │ HTTP POST to Mapbox         │
     │    │ Directions API              │
     │    └──────────┬──────────────────┘
     │               │
     │               ▼
     │    Mapbox API Response
     │    ┌─────────────────────────────┐
     │    │ JSON: Route geometry        │
     │    │ - Polyline (encoded)        │
     │    │ - Distance (meters)         │
     │    │ - Duration (seconds)        │
     │    └──────────┬──────────────────┘
     │               │
     │               ▼
     │    RouteService
     │    ┌─────────────────────────────┐
     │    │ Parse response              │
     │    │ Create Route entity         │
     │    └──────────┬──────────────────┘
     │               │
     │               ▼
     │    RouteRepository
     │    ┌─────────────────────────────┐
     │    │ insert(route)               │
     │    └──────────┬──────────────────┘
     │               │
     │               ▼
     │    SQLite Database
     │    ┌─────────────────────────────┐
     │    │ INSERT INTO routes          │
     │    └──────────┬──────────────────┘
     │               │
     └───────────────┴───────────────────┐
                                         │
                                         ▼
                              RouteService
                              ┌─────────────────────────────┐
                              │ Collect all route segments  │
                              │ Calculate totals:           │
                              │ - Total distance            │
                              │ - Total duration            │
                              │ - Apply preferences         │
                              │   (rest stops, etc.)        │
                              └──────────┬──────────────────┘
                                         │
                                         ▼
                              RouteCalculationBloc
                              ┌─────────────────────────────┐
                              │ Update State:               │
                              │ RouteCalculated             │
                              │ - routes: List<Route>       │
                              │ - totalDistance             │
                              │ - totalDuration             │
                              └──────────┬──────────────────┘
                                         │
                                         ▼
                              TripDetailScreen
                              ┌─────────────────────────────┐
                              │ Rebuild UI                  │
                              │ - Show route on map         │
                              │ - Display metrics           │
                              │ - Enable navigation         │
                              └─────────────────────────────┘
```

---

## 5. Map Interaction Flow

### User Interaction → State Update → UI Refresh

```
User taps waypoint marker on map
              │
              ▼
InteractiveMapScreen
┌─────────────────────────────┐
│ _onMarkerTap(waypoint)      │
└──────────┬──────────────────┘
           │
           ▼
MapBloc
┌─────────────────────────────┐
│ selectWaypoint(waypointId)  │
│ Update State:               │
│ - selectedWaypointId = id   │
│ - Keep other state same     │
└──────────┬──────────────────┘
           │
           ▼
InteractiveMapScreen (rebuild)
┌─────────────────────────────┐
│ Listen to state change      │
│ ref.watch(mapProvider)      │
└──────────┬──────────────────┘
           │
           ▼
InteractiveMapScreen
┌─────────────────────────────┐
│ _buildBottomSheet()         │
│ if (selectedWaypoint != null)│
│   Show waypoint details     │
│   - Name, type, address     │
│   - Quick actions           │
└──────────┬──────────────────┘
           │
           ▼
WaypointInfoPanel (Widget)
┌─────────────────────────────┐
│ Display waypoint info       │
│ - Collapsible bottom sheet  │
│ - Tap to expand/collapse    │
│ - "View Details" button     │
│ - "Navigate" button         │
└─────────────────────────────┘


User long-presses on map
              │
              ▼
InteractiveMapScreen
┌─────────────────────────────┐
│ _onMapLongPress(latLng)     │
└──────────┬──────────────────┘
           │
           ▼
Show Context Menu
┌─────────────────────────────┐
│ Options:                    │
│ - Add Waypoint Here         │
│ - Get Directions To Here    │
│ - Share Location            │
│ - Cancel                    │
└──────────┬──────────────────┘
           │ User selects "Add Waypoint"
           ▼
AddWaypointScreen (Modal)
┌─────────────────────────────┐
│ Pre-filled with:            │
│ - latitude, longitude       │
│ - Reverse geocoded address  │
└──────────┬──────────────────┘
           │
           ▼
MapboxService
┌─────────────────────────────┐
│ reverseGeocode(latLng)      │
│ HTTP GET to Mapbox API      │
└──────────┬──────────────────┘
           │
           ▼
Mapbox API Response
┌─────────────────────────────┐
│ JSON: Address information   │
│ - Street, city, country     │
│ - Place name                │
└──────────┬──────────────────┘
           │
           ▼
AddWaypointScreen
┌─────────────────────────────┐
│ Update form with address    │
│ User completes form         │
│ Save waypoint (see Flow 3)  │
└─────────────────────────────┘
```

---

## 6. Offline Mode Data Flow

### Data Synchronization Strategy

```
App Launches
     │
     ▼
Check Network Connectivity
┌─────────────────────────────┐
│ ConnectivityBloc            │
│ Listen to connectivity      │
└──────────┬──────────────────┘
           │
     ┌─────┴─────┐
     │           │
     ▼           ▼
  Online      Offline
     │           │
     │           ▼
     │    ┌─────────────────────────────┐
     │    │ Set offline mode flag       │
     │    │ Use cached data only        │
     │    │ Queue write operations      │
     │    └─────────┬───────────────────┘
     │              │
     │              ▼
     │    User makes changes (e.g., adds waypoint)
     │              │
     │              ▼
     │    ┌─────────────────────────────┐
     │    │ Save to local database      │
     │    │ Mark as "pending sync"      │
     │    └─────────┬───────────────────┘
     │              │
     │              ▼
     │    ┌─────────────────────────────┐
     │    │ Show offline indicator      │
     │    │ "Changes saved locally"     │
     │    └─────────────────────────────┘
     │              │
     └──────────────┘
           │
     Connectivity restored
           │
           ▼
┌─────────────────────────────┐
│ ConnectivityBloc            │
│ Emit online state           │
└──────────┬──────────────────┘
           │
           ▼
┌─────────────────────────────┐
│ Future: SyncService         │
│ Process queued operations   │
│ - Upload pending changes    │
│ - Resolve conflicts         │
│ - Update sync timestamps    │
└──────────┬──────────────────┘
           │
           ▼
┌─────────────────────────────┐
│ Show sync complete message  │
│ Update UI with latest data  │
└─────────────────────────────┘
```

**Note**: For MVP, offline mode is fully functional without cloud sync. Future versions will add cloud synchronization.

---

## 7. State Management Data Flow

### Riverpod Provider Chain

```
                    Root ProviderScope
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
DatabaseProvider    MapboxService      LocationService
        │              Provider            Provider
        │                   │                   │
        └───────┬───────────┴───────────────────┘
                │
    ┌───────────┼───────────┬───────────┐
    │           │           │           │
    ▼           ▼           ▼           ▼
TripRepo   WaypointRepo  RouteRepo  ActivityRepo
Provider    Provider     Provider    Provider
    │           │           │           │
    └───────────┼───────────┴───────────┘
                │
    ┌───────────┼───────────┬───────────┐
    │           │           │           │
    ▼           ▼           ▼           ▼
TripListBloc TripDetail  MapBloc   RouteCalc
  Provider    Provider   Provider   Provider
    │           │           │           │
    │           │           │           │
    ▼           ▼           ▼           ▼
TripListScreen TripDetail MapScreen Planning
               Screen               Screen
```

### State Update Propagation

```
User Action
    │
    ▼
Widget calls BLoC method
    │
    ▼
BLoC calls Repository
    │
    ▼
Repository updates Database
    │
    ▼
Repository returns result
    │
    ▼
BLoC updates State
    │
    ▼
StateNotifier emits new state
    │
    ▼
Riverpod notifies listeners
    │
    ▼
Widget ref.watch() detects change
    │
    ▼
Widget.build() is called
    │
    ▼
UI updates with new data
```

---

## 8. Error Handling Data Flow

### Error Propagation

```
Database Error / Network Error / Validation Error
                │
                ▼
        Repository catches exception
                │
                ▼
        Transform to domain error
        - DatabaseException → DataError
        - NetworkException → NetworkError
        - ValidationException → ValidationError
                │
                ▼
        Return Result<T, Error>
        or throw specific exception
                │
                ▼
        BLoC catches error
                │
                ▼
        Update state to error state
        - Include error message
        - Preserve previous data if available
                │
                ▼
        Widget detects error state
                │
                ▼
        Display error UI
        - Error message
        - Retry button
        - Fallback content
                │
                ▼
        Log error for debugging
        - Error type
        - Stack trace
        - Context information
```

---

## 9. Performance Optimization Patterns

### Lazy Loading

```
TripListScreen loads
        │
        ▼
Load trip summaries only (without relations)
┌─────────────────────────────┐
│ SELECT id, name, dates      │
│ FROM trips                  │
│ ORDER BY updated_at DESC    │
│ LIMIT 20 OFFSET 0           │
└──────────┬──────────────────┘
           │
           ▼
Display trip cards
        │
        │ User taps trip
        ▼
TripDetailScreen loads
        │
        ▼
Load full trip with relations
┌─────────────────────────────┐
│ Load Trip                   │
│ Load Waypoints (by trip)    │
│ Load Routes (by trip)       │
│ Load Preferences (by trip)  │
└─────────────────────────────┘
```

### Caching Strategy

```
Request Data
     │
     ▼
Check Memory Cache
     │
 ┌───┴───┐
 │       │
Hit    Miss
 │       │
 │       ▼
 │   Check Database Cache
 │       │
 │   ┌───┴───┐
 │   │       │
 │  Hit    Miss
 │   │       │
 │   │       ▼
 │   │   Fetch from API/Service
 │   │       │
 │   │       ▼
 │   │   Store in Database
 │   │       │
 │   └───────┤
 │           ▼
 │       Store in Memory
 │           │
 └───────────┤
             ▼
       Return Data
```

---

## 10. Data Validation Flow

### Multi-Layer Validation

```
User Input
    │
    ▼
UI Layer Validation
┌─────────────────────────────┐
│ Form validators             │
│ - Required fields           │
│ - Format checks             │
│ - Length constraints        │
└──────────┬──────────────────┘
           │ Valid
           ▼
BLoC Layer Validation
┌─────────────────────────────┐
│ Business rule validation    │
│ - Date logic                │
│ - Sequence constraints      │
│ - Related entity checks     │
└──────────┬──────────────────┘
           │ Valid
           ▼
Repository Layer Validation
┌─────────────────────────────┐
│ Data integrity validation   │
│ - Foreign key existence     │
│ - Unique constraints        │
│ - Type conversions          │
└──────────┬──────────────────┘
           │ Valid
           ▼
Database Layer Validation
┌─────────────────────────────┐
│ Database constraints        │
│ - NOT NULL checks           │
│ - CHECK constraints         │
│ - FOREIGN KEY constraints   │
│ - UNIQUE constraints        │
└──────────┬──────────────────┘
           │ Valid
           ▼
    Data Persisted
```

---

## Key Data Flow Principles

1. **Unidirectional Flow**: Data flows from user → BLoC → repository → database
2. **State Immutability**: State objects are never mutated, only replaced
3. **Single Source of Truth**: Database is the authoritative data source
4. **Reactive Updates**: UI automatically updates when state changes
5. **Error Boundaries**: Errors are caught and handled at appropriate layers
6. **Offline First**: Local database operations work without network
7. **Caching**: Expensive operations (API calls) are cached
8. **Lazy Loading**: Data loaded on-demand to improve performance

---

## Future Enhancements

### Cloud Synchronization Flow (Phase 2)
```
Local Change → Mark as dirty → Queue for sync
                                    │
                          Network available?
                                    │
                              ┌─────┴─────┐
                              │           │
                             Yes         No
                              │           │
                              ▼           └─► Wait
                        Upload to cloud
                              │
                    Detect conflicts?
                              │
                        ┌─────┴─────┐
                        │           │
                       Yes         No
                        │           │
                        ▼           ▼
                 Resolve conflict  Mark synced
                 (last-write-wins  Clear dirty flag
                  or user choice)       │
                        │               │
                        └───────┬───────┘
                                │
                                ▼
                      Update local database
                      with server timestamp
```

### Real-time Collaboration Flow (Phase 3)
```
WebSocket connection
        │
        ▼
Listen for remote changes
        │
        ▼
Remote change received
        │
        ▼
Merge with local state
        │
        ▼
Update database
        │
        ▼
Notify BLoC
        │
        ▼
Update UI
```
