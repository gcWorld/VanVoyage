# Interactive Map Screen

## Overview

The `InteractiveMapScreen` provides a full-featured map interface using Mapbox GL for trip planning and location tracking.

## Features

### Map Display
- **Mapbox GL Integration**: Uses Mapbox Outdoors style optimized for outdoor activities and travel
- **Interactive Controls**: Pan, zoom, and rotate the map
- **Location Indicator**: Blue pulsing dot shows current user location

### Map Controls

1. **Zoom In/Out Buttons**: Mini FABs on the right side for zooming
2. **Center on Location**: Quickly center map on current user location
3. **Toggle Location Tracking**: Enable/disable continuous location updates
   - Green icon when tracking is active
   - Map automatically follows user movement when enabled

### Location Information

A card overlay displays:
- Current latitude and longitude coordinates
- GPS accuracy in meters
- Updates in real-time when tracking is enabled

## Usage

### Basic Navigation

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const InteractiveMapScreen(),
  ),
);
```

### Required Permissions

The app requires location permissions to function:
- **Android**: `ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION`
- **iOS**: Location when in use permission

Permissions are automatically requested when the map screen is opened.

## Services Used

### LocationService
- GPS position tracking
- Permission management
- Location stream for real-time updates
- Distance calculations

### MapboxService
- Map rendering via Mapbox GL
- Geocoding and reverse geocoding
- Place search functionality
- Route calculation

## Map Styles

Currently using `MapboxStyles.OUTDOORS` which is ideal for:
- Outdoor activities
- Trip planning
- Hiking and camping locations
- Natural features visualization

To change the map style, modify the `styleUri` parameter in the `MapWidget`:

```dart
MapWidget(
  styleUri: MapboxStyles.STREETS, // or SATELLITE_STREETS, LIGHT, DARK
  // ...
)
```

## Architecture

The screen follows the Clean Architecture pattern:
- **Presentation Layer**: `InteractiveMapScreen` widget
- **Infrastructure Layer**: `LocationService` and `MapboxService`
- **State Management**: Uses Riverpod ConsumerStatefulWidget

## Future Enhancements

Planned features for future iterations:
- Waypoint markers for trip locations
- Route lines between waypoints
- Search location functionality
- Long press to add waypoints
- Bottom sheet for waypoint details
- Trip selector dropdown
- Toggle between map styles (satellite/street view)
