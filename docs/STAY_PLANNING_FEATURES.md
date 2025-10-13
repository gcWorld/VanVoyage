# Stay Planning and Multi-day Itineraries

## Overview

This document describes the stay planning and multi-day itinerary features added to VanVoyage. These features allow users to configure detailed stay information for each waypoint and visualize their trip timeline.

## Features

### 1. Waypoint Detail Screen

**Location**: `lib/presentation/screens/waypoint_detail_screen.dart`

The Waypoint Detail Screen allows users to view and edit detailed information about each waypoint, including:

- **Waypoint Information**:
  - Name and description
  - Location (address or coordinates)
  - Waypoint type (Overnight Stay, Point of Interest, Transit Point)

- **Stay Details** (for Overnight Stays):
  - Arrival date
  - Departure date
  - Stay duration (in nights) - automatically calculated from dates or manually entered
  
- **Visit Details** (for Points of Interest):
  - Visit date (optional)

**Key Features**:
- View/Edit mode toggle
- Date pickers for arrival/departure dates
- Automatic calculation of stay duration based on dates
- Validation ensuring departure is after arrival
- Validation ensuring overnight stays have a minimum duration of 1 night
- Integration with waypoint repository for persistence

**Usage**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => WaypointDetailScreen(waypoint: myWaypoint),
  ),
);
```

### 2. Trip Itinerary Timeline

**Location**: `lib/presentation/widgets/trip_itinerary_timeline.dart`

A visual timeline widget that displays the trip itinerary with all waypoints in chronological order.

**Features**:
- Visual timeline with color-coded waypoint types:
  - Blue for Overnight Stays
  - Green for Points of Interest
  - Orange for Transit Points
- Displays stay information:
  - Arrival and departure dates
  - Stay duration
  - Visit dates
- Shows driving information:
  - Distance from previous waypoint
  - Estimated driving time
- Interactive: tap any waypoint to view/edit details
- Responsive design with cards and icons

**Usage**:
```dart
TripItineraryTimeline(
  trip: myTrip,
  waypoints: myWaypoints,
  onWaypointTap: (waypoint) {
    // Handle waypoint tap
  },
)
```

### 3. Trip Itinerary Screen

**Location**: `lib/presentation/screens/trip_itinerary_screen.dart`

A full-screen view of the trip itinerary using the timeline widget.

**Features**:
- Displays trip header with name, dates, and duration
- Shows complete itinerary timeline
- Refresh button to reload data
- Error handling and loading states
- Navigation to waypoint details

**Usage**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TripItineraryScreen(tripId: myTripId),
  ),
);
```

### 4. Enhanced Trip Planning Flow

**Location**: `lib/presentation/screens/trip_planning_screen.dart`

The trip planning screen now includes a 4th step for reviewing the itinerary:

**Steps**:
1. **Trip Details** - Basic trip information (name, dates, description)
2. **Add Destinations** - Select waypoints on map
3. **Travel Constraints** - Configure driving preferences
4. **Review Itinerary** - NEW - View timeline, configure stays, finish planning

The new step allows users to:
- Review their complete itinerary in timeline format
- Tap waypoints to configure stay details
- Finish the planning process

## Domain Model Support

The existing domain model already supports stay planning through the `Waypoint` entity:

```dart
class Waypoint {
  final DateTime? arrivalDate;      // When arriving at this waypoint
  final DateTime? departureDate;    // When departing from this waypoint
  final int? stayDuration;          // Duration in days (for overnight stays)
  final String? description;         // Notes/details about the waypoint
  // ... other fields
}
```

**Validation Rules**:
- `departureDate` must be after `arrivalDate` if both are set
- `stayDuration` must be >= 1 for OVERNIGHT_STAY type waypoints
- Coordinates must be valid latitude (-90 to 90) and longitude (-180 to 180)

## Database Schema

The database already supports these fields through the `waypoints` table:

```sql
CREATE TABLE waypoints (
  id TEXT PRIMARY KEY,
  trip_id TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  waypoint_type TEXT NOT NULL,
  arrival_date INTEGER,        -- Timestamp in milliseconds
  departure_date INTEGER,      -- Timestamp in milliseconds
  stay_duration INTEGER,       -- Duration in days
  sequence_order INTEGER NOT NULL,
  -- ... other fields
)
```

