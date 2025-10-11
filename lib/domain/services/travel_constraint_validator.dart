import '../entities/constraint_violation.dart';
import '../entities/travel_constraint.dart';
import '../entities/trip_preferences.dart';

/// Service for validating travel preferences against constraints
class TravelConstraintValidator {
  final TravelConstraint constraints;

  const TravelConstraintValidator({
    TravelConstraint? constraints,
  }) : constraints = constraints ?? const TravelConstraint();

  /// Validates trip preferences and returns list of violations
  List<ConstraintViolation> validate(TripPreferences preferences) {
    final violations = <ConstraintViolation>[];

    // Validate daily distance
    violations.addAll(_validateDailyDistance(preferences.maxDailyDrivingDistance));

    // Validate daily time
    violations.addAll(_validateDailyTime(preferences.maxDailyDrivingTime));

    // Validate driving speed
    violations.addAll(_validateSpeed(preferences.preferredDrivingSpeed));

    // Validate rest stop interval if enabled
    if (preferences.includeRestStops && preferences.restStopInterval != null) {
      violations.addAll(_validateRestInterval(preferences.restStopInterval!));
    }

    // Check for conflicting preferences
    violations.addAll(_validateConsistency(preferences));

    return violations;
  }

  /// Validates maximum daily driving distance
  List<ConstraintViolation> _validateDailyDistance(int distance) {
    final violations = <ConstraintViolation>[];

    if (distance < constraints.minDailyDistance) {
      violations.add(ConstraintViolation.error(
        field: 'maxDailyDrivingDistance',
        message: 'Daily distance of $distance km is too low. Minimum is ${constraints.minDailyDistance} km.',
        currentValue: distance,
        expectedValue: '>= ${constraints.minDailyDistance} km',
      ));
    } else if (distance > constraints.maxDailyDistance) {
      violations.add(ConstraintViolation.error(
        field: 'maxDailyDrivingDistance',
        message: 'Daily distance of $distance km exceeds safe limit. Maximum is ${constraints.maxDailyDistance} km.',
        currentValue: distance,
        expectedValue: '<= ${constraints.maxDailyDistance} km',
      ));
    } else if (distance < constraints.recommendedMinDistance) {
      violations.add(ConstraintViolation.warning(
        field: 'maxDailyDrivingDistance',
        message: 'Daily distance of $distance km is below recommended range. Consider ${constraints.recommendedMinDistance}-${constraints.recommendedMaxDistance} km per day.',
        currentValue: distance,
        expectedValue: '${constraints.recommendedMinDistance}-${constraints.recommendedMaxDistance} km',
      ));
    } else if (distance > constraints.recommendedMaxDistance) {
      violations.add(ConstraintViolation.warning(
        field: 'maxDailyDrivingDistance',
        message: 'Daily distance of $distance km is above recommended range. Consider ${constraints.recommendedMinDistance}-${constraints.recommendedMaxDistance} km per day for a comfortable trip.',
        currentValue: distance,
        expectedValue: '${constraints.recommendedMinDistance}-${constraints.recommendedMaxDistance} km',
      ));
    }

    return violations;
  }

  /// Validates maximum daily driving time
  List<ConstraintViolation> _validateDailyTime(int timeInMinutes) {
    final violations = <ConstraintViolation>[];
    final hours = (timeInMinutes / 60).toStringAsFixed(1);

    if (timeInMinutes < constraints.minDailyTime) {
      violations.add(ConstraintViolation.error(
        field: 'maxDailyDrivingTime',
        message: 'Daily driving time of $hours hours is too short. Minimum is ${(constraints.minDailyTime / 60).toStringAsFixed(1)} hours.',
        currentValue: timeInMinutes,
        expectedValue: '>= ${constraints.minDailyTime} minutes',
      ));
    } else if (timeInMinutes > constraints.maxDailyTime) {
      violations.add(ConstraintViolation.error(
        field: 'maxDailyDrivingTime',
        message: 'Daily driving time of $hours hours exceeds safe limit. Maximum is ${(constraints.maxDailyTime / 60).toStringAsFixed(1)} hours to avoid fatigue.',
        currentValue: timeInMinutes,
        expectedValue: '<= ${constraints.maxDailyTime} minutes',
      ));
    } else if (timeInMinutes < constraints.recommendedMinTime) {
      violations.add(ConstraintViolation.warning(
        field: 'maxDailyDrivingTime',
        message: 'Daily driving time of $hours hours is below recommended range. Consider ${(constraints.recommendedMinTime / 60).toStringAsFixed(1)}-${(constraints.recommendedMaxTime / 60).toStringAsFixed(1)} hours per day.',
        currentValue: timeInMinutes,
        expectedValue: '${constraints.recommendedMinTime}-${constraints.recommendedMaxTime} minutes',
      ));
    } else if (timeInMinutes > constraints.recommendedMaxTime) {
      violations.add(ConstraintViolation.warning(
        field: 'maxDailyDrivingTime',
        message: 'Daily driving time of $hours hours is above recommended range. Consider ${(constraints.recommendedMinTime / 60).toStringAsFixed(1)}-${(constraints.recommendedMaxTime / 60).toStringAsFixed(1)} hours per day to avoid driver fatigue.',
        currentValue: timeInMinutes,
        expectedValue: '${constraints.recommendedMinTime}-${constraints.recommendedMaxTime} minutes',
      ));
    }

    return violations;
  }

