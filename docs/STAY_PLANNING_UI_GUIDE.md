# Stay Planning UI - Visual Guide

This document provides visual representations of the Stay Planning and Itinerary features UI.

## 1. Waypoint Detail Screen - View Mode

```
┌─────────────────────────────────────┐
│ ◀ Waypoint Details           ✏️    │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ 🏨  Grand Canyon Lodge          │ │
│ │     Overnight Stay              │ │
│ │                                 │ │
│ │ Beautiful lodge with amazing    │ │
│ │ views of the canyon rim         │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📍 Location                     │ │
│ │                                 │ │
│ │ 123 Rim Drive                   │ │
│ │ Grand Canyon Village, AZ        │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🏨 Stay Details                 │ │
│ │                                 │ │
│ │ 📅 Arrival: Jun 15, 2024        │ │
│ │ 📆 Departure: Jun 18, 2024      │ │
│ │ 🌙 Duration: 3 nights           │ │
│ └─────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

## 2. Waypoint Detail Screen - Edit Mode

```
┌─────────────────────────────────────┐
│ ◀ Edit Waypoint              ✖️     │
├─────────────────────────────────────┤
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🏷️  Waypoint Name___________   │ │
│ │     Grand Canyon Lodge          │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📝  Description_____________    │ │
│ │     Beautiful lodge with        │ │
│ │     amazing views of the        │ │
│ │     canyon rim                  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Waypoint Type                   │ │
│ │                                 │ │
│ │ [  Stay  ] [  Visit ] [ Transit]│ │
│ │    🏨         📍         🚗      │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Stay Details                    │ │
│ │                                 │ │
│ │ ┌─────────────────────────────┐ │ │
│ │ │ 📅 Arrival Date   ✏️        │ │ │
│ │ │    Jun 15, 2024             │ │ │
│ │ └─────────────────────────────┘ │ │
│ │                                 │ │
│ │ ┌─────────────────────────────┐ │ │
│ │ │ 📆 Departure Date ✏️        │ │ │
│ │ │    Jun 18, 2024             │ │ │
│ │ └─────────────────────────────┘ │ │
│ │                                 │ │
│ │ ┌─────────────────────────────┐ │ │
│ │ │ 🌙 Stay Duration (nights)   │ │ │
│ │ │    3                        │ │ │
│ │ │    Auto-calculated          │ │ │
│ │ └─────────────────────────────┘ │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌───────────────────────────────┐   │
│ │      💾 Save Changes         │   │
│ └───────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

## 3. Trip Itinerary Timeline