## User Workflows

### Adding Stay Details to a Waypoint

1. Navigate to trip planning or itinerary view
2. Tap on a waypoint to open the detail screen
3. Tap the edit button (pencil icon)
4. Select waypoint type (e.g., "Overnight Stay")
5. Set arrival date using date picker
6. Set departure date using date picker
7. Stay duration is automatically calculated, or enter manually
8. Add description/notes
9. Tap "Save Changes"

### Viewing Trip Itinerary

**From Trip Planning**:
1. Create a trip (Step 1)
2. Add destinations (Step 2)
3. Configure preferences (Step 3)
4. Review itinerary in Step 4
5. Tap waypoints to configure stays
6. Tap "Finish Planning"

**Standalone View**:
1. Navigate to trip itinerary screen with trip ID
2. View timeline of all waypoints
3. Tap any waypoint to view/edit details
4. Use refresh button to reload data

## Testing

Unit tests have been added to verify stay planning functionality:

**Location**: `test/unit/domain/waypoint_test.dart`

**Test Coverage**:
- Creating waypoints with arrival/departure dates
- Validating waypoint dates (departure after arrival)
- Serialization/deserialization of date fields
- Stay duration calculation and validation
- Copying waypoints with updated dates

**Run Tests**:
```bash
flutter test test/unit/domain/waypoint_test.dart
```

## Future Enhancements

Potential improvements for stay planning:

1. **Calendar View**: Add a calendar widget showing occupied dates
2. **Conflict Detection**: Warn about overlapping stays
3. **Auto-scheduling**: Automatically suggest arrival/departure dates based on driving time
4. **Activity Integration**: Link activities to specific days during a stay
5. **Weather Integration**: Show weather forecasts for stay dates
6. **Booking Links**: Add links to accommodation booking sites
7. **Cost Tracking**: Track costs per stay
8. **Photo Gallery**: Add photos for each waypoint/stay

## Architecture Notes

### Design Principles

1. **Minimal Changes**: Leveraged existing domain model and database schema
2. **Separation of Concerns**: 
   - Domain entities handle data and validation
   - Screens handle user interaction
   - Widgets handle presentation
   - Repositories handle persistence
3. **Reusability**: Timeline widget can be used in multiple contexts
4. **Testability**: Pure domain logic is easily testable

### Component Relationships

```
WaypointDetailScreen
  └─> Uses WaypointRepository for persistence
  └─> Navigated to from TripItineraryTimeline or TripPlanningScreen

TripItineraryTimeline (Widget)
  └─> Displays list of Waypoints
  └─> Calls onWaypointTap callback
  └─> Used by TripItineraryScreen and TripPlanningScreen

TripItineraryScreen
  └─> Uses TripRepository and WaypointRepository
  └─> Contains TripItineraryTimeline
  └─> Navigates to WaypointDetailScreen

TripPlanningScreen (Enhanced)
  └─> Added Step 4: Review Itinerary
  └─> Contains TripItineraryTimeline
  └─> Navigates to WaypointDetailScreen
```

## API Reference

### WaypointDetailScreen

```dart
WaypointDetailScreen({
  required Waypoint waypoint,
})
```

Returns: `Waypoint?` (updated waypoint if saved)

### TripItineraryTimeline

```dart
TripItineraryTimeline({
  required Trip trip,
  required List<Waypoint> waypoints,
  Function(Waypoint)? onWaypointTap,
})
```

### TripItineraryScreen

```dart
TripItineraryScreen({
  required String tripId,
})
```

## Troubleshooting

### Issue: Stay duration not calculating automatically

**Solution**: Ensure both arrival and departure dates are set. The duration is calculated as the difference in days.

### Issue: Validation error when saving overnight stay

**Solution**: Overnight stays require:
- Stay duration >= 1 day
- Departure date after arrival date (if both set)

### Issue: Waypoint not updating in timeline

**Solution**: The timeline screen reloads data when returning from waypoint detail screen. Ensure the waypoint was saved successfully.

## Related Documentation

- [Domain Models](architecture/01-domain-models.md) - Domain entity definitions
- [Trip Planning UI](TRIP_PLANNING_UI.md) - Trip planning interface documentation
- [UI Navigation](architecture/04-ui-navigation.md) - Navigation flow documentation
