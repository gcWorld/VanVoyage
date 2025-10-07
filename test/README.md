# VanVoyage Tests

This directory contains tests for the VanVoyage application.

## Test Structure

```
test/
├── unit/                           # Unit tests for business logic
│   ├── domain/                     # Domain entity tests
│   │   ├── trip_test.dart
│   │   └── waypoint_test.dart
│   └── infrastructure/             # Infrastructure layer tests
├── integration/                    # Integration tests
│   └── infrastructure/             # Database and repository tests
│       ├── database_test.dart
│       ├── trip_repository_test.dart
│       └── waypoint_repository_test.dart
└── widget_test.dart               # Widget tests
```

## Running Tests

### All Tests
```bash
flutter test
```

### Unit Tests Only
```bash
flutter test test/unit/
```

### Integration Tests Only
```bash
flutter test test/integration/
```

### Specific Test File
```bash
flutter test test/unit/domain/trip_test.dart
```

### With Coverage
```bash
flutter test --coverage
```

## Test Categories

### Unit Tests
- Test individual classes and functions in isolation
- Fast execution
- No external dependencies
- Located in `test/unit/`

### Integration Tests
- Test interaction between components
- Database operations
- Repository functionality
- Located in `test/integration/`

### Widget Tests
- Test UI components
- User interactions
- Located in `test/widget_test.dart`

## Test Database

Integration tests use `sqflite_common_ffi` to create an in-memory SQLite database for testing. This ensures:
- Fast test execution
- No side effects between tests
- Consistent test environment
- No need for actual device/emulator

## Testing Guidelines

- Write tests for all new features
- Follow the testing patterns established in the architecture docs
- Use mockito for mocking dependencies
- Aim for good test coverage of business logic
- Use Arrange-Act-Assert pattern
- Keep tests focused with descriptive names
