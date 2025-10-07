# Domain Models

This document describes the core domain models for the VanVoyage application, including entities, their relationships, and data structures.

## Core Domain Entities

### 1. Trip

Represents a complete van travel journey with associated metadata and schedule.

**Properties:**
- `id`: String (UUID) - Unique identifier
- `name`: String - User-defined trip name
- `description`: String? - Optional trip description
- `startDate`: DateTime - Trip start date
- `endDate`: DateTime - Trip end date
- `status`: TripStatus - Current trip status (PLANNING, ACTIVE, COMPLETED, ARCHIVED)
- `createdAt`: DateTime - Creation timestamp
- `updatedAt`: DateTime - Last modification timestamp

**Relationships:**
- Has many `Waypoint`s (ordered list)
- Has many `TripPhase`s (typically 1-3 phases)
- Has one `TripPreferences`

**Invariants:**
- `endDate` must be after `startDate`
- Must have at least one `Waypoint`
- Active trip can only have one per user

---

### 2. TripPhase

Represents a distinct phase of a trip (e.g., "Outbound Journey", "Exploring Region", "Return Journey").

**Properties:**
- `id`: String (UUID) - Unique identifier
- `tripId`: String - Foreign key to Trip
- `name`: String - Phase name
- `phaseType`: PhaseType - Type of phase (OUTBOUND, EXPLORATION, RETURN)
- `startDate`: DateTime - Phase start date
- `endDate`: DateTime - Phase end date
- `sequenceOrder`: int - Order within trip (0-based)

**Relationships:**
- Belongs to one `Trip`
- Has many `Waypoint`s (subset of trip waypoints)

**Invariants:**
- Phase dates must fall within trip dates
- Phases cannot overlap in time
- `sequenceOrder` must be unique within a trip

---

### 3. Waypoint

Represents a location on the trip route where the traveler will visit or stay.

**Properties:**
- `id`: String (UUID) - Unique identifier
- `tripId`: String - Foreign key to Trip
- `phaseId`: String? - Optional foreign key to TripPhase
- `name`: String - Location name
- `description`: String? - Optional description
- `latitude`: double - Geographic latitude
- `longitude`: double - Geographic longitude
- `address`: String? - Human-readable address
- `waypointType`: WaypointType - Type (OVERNIGHT_STAY, POI, TRANSIT)
- `arrivalDate`: DateTime? - Planned arrival
- `departureDate`: DateTime? - Planned departure
- `stayDuration`: int? - Duration in days (for overnight stays)
- `sequenceOrder`: int - Order in route
- `estimatedDrivingTime`: int? - Minutes from previous waypoint
- `estimatedDistance`: double? - Kilometers from previous waypoint

**Relationships:**
- Belongs to one `Trip`
- Optionally belongs to one `TripPhase`
- Has many `Activity` items

**Invariants:**
- `departureDate` must be after `arrivalDate` if both set
- `stayDuration` >= 1 for OVERNIGHT_STAY type
- `sequenceOrder` must be unique within a trip

---

### 4. Activity

Represents things to do or see at a waypoint.

**Properties:**
- `id`: String (UUID) - Unique identifier
- `waypointId`: String - Foreign key to Waypoint
- `name`: String - Activity name
- `description`: String? - Activity details
- `category`: ActivityCategory - Category (SIGHTSEEING, HIKING, DINING, etc.)
- `estimatedDuration`: int? - Duration in minutes
- `cost`: double? - Estimated cost
- `priority`: Priority - Importance (HIGH, MEDIUM, LOW)
- `notes`: String? - User notes
- `isCompleted`: bool - Completion status

**Relationships:**
- Belongs to one `Waypoint`

---

### 5. TripPreferences

Configuration settings for trip planning behavior.

**Properties:**
- `id`: String (UUID) - Unique identifier
- `tripId`: String - Foreign key to Trip (one-to-one)
- `maxDailyDrivingDistance`: int - Maximum km per day
- `maxDailyDrivingTime`: int - Maximum minutes per day
- `preferredDrivingSpeed`: int - Average km/h for calculations
- `includeRestStops`: bool - Factor in rest stops
- `restStopInterval`: int? - Minutes between rest stops
- `avoidTolls`: bool - Avoid toll roads
- `avoidHighways`: bool - Avoid highways
- `preferScenicRoutes`: bool - Prefer scenic routes

**Relationships:**
- Belongs to one `Trip` (one-to-one)

---

### 6. Route

Represents the calculated route between waypoints.