  /// Validates preferred driving speed
  List<ConstraintViolation> _validateSpeed(int speed) {
    final violations = <ConstraintViolation>[];

    if (speed < constraints.minSpeed) {
      violations.add(ConstraintViolation.warning(
        field: 'preferredDrivingSpeed',
        message: 'Driving speed of $speed km/h is very slow. This may result in unrealistic travel time estimates.',
        currentValue: speed,
        expectedValue: '>= ${constraints.minSpeed} km/h',
      ));
    } else if (speed > constraints.maxSpeed) {
      violations.add(ConstraintViolation.warning(
        field: 'preferredDrivingSpeed',
        message: 'Driving speed of $speed km/h is very high. Consider local speed limits and road conditions.',
        currentValue: speed,
        expectedValue: '<= ${constraints.maxSpeed} km/h',
      ));
    }

    return violations;
  }

  /// Validates rest stop interval
  List<ConstraintViolation> _validateRestInterval(int intervalInMinutes) {
    final violations = <ConstraintViolation>[];
    final hours = (intervalInMinutes / 60).toStringAsFixed(1);

    if (intervalInMinutes < constraints.minRestInterval) {
      violations.add(ConstraintViolation.warning(
        field: 'restStopInterval',
        message: 'Rest interval of $hours hours is too frequent. This may add excessive travel time.',
        currentValue: intervalInMinutes,
        expectedValue: '>= ${constraints.minRestInterval} minutes',
      ));
    } else if (intervalInMinutes > constraints.maxRestInterval) {
      violations.add(ConstraintViolation.error(
        field: 'restStopInterval',
        message: 'Rest interval of $hours hours is too long. Take breaks every ${(constraints.maxRestInterval / 60).toStringAsFixed(1)} hours or less to stay alert.',
        currentValue: intervalInMinutes,
        expectedValue: '<= ${constraints.maxRestInterval} minutes',
      ));
    } else if (intervalInMinutes < constraints.recommendedMinRestInterval) {
      violations.add(ConstraintViolation.warning(
        field: 'restStopInterval',
        message: 'Rest interval of $hours hours is below recommended. Consider ${(constraints.recommendedMinRestInterval / 60).toStringAsFixed(1)}-${(constraints.recommendedMaxRestInterval / 60).toStringAsFixed(1)} hours between breaks.',
        currentValue: intervalInMinutes,
        expectedValue: '${constraints.recommendedMinRestInterval}-${constraints.recommendedMaxRestInterval} minutes',
      ));
    } else if (intervalInMinutes > constraints.recommendedMaxRestInterval) {
      violations.add(ConstraintViolation.warning(
        field: 'restStopInterval',
        message: 'Rest interval of $hours hours is above recommended. Consider taking breaks every ${(constraints.recommendedMinRestInterval / 60).toStringAsFixed(1)}-${(constraints.recommendedMaxRestInterval / 60).toStringAsFixed(1)} hours.',
        currentValue: intervalInMinutes,
        expectedValue: '${constraints.recommendedMinRestInterval}-${constraints.recommendedMaxRestInterval} minutes',
      ));
    }

    return violations;
  }

  /// Validates consistency between related preferences
  List<ConstraintViolation> _validateConsistency(TripPreferences preferences) {
    final violations = <ConstraintViolation>[];

    // Check if time limit is consistent with distance and speed
    final maxDistanceByTime = (preferences.maxDailyDrivingTime / 60) * preferences.preferredDrivingSpeed;
    
    if (preferences.maxDailyDrivingDistance > maxDistanceByTime * 1.2) {
      violations.add(ConstraintViolation.warning(
        field: 'consistency',
        message: 'Your max daily distance (${preferences.maxDailyDrivingDistance} km) may be unreachable with ${(preferences.maxDailyDrivingTime / 60).toStringAsFixed(1)} hours of driving at ${preferences.preferredDrivingSpeed} km/h. Maximum achievable is approximately ${maxDistanceByTime.toInt()} km.',
        currentValue: preferences.maxDailyDrivingDistance,
        expectedValue: '<= ${maxDistanceByTime.toInt()} km',
      ));
    }

    // Check if rest stop interval makes sense with daily driving time
    if (preferences.includeRestStops && preferences.restStopInterval != null) {
      if (preferences.restStopInterval! >= preferences.maxDailyDrivingTime) {
        violations.add(ConstraintViolation.warning(
          field: 'restStopInterval',
          message: 'Rest interval (${(preferences.restStopInterval! / 60).toStringAsFixed(1)} hrs) should be less than daily driving time (${(preferences.maxDailyDrivingTime / 60).toStringAsFixed(1)} hrs).',
          currentValue: preferences.restStopInterval,
          expectedValue: '< ${preferences.maxDailyDrivingTime} minutes',
        ));
      }
    }

    return violations;
  }

  /// Checks if there are any error-level violations
  bool hasErrors(List<ConstraintViolation> violations) {
    return violations.any((v) => v.severity == ViolationSeverity.error);
  }

  /// Checks if there are any warning-level violations
  bool hasWarnings(List<ConstraintViolation> violations) {
    return violations.any((v) => v.severity == ViolationSeverity.warning);
  }

  /// Gets violations of specific severity
  List<ConstraintViolation> getViolationsBySeverity(
    List<ConstraintViolation> violations,
    ViolationSeverity severity,
  ) {
    return violations.where((v) => v.severity == severity).toList();
  }
}
