# UI Navigation Flow

This document outlines the user interface structure, navigation patterns, and screen hierarchy for VanVoyage.

## Navigation Architecture

### Navigation Pattern: Nested Navigation with Bottom Navigation Bar

VanVoyage uses a hybrid navigation approach:
- **Bottom Navigation Bar** for primary app sections
- **Stack Navigation** within each section for deeper navigation
- **Modal Routes** for creation/editing workflows
- **Deep Linking** for sharing and notifications

---

## App Navigation Hierarchy

```
Root Navigator
├── Splash Screen (Initial)
├── Onboarding Flow (First Launch)
└── Main App (Bottom Navigation)
    ├── Home Tab (Navigator)
    │   ├── Trip List Screen
    │   ├── Trip Detail Screen
    │   │   ├── Waypoint Detail Screen
    │   │   │   └── Activity Detail Screen
    │   │   ├── Route View Screen
    │   │   └── Edit Trip Screen (Modal)
    │   └── Create Trip Screen (Modal)
    │
    ├── Map Tab (Navigator)
    │   ├── Interactive Map Screen
    │   │   ├── Waypoint Info Panel (Bottom Sheet)
    │   │   ├── Route Overview Panel (Bottom Sheet)
    │   │   └── Add Waypoint Screen (Modal)
    │   └── Location Search Screen (Modal)
    │
    ├── Plan Tab (Navigator)
    │   ├── Active Trip Planning Screen
    │   │   ├── Optimize Route Screen
    │   │   ├── Adjust Schedule Screen
    │   │   └── Set Preferences Screen
    │   └── No Active Trip Screen
    │
    └── Settings Tab (Navigator)
        ├── Settings Screen
        ├── About Screen
        ├── Preferences Screen
        ├── Data Management Screen
        │   ├── Export Data Screen
        │   └── Import Data Screen
        └── Help Screen
```

---

## Screen Definitions

### 1. Splash & Onboarding

#### Splash Screen
**Purpose**: App initialization and branding
**Duration**: 1-2 seconds
**Actions**:
- Load app configuration
- Initialize database
- Check authentication (future)
- Navigate to onboarding or main app

#### Onboarding Flow
**Purpose**: First-time user introduction
**Screens**:
1. **Welcome**: App overview and value proposition
2. **Features**: Key features showcase (swipeable)
3. **Permissions**: Request location permissions
4. **Setup**: Initial preferences (units, language)

**Flow**:
```
Welcome → Features → Permissions → Setup → Main App
           ↓          ↓             ↓
         [Skip] → [Skip] → [Skip if granted]
```

---

### 2. Home Tab - Trip Management

#### Trip List Screen (Home)
**Purpose**: Overview of all trips
**Components**:
- Trip cards (shows trip name, dates, status, thumbnail map)
- Filter chips (Planning, Active, Completed, Archived)
- Floating Action Button (FAB) to create new trip
- Search bar (tap to expand)
- Sort options (by date, name, status)

**Navigation**:
- Tap trip card → Trip Detail Screen
- Tap FAB → Create Trip Screen (modal)
- Tap search → Expand search with filtering
- Long press card → Quick actions (edit, delete, archive)

**Empty State**:
- Illustration with message "No trips yet"
- "Create Your First Trip" button

---

#### Trip Detail Screen
**Purpose**: View and manage single trip details
**Sections**:
1. **Header**:
   - Trip name and dates
   - Status badge
   - Edit button
   - Share button (future)
   
2. **Summary Card**:
   - Total distance
   - Total duration
   - Number of waypoints
   - Number of overnight stays

3. **Map Preview**:
   - Small map showing route
   - Tap to open full map view

4. **Waypoints List**:
   - Ordered list of waypoints
   - Drag handles for reordering
   - Type icons (overnight, POI, transit)
   - Estimated arrival times
   - Tap to expand details

5. **Action Bar**:
   - Add Waypoint button
   - Calculate Route button
   - View on Map button

