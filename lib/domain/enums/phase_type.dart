/// Phase type enumeration representing the type of trip phase.
enum PhaseType {
  /// Journey to destination region
  outbound,

  /// Exploring within region
  exploration,

  /// Journey back home
  return_;

  /// Converts string to PhaseType enum
  static PhaseType fromString(String value) {
    return PhaseType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => PhaseType.exploration,
    );
  }

  /// Converts enum to database string representation
  String toDbString() {
    return name.toUpperCase();
  }
}
