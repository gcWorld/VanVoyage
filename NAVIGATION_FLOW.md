# VanVoyage Navigation Flow

## Overview
This document illustrates the navigation flow after implementing the trip management screens.

## Screen Navigation Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        TripListScreen                           │
│                         (Home Screen)                           │
│                                                                 │
│  ╔═══════════════════════════════════════════════════════════╗ │
│  ║ Filter: [All] [Planning] [Active] [Completed] [Archived] ║ │
│  ╚═══════════════════════════════════════════════════════════╝ │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ 🚐 Summer Road Trip                    📍 PLANNING      │  │
│  │ Jun 1, 2024 - Jun 15, 2024                              │  │
│  │ 15 days                                                 │  │
│  │                                    [Edit] [View] ──────►│  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ 🚐 Cross Country Adventure         ✓ COMPLETED          │  │
│  │ Jul 1, 2023 - Jul 31, 2023                              │  │
│  │ 31 days                                                 │  │
│  │                                    [Edit] [View] ──────►│  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│                                              [+ Create Trip] ◄─│─── FAB
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
        │                                                 │
        │ [Tap Card]                           [Edit Button]
        │                                                 │
        ▼                                                 ▼
┌──────────────────────┐                    ┌──────────────────────┐
│  TripDetailScreen    │                    │ TripPlanningScreen   │
│                      │                    │                      │
│  ╔════════════════╗  │                    │  Step 1: Trip Details│
│  ║ Summer Trip    ║  │                    │  Step 2: Destinations│
│  ║ Jun 1-15, 2024 ║  │                    │  Step 3: Constraints │
│  ║ 15 days        ║  │                    │  Step 4: Itinerary   │
│  ╚════════════════╝  │                    │                      │
│                      │                    │  [Finish Planning]   │
│  Summary:            │                    │                      │
│  • 5 Waypoints       │                    └──────────────────────┘
│  • 3 Overnight Stays │                             │
│                      │                             │ [Finish]
│  Waypoints:          │                             │
│  1. San Francisco    │◄────────────────────────────┘
│  2. Yosemite NP      │
│  3. Lake Tahoe       │
│                      │
│  [View Timeline] ──► │
│  [View Route Map] ─► │
│                      │
└──────────────────────┘
        │                        │
        │ [View Timeline]        │ [View Route Map]
        ▼                        ▼
┌──────────────────────┐  ┌──────────────────────┐
│ TripItineraryScreen  │  │  TripRouteScreen     │
│                      │  │                      │
│  Day 1 Timeline      │  │  🗺️ Map View         │
│  │                   │  │  with route lines    │
│  ├─ Start: SF        │  │                      │
│  │                   │  │  Route Summary:      │
│  ├─ Drive 3hrs       │  │  • 450 km            │
│  │                   │  │  • 6h 30min          │
│  └─ Arrive: Yosemite │  │                      │
│                      │  │  [Driving Mode ▼]    │
│  Day 2 Timeline      │  │  [Refresh Routes]    │
│  ...                 │  │                      │
│                      │  └──────────────────────┘
└──────────────────────┘
```

## Navigation Paths

### 1. Create New Trip Flow
```
TripListScreen
    │
    │ [Tap FAB]
    ▼
TripPlanningScreen (Create Mode)
    │
    │ Step 1: Enter trip name, dates
    │ Step 2: Add waypoints
    │ Step 3: Set preferences
    │ Step 4: Review itinerary
    │
    │ [Tap "Finish Planning"]
    ▼
TripListScreen (refreshed with new trip)
```

### 2. View Trip Details Flow
```
TripListScreen
    │
    │ [Tap Trip Card]
    ▼
TripDetailScreen
    │
    ├─ [Tap Edit Button] ──────────► TripPlanningScreen (Edit Mode)
    │                                    │
    │                                    │ [Finish Planning]
    │                                    ▼
    │                                TripDetailScreen (refreshed)
    │
    ├─ [Tap Waypoint] ────────────► WaypointDetailScreen
    │                                    │
    │                                    │ [Save Changes]
    │                                    ▼
    │                                TripDetailScreen (refreshed)
    │
    ├─ [Tap "View Timeline"] ─────► TripItineraryScreen
    │
    └─ [Tap "View Route Map"] ────► TripRouteScreen (2+ waypoints required)
```

### 3. Edit Trip Flow
```
TripListScreen
    │
    │ [Tap "Edit" or Long Press → Edit]
    ▼
TripPlanningScreen (Edit Mode - loads existing data)
    │
    │ Can modify all steps
    │
    │ [Tap "Finish Planning"]
    ▼
TripListScreen (refreshed with updated trip)
```

### 4. Delete Trip Flow
```
TripListScreen
    │
    │ [Long Press Trip Card]
    ▼
Quick Actions Menu
    │
    │ [Tap "Delete"]
    ▼
Confirmation Dialog
    │
    │ [Tap "Delete"]
    ▼
TripListScreen (trip removed)
```

## State Management Flow

### Trip List State
```
TripListScreen
    │
    ├─ _trips: List<Trip>         // All trips or filtered
    ├─ _isLoading: bool            // Loading indicator
    ├─ _error: String?             // Error message
    └─ _filterStatus: TripStatus?  // Current filter
         │
         └─ Loads from: TripRepository.findAll() or findByStatus()