**Navigation**:
- Tap waypoint → Waypoint Detail Screen
- Tap map preview → Map Tab (with trip context)
- Tap edit → Edit Trip Screen (modal)
- Tap add waypoint → Add Waypoint Screen (modal)
- Tap calculate route → Route View Screen

---

#### Waypoint Detail Screen
**Purpose**: View and edit waypoint information
**Sections**:
1. **Header**:
   - Waypoint name
   - Type badge
   - Edit button

2. **Location Card**:
   - Address
   - Coordinates
   - Small map preview
   - "Get Directions" button

3. **Schedule Card**:
   - Arrival date/time
   - Departure date/time
   - Stay duration
   - Driving time from previous waypoint
   - Distance from previous waypoint

4. **Activities List**:
   - Activities to do at this location
   - Priority indicators
   - Completion checkboxes
   - Add activity button

5. **Notes Section**:
   - User notes (editable)

**Navigation**:
- Tap edit → Edit Waypoint Screen (modal)
- Tap activity → Activity Detail Screen
- Tap map preview → Map Tab (centered on waypoint)
- Tap add activity → Add Activity Screen (modal)

---

#### Activity Detail Screen
**Purpose**: View and edit activity details
**Components**:
- Activity name and description
- Category icon
- Priority indicator
- Estimated duration
- Estimated cost
- Completion status
- Notes

**Navigation**:
- Edit inline or via edit button
- Delete activity option

---

### 3. Map Tab - Geographic Visualization

#### Interactive Map Screen
**Purpose**: Visual representation of trip route
**Components**:
1. **Map View** (full screen):
   - Mapbox map
   - Waypoint markers (color-coded by type)
   - Route line (if calculated)
   - User location indicator (blue dot)
   - Zoom controls
   - Compass
   - Center on location button

2. **Trip Selector** (top):
   - Dropdown to select active trip
   - "No trip selected" state

3. **Map Controls** (floating buttons):
   - Search location
   - Add waypoint at current location
   - Center on trip
   - Toggle route visibility
   - Toggle satellite/map view

4. **Bottom Panel** (collapsible):
   - When waypoint selected: Waypoint info
   - When route shown: Route overview
   - Drag handle to expand/collapse

**Interactions**:
- Tap marker → Show waypoint info in bottom panel
- Long press map → Add waypoint at location (if trip selected)
- Tap bottom panel → Navigate to detail screen
- Drag map → Free exploration

**Bottom Sheet States**:
- **Collapsed**: Just waypoint name and type
- **Expanded**: Full waypoint details with actions
- **Route Overview**: Total distance, duration, waypoints list

**Navigation**:
- Tap "View Details" in bottom sheet → Waypoint Detail Screen
- Tap "Add Waypoint" → Add Waypoint Screen (modal)
- Tap search → Location Search Screen (modal)

---

#### Location Search Screen (Modal)
**Purpose**: Search for locations to add as waypoints
**Components**:
- Search bar with autocomplete
- Recent searches
- Suggested locations (camping spots, POIs)
- Search results list
- Map preview for selected result

**Actions**:
- Select result → Show on map with "Add as Waypoint" button
- Add as waypoint → Returns to map with new marker

---

### 4. Plan Tab - Trip Planning Tools

#### Active Trip Planning Screen
**Purpose**: Planning tools for the selected active trip
**Sections**:
1. **Trip Overview**:
   - Selected trip name
   - Total metrics (distance, duration, waypoints)

2. **Timeline View**:
   - Day-by-day breakdown
   - Drive time per day
   - Overnight locations
   - Activities scheduled

3. **Planning Tools**:
   - Optimize Route button
   - Adjust Schedule button
   - Set Preferences button

4. **Warnings/Suggestions**:
   - Alerts for long driving days
   - Suggestions for rest stops
   - Weather warnings (future)

**Navigation**:
- Tap optimize → Optimize Route Screen
- Tap adjust schedule → Adjust Schedule Screen
- Tap preferences → Set Preferences Screen
- Tap day → Day Detail View (expanded)

---

#### No Active Trip Screen
**Purpose**: Prompt when no trip is selected for planning
**Components**:
- Illustration
- "Select a Trip to Plan" message
- Trip selector dropdown
- "Create New Trip" button

