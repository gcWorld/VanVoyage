# Testing Route Calculation and Visualization

This guide explains how to test the route calculation and visualization features.

## Quick Test via Demo

The easiest way to test the route features is through the built-in demo:

1. **Launch the app**
2. **Tap the Map icon** in the app bar on the Trip List screen
3. **View the demo screen** showing a pre-configured California trip with 4 waypoints
4. **Tap "View Route on Map"** to see the route visualization

## What You'll See

### Route Summary
- Total distance for the entire trip
- Total estimated driving time
- Number of route segments

### Interactive Map
- Blue route lines connecting waypoints
- Map controls (zoom in/out, center on location)
- Waypoint markers

### Route Segments Panel
- Scrollable list of individual route segments
- Each segment shows:
  - Start and end waypoint names
  - Distance and duration
  - Share button for navigation apps

### Features to Test

#### 1. Route Visualization
- Routes should appear as blue lines on the map
- Map should fit to show all waypoints
- Route should follow roads (not straight lines)

#### 2. Alternative Routes
- Tap any route segment card
- View up to 3 alternative routes with different colors:
  - Blue: Fastest route
  - Dark grey: Alternative 1
  - Light grey: Alternative 2
- Each alternative shows distance and time
- Tap "Back to main route" to return

#### 3. Share to Navigation Apps
- Tap the share button on any route segment
- Select a navigation app:
  - Google Maps
  - Apple Maps
  - Waze
  - HERE WeGo
- App should open with the route pre-loaded
- **Note**: App must be installed on device

#### 4. Route Caching
- Routes are cached for 7 days
- First load may take a few seconds
- Subsequent loads should be instant
- Tap refresh to recalculate with current traffic

#### 5. Refresh Routes
- Tap the refresh icon in the app bar
- Routes will be recalculated
- Shows loading indicator during calculation

## Testing with Real Trips

To test with your own trips:

1. **Create a trip** from the main screen
2. **Add waypoints** with actual GPS coordinates
3. **Navigate to TripRouteScreen**:
   ```dart
   Navigator.push(
     context,
     MaterialPageRoute(
       builder: (context) => TripRouteScreen(
         tripId: yourTrip.id,
         waypoints: yourWaypoints,
       ),
     ),
   );
   ```

## Manual Testing Checklist

- [ ] Demo screen loads without errors
- [ ] Route lines appear on map
- [ ] Route summary shows correct totals
- [ ] Individual segments are listed
- [ ] Tapping segment shows alternatives
- [ ] Alternative routes have different distances
- [ ] Share button opens modal with app options
- [ ] Selecting app opens navigation app
- [ ] Refresh button recalculates routes
- [ ] Loading states display correctly
- [ ] Error messages display for network issues
- [ ] Map controls work (zoom, pan)
- [ ] Routes fit within viewport

## Unit Tests

Run the test suite:

```bash
flutter test test/unit/infrastructure/services/mapbox_service_test.dart
flutter test test/unit/domain/services/route_service_test.dart
```

Tests cover:
- Route calculation
- Alternative routes API
- Route caching logic
- Distance/duration formatting
- Error handling

## Common Issues

### Routes Not Displaying
- **Check Mapbox API key**: Verify key in `lib/secrets.dart`
- **Check network**: Requires internet for first load
- **Check coordinates**: Ensure waypoints have valid lat/lng

### Share Not Working
- **App not installed**: Target navigation app must be installed
- **Permissions**: Check URL scheme permissions in platform configs
- **Platform**: Some apps only work on specific platforms (iOS/Android)

### Performance Issues
- **Too many waypoints**: Consider limiting to 10-15 waypoints
- **Large route geometries**: Routes with many points may slow rendering
- **Network delays**: First load requires API calls

## API Limits

**Mapbox Directions API**:
- Free tier: 60,000 requests/month
- Rate limit: 300 requests/minute
- Caching reduces API usage significantly

## Debugging

Enable debug logging:
```dart
debugPrint('Route calculated: ${route.distance} km, ${route.duration} min');
```

Check for errors in console when:
- Routes don't appear
- API calls fail
- Share functionality doesn't work

## Screenshots

When submitting issues or feedback, include:
- Screenshot of route on map
- Screenshot of route segments list
- Screenshot of any error messages
- Device info (iOS/Android, version)

## Next Steps

After testing, consider:
1. Testing with longer trips (5+ waypoints)
2. Testing in areas with limited road networks
3. Testing offline behavior (should use cached routes)
4. Testing with different route preferences
5. Testing share functionality with all apps

---

For more details, see:
- [ROUTE_IMPLEMENTATION.md](ROUTE_IMPLEMENTATION.md) - Full implementation details
- [MAPBOX_INTEGRATION.md](MAPBOX_INTEGRATION.md) - Mapbox integration guide
