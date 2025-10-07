# VanVoyage Tests

This directory contains tests for the VanVoyage application.

## Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

## Test Structure

- `widget_test.dart` - Basic widget tests
- Additional test files will be organized by feature as the project grows

## Testing Guidelines

- Write tests for all new features
- Follow the testing patterns established in the architecture docs
- Use mockito for mocking dependencies
- Aim for good test coverage of business logic