**Properties:**
- `id`: String (UUID) - Unique identifier
- `tripId`: String - Foreign key to Trip
- `fromWaypointId`: String - Starting waypoint
- `toWaypointId`: String - Ending waypoint
- `geometry`: String - Encoded polyline (GeoJSON LineString)
- `distance`: double - Total distance in kilometers
- `duration`: int - Estimated duration in minutes
- `calculatedAt`: DateTime - When route was calculated
- `routeProvider`: String - Service used (e.g., "Mapbox")

**Relationships:**
- Belongs to one `Trip`
- References two `Waypoint`s (from/to)

**Invariants:**
- `fromWaypointId` and `toWaypointId` must be different
- Must belong to waypoints of the same trip

---

## Enumerations

### TripStatus
```dart
enum TripStatus {
  PLANNING,    // Trip is being planned
  ACTIVE,      // Trip is currently in progress
  COMPLETED,   // Trip has been completed
  ARCHIVED     // Trip is archived for reference
}
```

### PhaseType
```dart
enum PhaseType {
  OUTBOUND,     // Journey to destination region
  EXPLORATION,  // Exploring within region
  RETURN        // Journey back home
}
```

### WaypointType
```dart
enum WaypointType {
  OVERNIGHT_STAY,  // Location where traveler will sleep
  POI,             // Point of interest to visit
  TRANSIT          // Waypoint for routing purposes only
}
```

### ActivityCategory
```dart
enum ActivityCategory {
  SIGHTSEEING,
  HIKING,
  DINING,
  SHOPPING,
  CULTURAL,
  OUTDOOR,
  RELAXATION,
  OTHER
}
```

### Priority
```dart
enum Priority {
  HIGH,
  MEDIUM,
  LOW
}
```

---

## Entity Relationships Diagram

```
┌─────────────┐
│    Trip     │
│─────────────│
│ id          │
│ name        │
│ startDate   │
│ endDate     │
│ status      │
└─────┬───────┘
      │
      │ 1:N
      │
      ├────────────────────────────────────┐
      │                                    │
      │                                    │
┌─────▼────────┐                  ┌───────▼────────┐
│  TripPhase   │                  │ TripPreferences│
│──────────────│                  │────────────────│
│ id           │                  │ id             │
│ tripId       │                  │ tripId (FK)    │
│ name         │                  │ maxDaily...    │
│ phaseType    │                  │ preferred...   │
│ startDate    │                  └────────────────┘
│ endDate      │
│ sequenceOrder│                  ┌────────────┐
└─────┬────────┘                  │   Route    │
      │                           │────────────│
      │ 1:N                       │ id         │
      │                           │ tripId     │
┌─────▼────────┐                  │ geometry   │
│   Waypoint   │                  │ distance   │
│──────────────│                  │ duration   │
│ id           │◄─────────────────┤ fromWaypoint│
│ tripId (FK)  │                  │ toWaypoint │
│ phaseId (FK) │                  └────────────┘
│ name         │
│ latitude     │
│ longitude    │
│ waypointType │
│ arrivalDate  │
│ departureDate│
│ sequenceOrder│
└─────┬────────┘
      │
      │ 1:N
      │
┌─────▼────────┐
│   Activity   │
│──────────────│
│ id           │
│ waypointId(FK)│
│ name         │
│ category     │
│ priority     │
│ isCompleted  │
└──────────────┘
```

---

## Domain Model Design Principles

### 1. Immutability
Where possible, domain entities should be treated as immutable after creation. Updates should create new versions with modified fields.

### 2. Value Objects
Consider creating value objects for:
- `Location` (latitude, longitude, address)
- `DateRange` (startDate, endDate)
- `Distance` (value in km with unit conversion methods)
- `Duration` (value in minutes with formatting methods)

### 3. Aggregate Boundaries
- `Trip` is the aggregate root containing `TripPhase`, `Waypoint`, and `TripPreferences`
- All modifications should go through the Trip aggregate
- Ensures consistency of trip data

### 4. Domain Events
Consider implementing domain events for:
- `TripCreated`
- `WaypointAdded`
- `TripStatusChanged`
- `RouteCalculated`

These events can trigger side effects like route recalculation, notifications, etc.

---

## Future Enhancements

### Potential Additional Entities
- **User**: When multi-user support is added
- **CampingSpot**: Specialized waypoint with camping-specific info
- **Weather**: Weather forecast data for waypoints
- **Expense**: Trip expense tracking
- **Photo**: Trip photos associated with waypoints
- **Share**: Sharing trips with other users
- **Template**: Reusable trip templates

### Potential Relationships
- User-to-Trip (many-to-many for shared trips)
- Waypoint-to-CampingSpot (one-to-one for camping locations)
- Waypoint-to-Weather (one-to-many for forecast over time)
