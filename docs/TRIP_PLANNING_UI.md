# Trip Planning Interface - UI Documentation

This document describes the Trip Planning Interface implementation.

## Overview

The Trip Planning Interface provides a comprehensive UI for creating and editing trip plans with three main steps:
1. **Trip Details** - Basic trip information
2. **Add Destinations** - Destination picker with map integration
3. **Travel Constraints** - Trip preferences and constraints

## Screen Structure

### TripPlanningScreen

The main screen uses a `Stepper` widget that guides users through the trip creation process.

#### Step 1: Trip Details (TripForm)

**Fields:**
- **Trip Name** - Required text field with validation
  - Minimum 3 characters
  - Text capitalization enabled
  - Icon: label icon
  
- **Description** - Optional multi-line text field
  - Up to 3 lines
  - Text capitalization for sentences
  - Icon: description icon
  
- **Start Date** - Date picker in a card
  - Opens date picker dialog
  - Displayed format: "MMM dd, yyyy"
  - Icon: calendar_today
  
- **End Date** - Date picker in a card
  - Opens date picker dialog
  - Automatically adjusted if before start date
  - Displayed format: "MMM dd, yyyy"
  - Icon: event
  
- **Duration Display** - Read-only info card
  - Shows calculated trip duration in days
  - Highlighted in primary container color
  - Icon: timelapse

**Actions:**
- Create Trip / Save Changes button (context-dependent)

#### Step 2: Add Destinations (DestinationPicker)

**Components:**

1. **Location Input Section** (Top)
   - Text field for location name
   - Waypoint type selector (segmented button)
     - POI (Point of Interest) - place icon
     - Stay (Overnight Stay) - hotel icon
     - Transit (Transit point) - navigation icon
   - Selected coordinates card (shown when location selected)

2. **Interactive Map** (Center)
   - Full Mapbox map view
   - Tap to select location functionality
   - Selected location marked with pin
   - Instruction overlay: "Tap on the map to select a location"
   - Outdoor map style by default

3. **Confirm Button** (Bottom)
   - Full-width elevated button
   - Text: "Confirm Location"
   - Icon: check

**Interaction Flow:**
1. User taps on map to select location
2. Marker appears at selected coordinates
3. Coordinates displayed in info card
4. User enters location name
5. User selects waypoint type
6. User confirms location
7. Waypoint added with snackbar notification
8. Option to proceed to next step

#### Step 3: Travel Constraints (TripPreferencesForm)

**Sections:**

1. **Driving Preferences**
   
   a. Max Daily Distance
   - Slider: 100-800 km (divisions: 70)
   - Default: 300 km
   - Recommendation text: "300-500 km per day"
   
   b. Max Daily Driving Time
   - Slider: 60-600 minutes (1-10 hours, divisions: 54)
   - Default: 240 minutes (4 hours)
   - Display format: hours with 1 decimal
   - Recommendation text: "3-6 hours per day"
   
   c. Preferred Driving Speed
   - Slider: 50-120 km/h (divisions: 70)
   - Default: 80 km/h
   - Info text: "Used for travel time calculations"

2. **Route Preferences**
   
   Switch list tiles:
   - **Avoid Tolls** - Default: false
     - Subtitle: "Prefer routes without toll roads"
   - **Avoid Highways** - Default: false
     - Subtitle: "Take smaller roads when possible"
   - **Prefer Scenic Routes** - Default: false
     - Subtitle: "Prioritize beautiful landscapes"

3. **Rest Stop Settings**
   
   a. Include Rest Stops switch - Default: true
   - Subtitle: "Factor in breaks during long drives"
   
   b. Rest Stop Interval (conditional - shown when enabled)
   - Slider: 60-300 minutes (1-5 hours, divisions: 24)
   - Default: 120 minutes (2 hours)
   - Display format: hours with 1 decimal
   - Recommendation text: "2-3 hours between breaks"

**Actions:**
- Save Preferences button
- Upon save, shows success message and returns to previous screen

## Navigation Flow

```
HomeScreen
  └─> [Create Trip Button] 
       └─> TripPlanningScreen
            ├─> Step 0: TripForm
            │    └─> [Create Trip] saves to DB → Step 1
            ├─> Step 1: DestinationPicker
            │    └─> [Confirm Location] adds waypoint
            │         └─> Can add multiple waypoints
            │         └─> [Next Step] → Step 2
            └─> Step 2: TripPreferencesForm
                 └─> [Save Preferences] → Navigate back

HomeScreen also has:
  └─> [Open Map Button] → InteractiveMapScreen
```

## Data Flow

### Creating a New Trip

1. User fills TripForm
2. On submit, creates Trip entity with:
   - Generated UUID
   - User-provided name, description
   - Selected start/end dates
   - Status: PLANNING
   - Created/updated timestamps
3. Trip saved to SQLite database
4. Trip ID stored in component state

### Adding Waypoints

1. User selects location on map
2. Map returns coordinates (lat/lng)
3. User enters location name
4. User selects waypoint type
5. On confirm, creates Waypoint entity with:
   - Generated UUID
   - Trip ID (from current trip)
   - Name and coordinates
   - Waypoint type
   - Sequence order (based on current waypoint count)
6. Waypoint saved to database
7. Waypoint added to local list

### Saving Preferences

1. User adjusts sliders and toggles
2. On save, creates TripPreferences entity with:
   - Generated UUID
   - Trip ID
   - All preference values
3. In current implementation, preferences shown in success message
4. (Future: would be saved to database)

## Validation Rules

### TripForm
- Trip name: Required, minimum 3 characters
- Start date: Must be valid date
- End date: Must be after start date (auto-adjusted if not)

### DestinationPicker
- Location name: Required (enforced on confirm)
- Coordinates: Required (must tap map)

### TripPreferencesForm
- All values have reasonable defaults
- Real-time constraint validation with warnings and errors
- Sliders enforce min/max ranges
- Visual warnings for values outside recommended ranges
- Error messages for values outside safe limits
- Consistency validation between related preferences
- See [TRAVEL_CONSTRAINTS.md](TRAVEL_CONSTRAINTS.md) for detailed validation rules

## Styling

- Uses Material 3 design
- Theme: ColorScheme.fromSeed(seedColor: Colors.deepOrange)
- Cards for grouping related information
- Elevated buttons for primary actions
- List tiles for switches
- Sliders with labels showing current values
- Icons for visual clarity

## Dependencies

- flutter/material.dart - UI framework
- flutter_riverpod - State management
- mapbox_maps_flutter - Map integration
- intl - Date formatting
- sqflite - Database operations

## Testing

Widget tests created for:
- TripForm: Form validation, field presence, edit mode, date pickers
- TripPreferencesForm: Section presence, slider values, switch states, save functionality, constraint warnings

Unit tests created for:
- TravelConstraintValidator: 15 test cases covering all validation rules

## Future Enhancements

Potential improvements:
1. Location search/geocoding in DestinationPicker
2. Save TripPreferences to database (repository implementation)
3. Edit existing waypoints
4. Reorder waypoints
5. Delete waypoints
6. Route preview on map
7. Import waypoints from saved locations
8. Batch operations for multiple destinations
