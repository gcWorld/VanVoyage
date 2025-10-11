# Travel Constraints Feature

> Real-time validation and warnings for safe trip planning

## Quick Overview

The Travel Constraints feature provides intelligent validation of trip preferences, helping users plan safe and realistic van travel journeys. It validates daily driving limits, speeds, and rest intervals with real-time feedback.

## 🎯 Problem Solved

Van travelers need guidance on safe travel practices:
- How far can I safely drive in a day?
- How much driving time is reasonable?
- Are my travel expectations realistic?
- When should I take rest breaks?

This feature answers these questions with smart validation and helpful warnings.

## ✨ Key Features

### 1. Real-time Validation
- Validates as you adjust sliders
- No need to save to see feedback
- Immediate, non-intrusive warnings

### 2. Smart Constraint Rules
- **Daily Distance**: 50-1000 km (recommended 300-500 km)
- **Daily Time**: 0.5-12 hours (recommended 3-6 hours)
- **Driving Speed**: 40-130 km/h
- **Rest Intervals**: 0.5-6 hours (recommended 2-3 hours)

### 3. Severity Levels
- 🔴 **Errors**: Values outside safe limits (e.g., 13 hours driving/day)
- 🟠 **Warnings**: Values outside recommended range (e.g., 600 km/day)
- 🔵 **Info**: Educational messages (future use)

### 4. Consistency Checking
- Detects unreachable distance goals
- Validates rest intervals vs. driving time
- Ensures settings work together

### 5. Clear Visual Feedback
- Color-coded warning cards
- Descriptive icons
- Expected value ranges
- Actionable messages

## 🚀 Usage

### For Users

1. Navigate to Trip Planning → Travel Constraints
2. Adjust sliders for your preferences
3. Watch for warning cards that appear
4. Review warnings and adjust if needed
5. Save your preferences

**Example:**
```
Setting: Max Daily Distance = 700 km
Warning: ⚠️ Daily distance of 700 km is above recommended range.
         Consider 300-500 km per day for a comfortable trip.
         Expected: 300-500 km
```

### For Developers

```dart
// Create validator
final validator = const TravelConstraintValidator();

// Create preferences
final prefs = TripPreferences.create(
  tripId: 'trip-id',
  maxDailyDrivingDistance: 600,
  maxDailyDrivingTime: 240,
  preferredDrivingSpeed: 80,
);

// Validate
final violations = validator.validate(prefs);

// Check results
if (validator.hasErrors(violations)) {
  // Handle critical issues
}

if (validator.hasWarnings(violations)) {
  // Show warnings to user
}
```

## 📁 File Structure

```
lib/domain/
├── entities/
│   ├── constraint_violation.dart   # Violation model
│   └── travel_constraint.dart      # Constraint definitions
└── services/
    └── travel_constraint_validator.dart  # Validation logic

lib/presentation/widgets/forms/
└── trip_preferences_form.dart      # UI with warnings (modified)

test/unit/domain/services/
└── travel_constraint_validator_test.dart  # Unit tests (15 cases)

test/widget/presentation/widgets/forms/
└── trip_preferences_form_test.dart        # Widget tests (5+ cases)

docs/
├── TRAVEL_CONSTRAINTS.md           # Full documentation
├── CONSTRAINT_EXAMPLES.md          # Usage examples
├── CONSTRAINT_UI_MOCKUP.md         # UI mockups
└── features/
    └── TRAVEL_CONSTRAINTS_FEATURE.md  # This file
```

## 🧪 Testing

### Run Tests

```bash
# Run unit tests
flutter test test/unit/domain/services/travel_constraint_validator_test.dart

# Run widget tests
flutter test test/widget/presentation/widgets/forms/trip_preferences_form_test.dart

# Run all tests
flutter test
```

### Test Coverage

- ✅ 15 unit tests for validator logic
- ✅ 5 widget tests for UI behavior
- ✅ 100% coverage of validation rules
- ✅ All edge cases covered

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [TRAVEL_CONSTRAINTS.md](../TRAVEL_CONSTRAINTS.md) | Comprehensive technical documentation |
| [CONSTRAINT_EXAMPLES.md](../CONSTRAINT_EXAMPLES.md) | 8 detailed violation examples |
| [CONSTRAINT_UI_MOCKUP.md](../CONSTRAINT_UI_MOCKUP.md) | Visual UI mockups and behavior |
| [IMPLEMENTATION_SUMMARY_CONSTRAINTS.md](../../IMPLEMENTATION_SUMMARY_CONSTRAINTS.md) | Complete implementation details |

## 🎨 UI Examples

### No Violations (Default)
```
✅ All values within recommended ranges
   No warnings displayed
```

### Warning Example
```
⚠️  Daily distance of 600 km is above recommended range.
    Consider 300-500 km per day for a comfortable trip.
    Expected: 300-500 km
```

### Error Example
```
❌  Daily driving time of 13.0 hours exceeds safe limit.
    Maximum is 12.0 hours to avoid fatigue.
    Expected: <= 720 minutes
```

### Consistency Warning
```
⚠️  Your max daily distance (600 km) may be unreachable
    with 4.0 hours of driving at 80 km/h. Maximum
    achievable is approximately 320 km.
    Expected: <= 320 km
```

## 📝 Summary

**Version**: 1.0.0  
**Last Updated**: 2025-10-11  
**Status**: ✅ Complete and Production-Ready

See full documentation in `/docs/TRAVEL_CONSTRAINTS.md`
