# Travel Constraints and Restrictions Handler

## Overview

The Travel Constraints system provides comprehensive validation and warnings for trip planning preferences to ensure safe and realistic travel plans. It helps users make informed decisions about their daily driving distances, time limits, and rest requirements.

## Features

### 1. Constraint Model (`TravelConstraint`)

Defines safe and recommended ranges for travel parameters:

- **Daily Distance Limits**
  - Minimum: 50 km
  - Maximum: 1000 km
  - Recommended: 300-500 km

- **Daily Driving Time**
  - Minimum: 30 minutes
  - Maximum: 720 minutes (12 hours)
  - Recommended: 180-360 minutes (3-6 hours)

- **Driving Speed**
  - Minimum: 40 km/h
  - Maximum: 130 km/h

- **Rest Stop Intervals**
  - Minimum: 30 minutes
  - Maximum: 360 minutes (6 hours)
  - Recommended: 120-180 minutes (2-3 hours)

### 2. Validation Service (`TravelConstraintValidator`)

Validates trip preferences against constraints and returns a list of violations with three severity levels:

- **Error**: Value is outside safe limits (e.g., driving 12+ hours per day)
- **Warning**: Value is outside recommended range but acceptable (e.g., 600 km/day)
- **Info**: Informational messages (currently not used but available)

#### Validation Rules

1. **Daily Distance Validation**
   - Checks if distance is within safe limits
   - Warns if outside recommended range
   - Ensures realistic trip planning

2. **Daily Time Validation**
   - Prevents excessive driving that could lead to fatigue
   - Warns about unusually short or long driving days
   - Considers driver safety

3. **Speed Validation**
   - Ensures speed is realistic for travel time calculations
   - Warns about very slow or very fast speeds
   - Considers typical road conditions

4. **Rest Stop Validation**
   - Validates rest intervals when enabled
   - Prevents too-frequent stops that waste time
   - Enforces maximum intervals to maintain alertness

5. **Consistency Validation**
   - Checks if distance is achievable with given time and speed
   - Validates rest interval against daily driving time
   - Identifies conflicting preferences

### 3. Violation Model (`ConstraintViolation`)

Represents a single constraint violation with:
- Field name (which preference is violated)
- Human-readable message
- Severity level (error/warning/info)
- Current value that caused the violation
- Expected/recommended value

### 4. UI Integration

The `TripPreferencesForm` widget now includes:

#### Real-time Validation
- Validates preferences as user adjusts sliders and switches
- Updates warnings dynamically
- No need to save to see validation results

#### Visual Warning System
- Color-coded warning cards:
  - **Red** (error container): Critical safety issues
  - **Orange**: Warnings about recommended ranges
  - **Blue**: Informational messages

- Icons for quick recognition:
  - ⚠️ Error icon: Critical issues
  - ⚠️ Warning icon: Recommendations
  - ℹ️ Info icon: Informational

#### Warning Card Components
Each warning displays:
- Severity icon and color
- Clear explanation of the issue
- Expected or recommended value range
- Current value that triggered the warning

## Usage Example

```dart
// Create validator with default constraints
final validator = const TravelConstraintValidator();

// Create trip preferences
final preferences = TripPreferences.create(
  tripId: 'trip123',
  maxDailyDrivingDistance: 600, // Above recommended
  maxDailyDrivingTime: 240,      // 4 hours
  preferredDrivingSpeed: 80,     // 80 km/h
);

// Validate preferences
final violations = validator.validate(preferences);

// Check for errors and warnings
if (validator.hasErrors(violations)) {
  print('Critical issues found!');
}

if (validator.hasWarnings(violations)) {
  print('Recommendations available');
}

// Get specific severity violations
final errors = validator.getViolationsBySeverity(
  violations, 
  ViolationSeverity.error
);

final warnings = validator.getViolationsBySeverity(
  violations, 
  ViolationSeverity.warning
);
```

## Design Decisions

### Why Separate Constraints from Preferences?

1. **Single Responsibility**: Preferences store user choices, constraints define rules
2. **Flexibility**: Constraints can be customized for different regions/regulations
3. **Testability**: Validation logic is isolated and easy to test
4. **Maintainability**: Rules can be updated without changing core entities

### Why Real-time Validation?

1. **Immediate Feedback**: Users see issues as they adjust values
2. **Better UX**: No surprise errors after clicking save
3. **Learning Tool**: Helps users understand safe travel practices
4. **Prevents Errors**: Catches issues before they're persisted

### Why Three Severity Levels?

1. **Error**: Absolute limits for safety (not overridable)
2. **Warning**: Recommendations that can be ignored if user prefers
3. **Info**: Educational information without judgment

## Testing

### Unit Tests (TravelConstraintValidator)

15 comprehensive test cases covering:
- Daily distance validation (5 tests)
- Daily time validation (4 tests)
- Speed validation (3 tests)
- Rest interval validation (4 tests)
- Consistency validation (2 tests)
- Helper methods (3 tests)

### Widget Tests (TripPreferencesForm)

5 additional test cases for:
- Warning display for out-of-range values
- Error display for extreme values
- Dynamic warning updates
- Consistency warnings
- UI rendering with violations

## Future Enhancements

1. **Customizable Constraints**
   - Allow users to adjust constraint levels
   - Region-specific constraint profiles (EU, US, etc.)
   - Save custom constraint sets

2. **Historical Data**
   - Learn from past trips
   - Suggest personalized constraints
   - Track violation patterns

3. **Route-Specific Validation**
   - Consider terrain difficulty
   - Account for weather conditions
   - Adjust for vehicle type

4. **Multi-Driver Support**
   - Different constraints per driver
   - Team driving considerations
   - Rotation schedules

5. **Accessibility**
   - Screen reader support for warnings
   - High contrast warning colors
   - Keyboard navigation for violations

## Files Changed/Added

### New Files
- `lib/domain/entities/travel_constraint.dart` - Constraint model
- `lib/domain/entities/constraint_violation.dart` - Violation model
- `lib/domain/services/travel_constraint_validator.dart` - Validation service
- `test/unit/domain/services/travel_constraint_validator_test.dart` - Unit tests
- `docs/TRAVEL_CONSTRAINTS.md` - This documentation

### Modified Files
- `lib/presentation/widgets/forms/trip_preferences_form.dart` - Added validation UI

## Summary

The Travel Constraints system provides a robust framework for validating trip preferences with:
- ✅ Comprehensive constraint definitions
- ✅ Multi-level violation severity
- ✅ Real-time validation
- ✅ Clear visual warnings
- ✅ Extensive test coverage
- ✅ Consistency checking
- ✅ User-friendly messages

This ensures users create safe, realistic trip plans while maintaining flexibility for their specific needs.