```
┌─────────────────────────────────────┐
│ ◀ Trip Itinerary             🔄     │
├─────────────────────────────────────┤
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🎯 Summer Road Trip 2024        │ │
│ │ 📅 Jun 15, 2024 - Jun 22, 2024  │ │
│ │ ⏱️  8 days                       │ │
│ └─────────────────────────────────┘ │
│                                     │
│  ●─┐                                │
│  🏨│ ┌─────────────────────────┐   │
│    │ │ Grand Canyon Lodge      │   │
│  │ │ │ [  Stay  ]              │   │
│  │ │ │                         │   │
│  │ │ │ 📅 Jun 15 → 📆 Jun 18   │   │
│  │ │ │ 🌙 3 nights             │   │
│  │ └ └─────────────────────────┘   │
│  │                                  │
│  ●─┐                                │
│  📍│ ┌─────────────────────────┐   │
│    │ │ Horseshoe Bend          │   │
│  │ │ │ [ Visit  ]              │   │
│  │ │ │                         │   │
│  │ │ │ 📅 Jun 18               │   │
│  │ │ │ 🚗 45.3 km • 0.8 hrs    │   │
│  │ └ └─────────────────────────┘   │
│  │                                  │
│  ●─┐                                │
│  🏨│ ┌─────────────────────────┐   │
│    │ │ Zion National Park      │   │
│  │ │ │ [  Stay  ]              │   │
│  │ │ │                         │   │
│  │ │ │ 📅 Jun 18 → 📆 Jun 21   │   │
│  │ │ │ 🌙 3 nights             │   │
│  │ │ │ 🚗 190.5 km • 2.5 hrs   │   │
│  │ └ └─────────────────────────┘   │
│  │                                  │
│  ●                                  │
│  📍  ┌─────────────────────────┐   │
│      │ Bryce Canyon            │   │
│      │ [ Visit  ]              │   │
│      │                         │   │
│      │ 📅 Jun 21               │   │
│      │ 🚗 85.2 km • 1.2 hrs    │   │
│      └─────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

## 4. Trip Planning - Step 4: Review Itinerary

```
┌─────────────────────────────────────┐
│ ◀ Create Trip                       │
├─────────────────────────────────────┤
│                                     │
│ Steps:                              │
│ ✓ 1. Trip Details                   │
│ ✓ 2. Add Destinations (4 added)     │
│ ✓ 3. Travel Constraints             │
│ ► 4. Review Itinerary               │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Configure stays and review      │ │
│ │ your complete timeline          │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Timeline view - see above]         │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Tap any waypoint to configure   │ │
│ │ stay details, dates, and notes  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌───────────────────────────────┐   │
│ │   ✓ Finish Planning          │   │
│ └───────────────────────────────┘   │
│                                     │
│ [◀ Back]          [Continue ▶]      │
└─────────────────────────────────────┘
```

## 5. Date Picker Dialog

```
┌─────────────────────────────────────┐
│        Select Arrival Date          │
├─────────────────────────────────────┤
│                                     │
│     June 2024                       │
│   ◀                          ▶      │
│                                     │
│  S   M   T   W   T   F   S         │
│                      1               │
│  2   3   4   5   6   7   8         │
│  9  10  11  12  13  14 (15)        │
│ 16  17  18  19  20  21  22         │
│ 23  24  25  26  27  28  29         │
│ 30                                  │
│                                     │
│         [CANCEL]  [OK]              │
└─────────────────────────────────────┘
```

## UI Features Highlighted

### Visual Design Elements

1. **Timeline Indicators**
   - Colored circles for waypoint types:
     - 🏨 Blue for Overnight Stays
     - 📍 Green for Points of Interest
     - 🚗 Orange for Transit Points
   - Connected lines showing route flow

2. **Stay Information Cards**
   - Arrival/Departure dates prominently displayed
   - Stay duration automatically calculated
   - Distance and driving time from previous waypoint

3. **Type Chips**
   - Visual badges for waypoint types
   - Icons for quick recognition
   - Color-coded backgrounds

4. **Date Pickers**
   - Standard Material Design date picker
   - Calendar view for easy selection
   - Validation feedback

### Interaction Patterns

1. **Edit Mode Toggle**
   - Pencil icon in app bar to enter edit mode
   - Close icon to cancel and reset changes
   - Save button to persist changes

2. **Date Selection**
   - Tap date fields to open picker
   - Visual feedback on selected dates
   - Auto-calculation of duration

3. **Waypoint Navigation**
   - Tap any waypoint in timeline to edit
   - Returns to timeline after saving
   - Automatic data refresh

### Validation & Feedback

1. **Inline Validation**
   - Red borders for invalid fields
   - Helper text explaining requirements
   - Snackbar messages for success/errors

2. **Business Rule Enforcement**
   - Departure must be after arrival
   - Overnight stays require duration >= 1
   - Coordinates must be valid

3. **User Guidance**
   - Empty states with helpful messages
   - Tooltips on interactive elements
   - Context-appropriate help text

## Color Scheme

Based on Material 3 with deep orange seed color:

- **Primary**: Deep Orange
- **Secondary**: Orange/Amber tones
- **Success**: Green for completed items
- **Info**: Blue for informational content
- **Warning**: Orange/Yellow for attention
- **Error**: Red for validation errors

### Waypoint Type Colors

- **Overnight Stay**: Blue (#2196F3)
- **Point of Interest**: Green (#4CAF50)
- **Transit Point**: Orange (#FF9800)

## Responsive Design

The UI is designed to work on various screen sizes:

- **Mobile**: Single column layout, full-width cards
- **Tablet**: Optimized spacing, larger touch targets
- **Desktop**: Centered content with max-width constraints

## Accessibility

- **Icons**: Always paired with text labels
- **Colors**: Sufficient contrast ratios
- **Touch Targets**: Minimum 48x48 dp
- **Screen Readers**: Semantic HTML and ARIA labels
- **Keyboard**: Full keyboard navigation support

## Animation & Transitions

- **Screen Transitions**: Material motion for navigation
- **List Items**: Slide animation for timeline
- **Buttons**: Ripple effects on tap
- **Loading**: Circular progress indicators
- **Snackbars**: Slide up from bottom

## Example User Flows

### Flow 1: Adding a Stay to a Waypoint

1. User creates trip and adds waypoints
2. Navigate to Step 4: Review Itinerary
3. Tap on a waypoint in the timeline
4. Waypoint detail screen opens
5. Tap edit button (pencil icon)
6. Change type to "Stay"
7. Tap arrival date field → Select date
8. Tap departure date field → Select date
9. Duration auto-calculates (or enter manually)
10. Tap "Save Changes"
11. Return to timeline with updated info

### Flow 2: Viewing Complete Itinerary

1. Open trip from home screen
2. Navigate to itinerary view
3. Scroll timeline to see all waypoints
4. View stay details inline
5. See driving distances and times
6. Tap waypoint for full details
7. Use refresh to reload data

### Flow 3: Planning Multi-Day Trip

1. Start trip planning flow
2. Enter trip name and dates (Jun 15 - Jun 22)
3. Add multiple waypoints via map
4. Set travel preferences
5. Move to itinerary review (Step 4)
6. Configure first waypoint as overnight stay
   - Set arrival: Jun 15
   - Set departure: Jun 18
   - Duration: 3 nights
7. Configure second waypoint as POI
   - Set visit date: Jun 18
8. Configure third waypoint as overnight stay
   - Set arrival: Jun 18
   - Set departure: Jun 21
   - Duration: 3 nights
9. Review complete timeline
10. Finish planning

## Tips for Developers

### Customizing Colors

To change waypoint type colors, modify the `_getWaypointColor` method in `TripItineraryTimeline`:

```dart
Color _getWaypointColor(BuildContext context, Waypoint waypoint) {
  switch (waypoint.waypointType) {
    case WaypointType.overnightStay:
      return Colors.blue;  // Change this
    case WaypointType.poi:
      return Colors.green;  // Change this
    case WaypointType.transit:
      return Colors.orange;  // Change this
  }
}
```

### Customizing Timeline Layout

The timeline uses `IntrinsicHeight` and `Row` for layout. To adjust spacing:

```dart
// In _buildTimelineItem method
SizedBox(
  width: 60,  // Adjust timeline indicator width
  child: Column(...),
)
```

### Adding New Date Fields

To add time of day to dates:

1. Change `DateTime?` fields to include time
2. Add `TimeOfDay` picker alongside date picker
3. Combine date and time in save logic
4. Update display format to show time

## Future Enhancements

Potential UI improvements:

1. **Calendar Grid View**: Alternative visualization as a calendar
2. **Map Integration**: Show waypoints on map in timeline
3. **Photos**: Add photo thumbnails to waypoints
4. **Weather**: Show weather icons for stay dates
5. **Cost Tracking**: Add budget information to stays
6. **Activities**: Expandable section for activities per stay
7. **Notes**: Rich text editor for detailed notes
8. **Sharing**: Export/share itinerary as PDF or link
9. **Templates**: Save common stay patterns as templates
10. **Drag & Drop**: Reorder waypoints by dragging in timeline

---

This visual guide provides a comprehensive overview of the Stay Planning UI. For implementation details, see [STAY_PLANNING_FEATURES.md](STAY_PLANNING_FEATURES.md).
