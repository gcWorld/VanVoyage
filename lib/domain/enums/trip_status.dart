/// Trip status enumeration representing the current state of a trip.
enum TripStatus {
  /// Trip is being planned
  planning,

  /// Trip is currently in progress
  active,

  /// Trip has been completed
  completed,

  /// Trip is archived for reference
  archived;

  /// Converts string to TripStatus enum
  static TripStatus fromString(String value) {
    return TripStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => TripStatus.planning,
    );
  }

  /// Converts enum to database string representation
  String toDbString() {
    return name.toUpperCase();
  }
}
