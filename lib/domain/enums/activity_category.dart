/// Activity category enumeration representing the type of activity.
enum ActivityCategory {
  sightseeing,
  hiking,
  dining,
  shopping,
  cultural,
  outdoor,
  relaxation,
  other;

  /// Converts string to ActivityCategory enum
  static ActivityCategory fromString(String value) {
    return ActivityCategory.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => ActivityCategory.other,
    );
  }

  /// Converts enum to database string representation
  String toDbString() {
    return name.toUpperCase();
  }
}