---

#### Optimize Route Screen
**Purpose**: Calculate optimal waypoint order
**Components**:
- Current route preview
- Optimization options (shortest distance, shortest time, balanced)
- "Calculate Optimal Route" button
- Before/after comparison
- Accept/reject options

---

#### Adjust Schedule Screen
**Purpose**: Modify arrival/departure times
**Components**:
- Timeline editor
- Drag-to-adjust date/time pickers
- Automatic recalculation of dependent dates
- Warning indicators for conflicts

---

#### Set Preferences Screen
**Purpose**: Configure trip planning parameters
**Sections**:
1. **Driving Preferences**:
   - Max daily driving distance
   - Max daily driving time
   - Preferred driving speed

2. **Route Preferences**:
   - Avoid tolls
   - Avoid highways
   - Prefer scenic routes

3. **Rest Stop Settings**:
   - Include rest stops
   - Rest stop interval

---

### 5. Settings Tab - App Configuration

#### Settings Screen
**Purpose**: App-wide settings and configuration
**Sections**:
1. **General**:
   - Units (metric/imperial)
   - Language
   - Theme (light/dark/system)

2. **Map**:
   - Default map style
   - Mapbox API key configuration

3. **Trip Defaults**:
   - Default driving preferences
   - Default waypoint stay duration

4. **Data**:
   - Export data
   - Import data
   - Clear cache
   - Delete all data

5. **About**:
   - App version
   - Licenses
   - Privacy policy (future)
   - Terms of service (future)

6. **Support**:
   - Help & FAQ
   - Send feedback
   - Report a bug

**Navigation**:
- Tap section → Respective detail screen
- Tap export/import → Data Management Screen

---

## Navigation Flows

### Flow 1: Create New Trip
```
Trip List Screen
  → [Tap FAB] → Create Trip Screen (Modal)
    → Enter trip details
    → [Save] → Trip Detail Screen (new trip)
      → [Add Waypoint] → Add Waypoint Screen (Modal)
        → Search/select location
        → [Add] → Trip Detail Screen (updated)
```

### Flow 2: View Trip on Map
```
Trip List Screen
  → [Tap Trip] → Trip Detail Screen
    → [Tap Map Preview] → Map Tab
      → Interactive Map Screen (centered on trip route)
```

### Flow 3: Plan Route
```
Home Tab → Trip Detail Screen
  → [Calculate Route] → Map Tab
    → Shows calculated route
    → [Optional] Optimize → Optimize Route Screen
      → [Accept] → Returns to Map with optimized route
```

### Flow 4: Add Activity to Waypoint
```
Trip Detail Screen
  → [Tap Waypoint] → Waypoint Detail Screen
    → [Add Activity] → Add Activity Screen (Modal)
      → Enter activity details
      → [Save] → Waypoint Detail Screen (updated)
```

### Flow 5: Quick Location Marking
```
Map Tab → Interactive Map Screen
  → [Long Press] → Context Menu
    → "Add Waypoint Here"
    → Add Waypoint Screen (Modal, pre-filled with location)
      → [Save] → Map Screen (new marker added)
```

---

## Modal Workflows

### Create/Edit Trip Modal
**Fields**:
- Trip name (required)
- Description (optional)
- Start date (required)
- End date (required)
- Status selection

**Actions**:
- Cancel (dismisses modal)
- Save (validates and saves, then dismisses)

---

### Add/Edit Waypoint Modal
**Fields**:
- Name (required)
- Type (required: overnight, POI, transit)
- Location (latitude/longitude or search)
- Address (auto-populated from geocoding)
- Arrival date (optional)
- Departure date (optional)
- Stay duration (for overnight stays)
- Description (optional)

**Actions**:
- Cancel
- Save
- Delete (if editing)

---

### Add/Edit Activity Modal
**Fields**:
- Name (required)
- Description (optional)
- Category (required)
- Duration (optional)
- Cost (optional)
- Priority (required)
- Notes (optional)

**Actions**:
- Cancel
- Save
- Delete (if editing)

---

## Navigation Implementation

