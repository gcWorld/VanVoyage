# Linting Fixes Summary

## Issues Resolved

### 1. Unnecessary Braces in String Interpolation
**Location**: `lib/domain/services/route_service.dart:191`

**Before**:
```dart
return '$totalDurationHours hr ${remainingMinutes} min';
```

**After**:
```dart
return '$totalDurationHours hr $remainingMinutes min';
```

**Reason**: When interpolating a simple variable without calling methods or accessing properties, braces are unnecessary.

---

### 2. Unused Local Variable
**Location**: `lib/presentation/widgets/map_route_layer.dart:174`

**Before**:
```dart
final bounds = CoordinateBounds(
  southwest: southwest,
  northeast: northeast,
  infiniteBounds: false,
);
```

**After**:
```dart
// Note: Mapbox Flutter SDK doesn't support direct bounds fitting yet
// Using center point instead
```

**Reason**: The `bounds` variable was created but never used. Removed it and added a comment explaining why bounds fitting isn't implemented.

---

### 3. Cast From Null Always Fails
**Location**: `test/unit/domain/services/route_service_test.dart:32`

**Before**:
```dart
return _routes.values.firstWhere(
  (r) => r.fromWaypointId == fromWaypointId && r.toWaypointId == toWaypointId,
  orElse: () => null as Route,
);
```

**After**:
```dart
try {
  return _routes.values.firstWhere(
    (r) => r.fromWaypointId == fromWaypointId && r.toWaypointId == toWaypointId,
  );
} catch (e) {
  return null;
}
```

**Reason**: Using `null as Route` always throws an exception. Changed to use try-catch to properly handle the case when no route is found.

---

### 4. MockMapboxService Missing Routing Profile Parameters
**Location**: `test/unit/domain/services/route_service_test.dart:60-92`

**Issue**: MockMapboxService methods didn't include the new `profile` parameter added to the real MapboxService API.

**Before**:
```dart
Future<MapboxRoute?> calculateRoute(
  double startLat,
  double startLng,
  double endLat,
  double endLng, {
  bool alternatives = false,
}) async {
  // ...
}

Future<List<MapboxRoute>> calculateRouteWithAlternatives(
  double startLat,
  double startLng,
  double endLat,
  double endLng,
) async {
  // ...
}
```

**After**:
```dart
Future<MapboxRoute?> calculateRoute(
  double startLat,
  double startLng,
  double endLat,
  double endLng, {
  bool alternatives = false,
  RoutingProfile profile = RoutingProfile.driving,
}) async {
  // ...
}

Future<List<MapboxRoute>> calculateRouteWithAlternatives(
  double startLat,
  double startLng,
  double endLat,
  double endLng, {
  RoutingProfile profile = RoutingProfile.driving,
}) async {
  // ...
}
```

**Reason**: Mock service must match the interface of the real service to avoid compilation errors in tests.

---

## Verification

All issues have been resolved:
- ✅ No unnecessary braces
- ✅ No unused variables
- ✅ Proper null handling without casting
- ✅ Mock service matches real API signature

## Testing

The test suite should now run without errors:
```bash
flutter test test/unit/domain/services/route_service_test.dart
```

All tests should pass with the updated mock service.

---

**Fixed in Commit**: f4874fc
**Date**: 2025-10-14