```

### Trip Detail State
```
TripDetailScreen
    │
    ├─ _trip: Trip?                // Trip data
    ├─ _waypoints: List<Waypoint>  // Trip waypoints
    ├─ _isLoading: bool            // Loading indicator
    └─ _error: String?             // Error message
         │
         ├─ Loads from: TripRepository.findById(tripId)
         └─ Loads from: WaypointRepository.findByTripId(tripId)
```

## User Actions Matrix

| Screen | Action | Navigation Target | Data Changed |
|--------|--------|------------------|--------------|
| TripListScreen | Tap FAB | TripPlanningScreen | None |
| TripListScreen | Tap Card | TripDetailScreen | None |
| TripListScreen | Tap Edit | TripPlanningScreen (edit) | None |
| TripListScreen | Long Press → Delete | Confirmation Dialog | Trip deleted |
| TripListScreen | Pull to Refresh | Same screen | Reloads trips |
| TripListScreen | Tap Filter Chip | Same screen | Changes filter |
| TripDetailScreen | Tap Edit | TripPlanningScreen (edit) | None |
| TripDetailScreen | Tap Waypoint | WaypointDetailScreen | None |
| TripDetailScreen | Tap "View Timeline" | TripItineraryScreen | None |
| TripDetailScreen | Tap "View Route Map" | TripRouteScreen | None |
| TripDetailScreen | Tap Map Icon (app bar) | TripRouteScreen | None |
| TripPlanningScreen | Tap "Finish Planning" | Previous screen (pop) | Trip created/updated |
| TripPlanningScreen | Tap "Cancel/Back" | Previous screen (pop) | None |

## Empty States

### TripListScreen - No Trips
```
┌─────────────────────────────────────┐
│         TripListScreen              │
│                                     │
│         🚐                          │
│    (large faded car icon)           │
│                                     │
│      No trips yet                   │
│                                     │
│  Create your first trip to          │
│  get started                        │
│                                     │
│  [Create Your First Trip]           │
│                                     │
│                                     │
│                    [+ Create Trip]  │
└─────────────────────────────────────┘
```

### TripDetailScreen - No Waypoints
```
┌─────────────────────────────────────┐
│       TripDetailScreen              │
│                                     │
│  ╔════════════════════════╗         │
│  ║ Trip Header            ║         │
│  ╚════════════════════════╝         │
│                                     │
│  Summary: 0 Waypoints               │
│                                     │
│  Waypoints:                         │
│                                     │
│      📍                             │
│  (faded location icon)              │
│                                     │
│    No waypoints yet                 │
│                                     │
│  Add waypoints to start             │
│  planning your route                │
│                                     │
└─────────────────────────────────────┘
```

## Error States

### Network/Database Error
```
┌─────────────────────────────────────┐
│         Screen Title                │
│                                     │
│         ⚠                           │
│    (large error icon)               │
│                                     │
│   Error loading trips               │
│                                     │
│  [Error message displayed here]     │
│                                     │
│         [🔄 Retry]                  │
│                                     │
└─────────────────────────────────────┘
```

## Data Flow Summary

### Creating a Trip
```
User Input (TripForm)
    ↓
Trip.create() [domain entity]
    ↓
TripRepository.insert() [database]
    ↓
State Update (setState)
    ↓
Navigate back with result=true
    ↓
TripListScreen refreshes
    ↓
New trip appears in list
```

### Viewing a Trip
```
Tap Trip Card
    ↓
Navigate to TripDetailScreen(tripId)
    ↓
Load Trip: TripRepository.findById()
    ↓
Load Waypoints: WaypointRepository.findByTripId()
    ↓
Update State with data
    ↓
Display trip details
```

### Editing a Trip
```
Tap Edit Button
    ↓
Navigate to TripPlanningScreen(tripId)
    ↓
Load existing trip and waypoints
    ↓
User modifies data
    ↓
Trip.copyWith() [creates updated entity]
    ↓
TripRepository.update() [database]
    ↓
Navigate back with result=true
    ↓
Previous screen refreshes
```

### Deleting a Trip
```
Long press → Delete
    ↓
Show confirmation dialog
    ↓
User confirms
    ↓
TripRepository.delete(tripId) [database]
    ↓
State Update (removes from list)
    ↓
Show success SnackBar
```

## Key Design Decisions

1. **Home Screen is Trip List**: Following the architecture docs, the main entry point is now the trip list rather than a placeholder screen.

2. **Navigation Return Values**: Screens return `true` when data is modified to signal parent screens to refresh.

3. **Centralized Providers**: All repository providers are in `lib/providers.dart` to avoid duplication and ensure consistency.

4. **Proper Error Handling**: All database operations are wrapped in try-catch with user-friendly error messages.

5. **Empty States**: Clear messaging when no data exists to guide users on next actions.

6. **Loading States**: CircularProgressIndicator shown during async operations for better UX.

7. **Confirmation Dialogs**: Destructive actions (like delete) require confirmation to prevent accidents.

8. **Material 3 Design**: Consistent use of Material 3 components (Cards, FilterChips, FAB, etc.).

## Future Enhancements

Potential improvements based on architecture docs:

- [ ] Search functionality in trip list
- [ ] Sort options (by date, name, status)
- [ ] Swipe to delete gesture
- [ ] Trip sharing functionality
- [ ] Thumbnail map in trip cards
- [ ] Archive trip action
- [ ] Batch operations (select multiple trips)
- [ ] Trip templates
- [ ] Export/import trips