### Route Configuration (Flutter)

```dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => OnboardingFlow(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => TripListScreen(),
          routes: [
            GoRoute(
              path: 'trip/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return TripDetailScreen(tripId: id);
              },
              routes: [
                GoRoute(
                  path: 'waypoint/:waypointId',
                  builder: (context, state) {
                    final id = state.pathParameters['waypointId']!;
                    return WaypointDetailScreen(waypointId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/map',
          builder: (context, state) => InteractiveMapScreen(),
        ),
        GoRoute(
          path: '/plan',
          builder: (context, state) => PlanningScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => SettingsScreen(),
        ),
      ],
    ),
  ],
);
```

---

## Bottom Navigation Bar Configuration

```dart
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.map),
      label: 'Map',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.route),
      label: 'Plan',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ],
  currentIndex: _selectedIndex,
  onTap: _onItemTapped,
)
```

---

## Deep Linking

### Supported Deep Links

| Deep Link | Destination | Use Case |
|-----------|-------------|----------|
| `vanvoyage://trip/{id}` | Trip Detail Screen | Share specific trip |
| `vanvoyage://waypoint/{id}` | Waypoint Detail Screen | Share location |
| `vanvoyage://map?lat={lat}&lng={lng}` | Map Screen | External location link |
| `vanvoyage://create-trip` | Create Trip Screen | Quick trip creation |

---

## Gesture Navigation

### Supported Gestures
- **Swipe right**: Go back (when applicable)
- **Long press**: Context menu
- **Pinch**: Zoom on map
- **Double tap**: Zoom in on map
- **Drag**: Pan map or reorder list items
- **Pull down**: Refresh list (when applicable)

---

## Accessibility Considerations

### Navigation
- All screens support screen reader navigation
- Semantic labels for all interactive elements
- Logical focus order

### Keyboard Navigation (Web/Desktop)
- Tab through interactive elements
- Enter to activate
- Escape to dismiss modals
- Arrow keys for list navigation

---

## Transition Animations

### Screen Transitions
- **Push**: Slide from right (default)
- **Modal**: Slide up from bottom
- **Bottom Sheet**: Slide up with backdrop
- **Tab Switch**: Cross-fade (no slide)

### Element Transitions
- **Shared Element**: Hero animations for images and maps
- **List Items**: Staggered fade-in on load
- **Cards**: Lift on tap (elevation change)

---

## Error States & Edge Cases

### No Network
- Show cached data
- Disable route calculation
- Show offline indicator

### Empty States
- Illustrative graphics with helpful text
- Clear call-to-action buttons
- "Getting Started" hints

### Loading States
- Skeleton loaders for content
- Progress indicators for long operations
- Optimistic UI updates where possible

---

## Future Navigation Enhancements

### Phase 2
- **Split View** (tablet/desktop): Master-detail layout
- **Multi-window** support
- **Floating panels**: Overlay panels on map

### Phase 3
- **Collaborative Editing**: Real-time trip sharing
- **Notifications**: Navigate to specific content from notifications
- **Widgets**: Quick access from home screen widgets

---

## Navigation Testing Strategy

### Unit Tests
- Route parsing and parameter extraction
- Deep link handling
- Navigation state management

### Widget Tests
- Bottom navigation bar switching
- Back button behavior
- Modal dismissal

### Integration Tests
- Complete user journeys
- Navigation state persistence
- Deep link end-to-end flows

---

## Screen Mockup References

For detailed UI mockups and designs, refer to:
- `/docs/designs/wireframes/` (to be created)
- `/docs/designs/mockups/` (to be created)
- Figma design link: [To be added]

---

## Navigation Best Practices

1. **Consistent Patterns**: Use same navigation patterns throughout app
2. **Clear Hierarchy**: Users should always know where they are
3. **Back Button**: Always respect system back button behavior
4. **State Preservation**: Preserve navigation state across app restarts
5. **Performance**: Lazy load screens and dispose properly
6. **Feedback**: Provide visual feedback for navigation actions
7. **Accessibility**: Test with screen readers and keyboard navigation
