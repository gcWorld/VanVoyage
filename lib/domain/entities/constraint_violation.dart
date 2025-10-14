import 'package:equatable/equatable.dart';

/// Severity level of a constraint violation
enum ViolationSeverity {
  /// Informational message, no violation
  info,
  
  /// Warning - value is outside recommended range but acceptable
  warning,
  
  /// Error - value is outside safe limits
  error,
}

/// Represents a violation of a travel constraint
class ConstraintViolation extends Equatable {
  /// Field that has the violation
  final String field;
  
  /// Human-readable message describing the violation
  final String message;
  
  /// Severity of the violation
  final ViolationSeverity severity;
  
  /// Current value that caused the violation
  final dynamic currentValue;
  
  /// Expected/recommended value or range
  final String? expectedValue;

  const ConstraintViolation({
    required this.field,
    required this.message,
    required this.severity,
    required this.currentValue,
    this.expectedValue,
  });

  /// Creates a warning violation
  factory ConstraintViolation.warning({
    required String field,
    required String message,
    required dynamic currentValue,
    String? expectedValue,
  }) {
    return ConstraintViolation(
      field: field,
      message: message,
      severity: ViolationSeverity.warning,
      currentValue: currentValue,
      expectedValue: expectedValue,
    );
  }

  /// Creates an error violation
  factory ConstraintViolation.error({
    required String field,
    required String message,
    required dynamic currentValue,
    String? expectedValue,
  }) {
    return ConstraintViolation(
      field: field,
      message: message,
      severity: ViolationSeverity.error,
      currentValue: currentValue,
      expectedValue: expectedValue,
    );
  }

  /// Creates an info message
  factory ConstraintViolation.info({
    required String field,
    required String message,
    required dynamic currentValue,
  }) {
    return ConstraintViolation(
      field: field,
      message: message,
      severity: ViolationSeverity.info,
      currentValue: currentValue,
    );
  }

  @override
  List<Object?> get props => [
        field,
        message,
        severity,
        currentValue,
        expectedValue,
      ];
}
