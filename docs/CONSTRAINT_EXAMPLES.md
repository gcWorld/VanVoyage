# Travel Constraint Validation Examples

This document provides examples of different constraint violations and what warnings/errors users will see.

## Example 1: Safe and Recommended Values (No Violations)

**User Settings:**
- Max Daily Distance: 400 km
- Max Daily Driving Time: 4 hours (240 minutes)
- Preferred Speed: 80 km/h
- Include Rest Stops: Yes
- Rest Stop Interval: 2 hours (120 minutes)

**Result:** ✅ No warnings or errors

## Example 2: Below Recommended Range (Warning)

**User Settings:**
- Max Daily Distance: 200 km (below 300 km recommended minimum)
- Max Daily Driving Time: 2 hours (120 minutes)
- Preferred Speed: 80 km/h
- Include Rest Stops: Yes
- Rest Stop Interval: 2 hours

**Result:** ⚠️ Warning displayed

**Warning Message:**
```
⚠️ Daily distance of 200 km is below recommended range. 
   Consider 300-500 km per day.
   Expected: 300-500 km
```

## Example 3: Above Recommended Range (Warning)

**User Settings:**
- Max Daily Distance: 600 km (above 500 km recommended maximum)
- Max Daily Driving Time: 7 hours (420 minutes)
- Preferred Speed: 90 km/h
- Include Rest Stops: Yes
- Rest Stop Interval: 2.5 hours

**Result:** ⚠️ Warning displayed

**Warning Message:**
```
⚠️ Daily distance of 600 km is above recommended range. 
   Consider 300-500 km per day for a comfortable trip.
   Expected: 300-500 km

⚠️ Daily driving time of 7.0 hours is above recommended range. 
   Consider 3.0-6.0 hours per day to avoid driver fatigue.
   Expected: 180-360 minutes
```

## Example 4: Extreme Values (Error)

**User Settings:**
- Max Daily Distance: 1200 km (exceeds 1000 km maximum)
- Max Daily Driving Time: 15 hours (900 minutes, exceeds 720 min maximum)
- Preferred Speed: 80 km/h
- Include Rest Stops: Yes
- Rest Stop Interval: 2 hours

**Result:** ❌ Errors displayed

**Error Messages:**
```
❌ Daily distance of 1200 km exceeds safe limit. 
   Maximum is 1000 km.
   Expected: <= 1000 km

❌ Daily driving time of 15.0 hours exceeds safe limit. 
   Maximum is 12.0 hours to avoid fatigue.
   Expected: <= 720 minutes
```

## Example 5: Inconsistent Values (Warning)

**User Settings:**
- Max Daily Distance: 600 km
- Max Daily Driving Time: 4 hours (240 minutes)
- Preferred Speed: 80 km/h
- Include Rest Stops: Yes
- Rest Stop Interval: 2 hours

**Result:** ⚠️ Consistency warning

**Warning Message:**
```
⚠️ Your max daily distance (600 km) may be unreachable with 4.0 hours 
   of driving at 80 km/h. Maximum achievable is approximately 320 km.
   Expected: <= 320 km
```

**Explanation:** At 80 km/h for 4 hours, you can only travel 320 km, so setting a max of 600 km is unrealistic.

## Example 6: Rest Interval Issues (Error)

**User Settings:**
- Max Daily Distance: 400 km
- Max Daily Driving Time: 3 hours (180 minutes)
- Preferred Speed: 80 km/h
- Include Rest Stops: Yes
- Rest Stop Interval: 7 hours (420 minutes, exceeds 360 min maximum)

**Result:** ❌ Error displayed

**Warning Message:**
```
❌ Rest interval of 7.0 hours is too long. Take breaks every 6.0 hours 
   or less to stay alert.
   Expected: <= 360 minutes

⚠️ Rest interval (7.0 hrs) should be less than daily driving time (3.0 hrs).
   Expected: < 180 minutes
```

## Example 7: Extremely Slow Speed (Warning)

**User Settings:**
- Max Daily Distance: 300 km
- Max Daily Driving Time: 4 hours
- Preferred Speed: 35 km/h (below 40 km/h minimum)
- Include Rest Stops: Yes
- Rest Stop Interval: 2 hours

**Result:** ⚠️ Warning displayed

**Warning Message:**
```
⚠️ Driving speed of 35 km/h is very slow. This may result in 
   unrealistic travel time estimates.
   Expected: >= 40 km/h
```

## Example 8: Extremely Fast Speed (Warning)

**User Settings:**
- Max Daily Distance: 400 km
- Max Daily Driving Time: 4 hours
- Preferred Speed: 140 km/h (above 130 km/h maximum)
- Include Rest Stops: Yes
- Rest Stop Interval: 2 hours

**Result:** ⚠️ Warning displayed

**Warning Message:**
```
⚠️ Driving speed of 140 km/h is very high. Consider local speed 
   limits and road conditions.
   Expected: <= 130 km/h
```

## Visual Representation in UI

### Warning Card (Orange)
```
┌─────────────────────────────────────────────────┐
│ ⚠️  Daily distance of 600 km is above          │
│     recommended range. Consider 300-500 km      │
│     per day for a comfortable trip.             │
│     Expected: 300-500 km                        │
└─────────────────────────────────────────────────┘
```

### Error Card (Red)
```
┌─────────────────────────────────────────────────┐
│ ❌  Daily driving time of 13.0 hours exceeds    │
│     safe limit. Maximum is 12.0 hours to avoid  │
│     fatigue.                                    │
│     Expected: <= 720 minutes                    │
└─────────────────────────────────────────────────┘
```

## Testing the System

To see the constraint system in action:

1. Open the trip planning screen
2. Navigate to Step 3: Travel Constraints
3. Adjust the sliders to extreme values:
   - Drag Max Daily Distance to minimum (100 km) or maximum (800 km)
   - Drag Max Daily Time to minimum (1 hour) or maximum (10 hours)
   - Drag Speed to extremes
   - Adjust rest intervals

4. Observe:
   - Warning cards appear immediately as you adjust values
   - Colors change based on severity (orange warnings, red errors)
   - Messages update dynamically
   - Multiple warnings can appear simultaneously
   - Consistency warnings appear when settings conflict

## Severity Guide

| Severity | Color | Icon | Meaning | Action |
|----------|-------|------|---------|--------|
| Error | Red | ❌ | Value outside safe limits | Strongly recommend changing |
| Warning | Orange | ⚠️ | Value outside recommended range | Consider adjusting |
| Info | Blue | ℹ️ | Informational message | No action needed |

## Validation Timing

- ✅ Real-time: Warnings update as you move sliders
- ✅ Immediate: No need to click save to see validation
- ✅ Dynamic: Warnings appear and disappear based on current values
- ✅ Non-blocking: You can still save preferences with warnings
