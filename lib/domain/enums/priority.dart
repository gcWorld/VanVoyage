/// Priority enumeration representing the importance level.
enum Priority {
  high,
  medium,
  low;

  /// Converts string to Priority enum
  static Priority fromString(String value) {
    return Priority.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => Priority.medium,
    );
  }

  /// Converts enum to database string representation
  String toDbString() {
    return name.toUpperCase();
  }
}
