# Routing Profiles Feature

## Overview

Added support for different routing profiles to accommodate various travel modes and preferences when calculating routes.

## Available Profiles

### 1. Fastest (Driving) - Default
**Icon**: 🚗 `Icons.directions_car`

- Optimized for fastest time by car
- Uses highways and main roads
- Best for: General road trips, time-efficient travel

**Use Case**: Standard van travel where speed is a priority

---

### 2. Traffic-Aware (Driving)
**Icon**: 🚦 `Icons.traffic`

- Considers real-time traffic conditions
- Avoids congested areas dynamically
- Updates based on current traffic data
- Best for: Urban travel, rush hour, time-sensitive trips

**Use Case**: City driving during busy hours, avoiding delays

---

### 3. Walking
**Icon**: 🚶 `Icons.directions_walk`

- Pedestrian-friendly routes
- Uses sidewalks and walking paths
- Prioritizes shorter distances
- Best for: City exploration, hiking trails, when vehicle can't access

**Use Case**: Exploring a destination on foot after parking the van

---

### 4. Cycling
**Icon**: 🚴 `Icons.directions_bike`

- Bike-friendly routes
- Uses bike lanes and dedicated paths
- Considers elevation and road types
- Best for: Bike tours, cycling adventures

**Use Case**: Planning bike trips from campsite to local attractions

---

## User Interface

### Profile Selector

The profile selector is accessible from the TripRouteScreen:

1. **Location**: App bar, left of refresh button
2. **Icon**: Shows current profile icon (car, traffic, walk, bike)
3. **Tooltip**: "Route type: [Profile Name]"
4. **Action**: Tap to open modal bottom sheet

### Selection Modal

When tapped, a modal bottom sheet appears with:

```
┌─────────────────────────────────┐
│   Select Route Type             │
├─────────────────────────────────┤
│ 🚗 Fastest                      │
│    Fastest route by car      ✓  │
├─────────────────────────────────┤
│ 🚦 Traffic                      │
│    Route considering traffic    │
├─────────────────────────────────┤
│ 🚶 Walking                      │
│    Walking route                │
├─────────────────────────────────┤
│ 🚴 Cycling                      │
│    Cycling route                │
└─────────────────────────────────┘
```

- Current selection shows checkmark
- Tap any profile to select
- Routes automatically recalculate

---

## How It Works

### Route Calculation Flow

```
User selects profile
        ↓
TripRouteScreen updates _selectedProfile
        ↓
Calls _refreshRoutes()
        ↓
RouteService.calculateTripRoute(profile: selectedProfile)
        ↓
MapboxService.calculateRoute(profile: profile)
        ↓
API: GET /directions/v5/mapbox/{profile}/...
        ↓
Routes returned and visualized
```

### API Integration

Mapbox Directions API supports these profile strings:
- `driving` → RoutingProfile.driving
- `driving-traffic` → RoutingProfile.drivingTraffic
- `walking` → RoutingProfile.walking
- `cycling` → RoutingProfile.cycling

### Caching

Routes are cached separately for each profile:
- Cache key includes waypoint IDs (not profile)
- Changing profile forces recalculation
- 7-day cache expiry still applies

---

## Code Examples

### Basic Usage

```dart
// Calculate route with specific profile
final route = await routeService.calculateRoute(
  tripId,
  fromWaypoint,
  toWaypoint,
  profile: RoutingProfile.drivingTraffic,
);
```

### With Alternatives

```dart
// Get alternatives for cycling
final alternatives = await routeService.calculateRouteWithAlternatives(
  tripId,
  fromWaypoint,
  toWaypoint,
  profile: RoutingProfile.cycling,
);
```

### Entire Trip

```dart
// Calculate full trip with walking profile
final routes = await routeService.calculateTripRoute(
  tripId,
  waypoints,
  profile: RoutingProfile.walking,
);
```

---

## Addressing the "Scenic Route" Request

### Current Approach

While Mapbox doesn't offer a dedicated "scenic" routing profile, users can find scenic routes by:

1. **Using Standard Driving Profile**: Tends to favor well-maintained, often scenic roads
2. **Viewing Alternatives**: The alternative routes feature often includes more scenic options
3. **Manual Selection**: Compare alternatives and choose the one that looks most scenic on the map

### Why No Dedicated Scenic Profile?

Mapbox Directions API doesn't provide a scenic profile because:
- "Scenic" is subjective and varies by region
- Would require extensive scenic road database
- Different users have different scenic preferences

### Workaround Strategy

```
1. Calculate route with Driving profile
2. Request alternatives (up to 3 routes)
3. View each route on map
4. Select the one that:
   - Follows coastlines, mountains, or rivers
   - Avoids highways when possible
   - Has interesting landmarks
```

### Future Enhancement Possibility

Could implement a custom scenic scoring algorithm:
- Analyze route geometry for coastal/mountain proximity
- Check for national parks along route
- Factor in road type (prefer scenic byways)
- Rank alternatives by "scenic score"

---

## Route Comparison

### Distance vs. Time Trade-offs

Different profiles optimize for different factors:

| Profile | Optimizes For | Average Speed | Route Type |
|---------|---------------|---------------|------------|
| Driving | Time | 80-120 km/h | Highways, main roads |
| Traffic | Time (w/ conditions) | 40-100 km/h | Less congested routes |
| Walking | Accessibility | 5 km/h | Sidewalks, paths |
| Cycling | Bike-friendly | 15-25 km/h | Bike lanes, low traffic |

### Example Comparison

San Francisco to Yosemite (Same waypoints, different profiles):

```
Driving Profile:
- Distance: 280 km
- Duration: 3h 45min
- Route: I-580, CA-120

Traffic Profile (peak hours):
- Distance: 295 km
- Duration: 4h 20min
- Route: Alternative avoiding I-580 congestion

Walking Profile:
- Distance: 265 km (more direct paths)
- Duration: 53 hours (!)
- Route: Local roads, trails

Cycling Profile:
- Distance: 288 km
- Duration: 19 hours
- Route: Bike-friendly roads, some climbing
```

---

## Benefits

### For Van Travelers

1. **Traffic Avoidance**: Use Traffic profile in urban areas
2. **Destination Exploration**: Switch to Walking when parked
3. **Multi-Modal**: Plan bike excursions with Cycling profile
4. **Flexibility**: Choose fastest route or more scenic alternative

### Technical Benefits

1. **Accurate Routing**: Profile-specific calculations
2. **Better Estimates**: Travel times match mode
3. **User Choice**: Empowers users to select preference
4. **API Leverage**: Uses full Mapbox capabilities

---

## Testing

### Manual Test Steps

1. Open route demo from main screen
2. Tap "View Route on Map"
3. Note the route and statistics
4. Tap route type icon (car icon)
5. Select "Walking"
6. Observe:
   - Route recalculates
   - Duration increases significantly
   - Route may follow different paths
7. Try other profiles
8. Verify alternative routes work with each profile

### Expected Behavior

- Profile changes trigger route recalculation
- Loading indicator shown during calculation
- Route lines update on map
- Statistics reflect profile characteristics
- Alternative routes available for all profiles

---

## Limitations

1. **No Scenic Profile**: Mapbox doesn't provide this
2. **Profile Availability**: All 4 profiles always available (no geographic restrictions checked)
3. **Cache**: Profile changes bypass cache (always recalculate)
4. **Historical Traffic**: Traffic profile uses current conditions, not predicted

---

## Future Enhancements

### Phase 1: Enhanced Profiles
- Add RV-specific routing (height/weight restrictions)
- Add "prefer scenic byways" filter
- Add "avoid unpaved roads" option

### Phase 2: Custom Profiles
- User-defined preferences per profile
- Save preferred profile per trip
- Profile-specific alternative route limits

### Phase 3: Advanced Features
- Combine profiles (e.g., drive + walk segments)
- Time-of-day profile switching
- Weather-aware routing

---

**Feature Added**: 2025-10-14
**Version**: 1.1.0
**Commit**: 9e4ad4a
