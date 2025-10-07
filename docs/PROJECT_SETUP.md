# VanVoyage Project Setup Documentation

This document describes the initial Flutter project setup for VanVoyage, including all dependencies, configurations, and architectural decisions.

## Project Overview

**Name**: VanVoyage  
**Description**: A camper van trip planning application for van life enthusiasts  
**Platform**: Flutter (Android-first, with iOS support planned)  
**Version**: 0.1.0+1

## Technology Stack

### Core Framework
- **Flutter SDK**: 3.0.0+ (stable channel recommended)
- **Dart**: 3.0.0+

### State Management
We use **BLoC pattern with Riverpod** as documented in the architecture:
- `flutter_riverpod` (^2.4.9): Provider-based state management
- `riverpod_annotation` (^2.3.3): Annotations for code generation
- `riverpod_generator` (^2.3.9): Code generation for providers

This combination provides:
- Dependency injection
- Reactive state updates
- Testability
- Type safety

### Maps & Location
- **mapbox_maps_flutter** (^1.1.0): Interactive maps with Mapbox GL
  - Requires Mapbox API key
  - Supports offline maps
  - Rich styling capabilities
  
- **geolocator** (^10.1.0): GPS location services
  - Current location tracking
  - Position streaming
  - Permission handling
  
- **geocoding** (^2.1.1): Address <-> Coordinates conversion
  - Forward geocoding (address to coordinates)
  - Reverse geocoding (coordinates to address)

### Data Persistence
- **sqflite** (^2.3.0): SQLite database for offline storage
  - Offline-first architecture
  - Complex queries support
  - Transaction support
  
- **path** (^1.8.3): Path manipulation utilities

The database schema is documented in `docs/architecture/03-data-persistence.md`.

### Navigation
- **go_router** (^12.1.1): Declarative routing
  - Type-safe navigation
  - Deep linking support
  - Tab/nested navigation

### Utilities
- **uuid** (^4.2.1): Generate unique IDs for entities
- **intl** (^0.18.1): Internationalization and date formatting
- **equatable** (^2.0.5): Value equality for domain objects

### Development Tools
- **flutter_lints** (^3.0.1): Recommended linting rules
- **build_runner** (^2.4.7): Code generation tool
- **mockito** (^5.4.4): Mocking framework for tests
- **integration_test**: End-to-end testing

## Project Structure

The project follows Clean Architecture principles with clear layer separation:

```
lib/
├── main.dart                     # App entry point with ProviderScope
├── app.dart                      # MaterialApp and theme configuration
├── providers.dart                # Global provider definitions
│
├── core/                         # Shared utilities
│   ├── constants/                # App-wide constants
│   ├── utils/                    # Helper functions
│   └── errors/                   # Error handling
│
├── domain/                       # Business logic layer
│   ├── entities/                 # Core business objects
│   │   ├── trip.dart
│   │   ├── waypoint.dart
│   │   └── activity.dart
│   ├── value_objects/            # Immutable value objects
│   │   ├── location.dart
│   │   └── date_range.dart
│   └── enums/                    # Enumerations
│       └── trip_status.dart
│
├── application/                  # Application logic layer
│   ├── blocs/                    # BLoC classes (business logic)
│   │   ├── trip/
│   │   ├── waypoint/
│   │   └── map/
│   └── states/                   # State definitions
│
├── infrastructure/               # External interfaces
│   ├── repositories/             # Data access implementations
│   │   ├── trip_repository.dart
│   │   └── waypoint_repository.dart
│   ├── services/                 # External service integrations
│   │   ├── mapbox_service.dart
│   │   └── location_service.dart
│   └── database/                 # Database setup
│       └── database_provider.dart
│
└── presentation/                 # UI layer
    ├── screens/                  # Full-screen pages
    │   ├── home/
    │   ├── map/
    │   └── planning/
    ├── widgets/                  # Reusable UI components
    │   ├── common/
    │   └── trip/
    └── theme/                    # App theming
```

## Configuration Files

### pubspec.yaml
Main Flutter configuration file containing:
- Project metadata
- Dependencies (runtime and dev)
- Asset declarations
- Font declarations

### analysis_options.yaml
Static analysis configuration using `package:flutter_lints/flutter.yaml`.

### .gitignore
Configured to exclude:
- Build artifacts (`/build/`, `.dart_tool/`)
- IDE files (`.idea/`, `*.iml`)
- Generated files (`*.g.dart`, `*.freezed.dart`)
- Secrets (`lib/secrets.dart`)
- Platform-specific build outputs

## Platform Configurations

### Android (android/)
- **Minimum SDK**: 21 (Android 5.0 Lollipop)
- **Target SDK**: Latest (configured via Flutter)
- **Language**: Kotlin
- **Gradle**: 8.1.0
- **Permissions**: Internet, Location (fine and coarse)

Key files:
- `android/app/build.gradle`: App-level build configuration
- `android/build.gradle`: Project-level build configuration
- `android/settings.gradle`: Project settings
- `android/app/src/main/AndroidManifest.xml`: Permissions and components

### iOS (ios/)
- **Minimum Version**: iOS 12.0 (via Flutter defaults)
- **Language**: Swift
- **Permissions**: Location (when in use and always)

Key files:
- `ios/Runner/Info.plist`: App configuration and permissions

## API Keys & Secrets

Sensitive data like API keys are stored in `lib/secrets.dart` (gitignored).

**Setup**:
1. Copy `lib/secrets.dart.template` to `lib/secrets.dart`
2. Add your API keys:
   ```dart
   const String mapboxApiKey = 'pk.your_actual_key_here';
   ```

Required API keys:
- **Mapbox**: Get from https://account.mapbox.com/

## CI/CD Pipeline

GitHub Actions workflow defined in `.github/workflows/flutter-ci.yml`:

### Triggers
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

### Jobs

#### build-and-test
1. Checkout code
2. Setup Flutter (v3.24.x stable)
3. Install dependencies (`flutter pub get`)
4. Verify code formatting (`dart format`)
5. Run static analysis (`flutter analyze`)
6. Execute tests (`flutter test`)
7. Build debug APK (`flutter build apk --debug`)

#### lint
1. Checkout code
2. Setup Flutter
3. Install dependencies
4. Check formatting
5. Analyze code (with fatal-infos disabled)

## Testing Strategy

### Unit Tests
- Test business logic in BLoCs
- Test repository implementations
- Test domain objects and value objects

### Widget Tests
- Test individual widgets in isolation
- Test widget interactions
- Use `ProviderScope` for state management testing

### Integration Tests
- Test full user flows
- Test end-to-end scenarios
- Use `integration_test` package

Example test structure:
```dart
// test/widget_test.dart
void main() {
  testWidgets('Test description', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: VanVoyageApp(),
      ),
    );
    
    expect(find.text('VanVoyage'), findsOneWidget);
  });
}
```

## Development Workflow

### 1. Initial Setup
```bash
flutter pub get
cp lib/secrets.dart.template lib/secrets.dart
# Add your API keys to lib/secrets.dart
```

### 2. Development Cycle
```bash
# Run app in debug mode
flutter run

# Hot reload: Press 'r' in terminal
# Hot restart: Press 'R' in terminal
```

### 3. Code Quality
```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Run tests
flutter test
```

### 4. Code Generation
When using Riverpod generators:
```bash
# One-time generation
flutter pub run build_runner build

# Watch mode (auto-generate on changes)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 5. Building
```bash
# Debug build
flutter build apk --debug

# Release build (requires signing configuration)
flutter build apk --release
```

## Architecture Patterns

### State Management: BLoC + Riverpod

Example BLoC structure:
```dart
// State
abstract class TripListState {}
class TripListInitial extends TripListState {}
class TripListLoading extends TripListState {}
class TripListLoaded extends TripListState {
  final List<Trip> trips;
  TripListLoaded(this.trips);
}

// BLoC
class TripListBloc extends StateNotifier<TripListState> {
  final TripRepository _repository;
  
  TripListBloc(this._repository) : super(TripListInitial());
  
  Future<void> loadTrips() async {
    state = TripListLoading();
    try {
      final trips = await _repository.getAllTrips();
      state = TripListLoaded(trips);
    } catch (e) {
      state = TripListError(e.toString());
    }
  }
}

// Provider
final tripListProvider = StateNotifierProvider<TripListBloc, TripListState>((ref) {
  final repository = ref.watch(tripRepositoryProvider);
  return TripListBloc(repository);
});
```

### Repository Pattern

Repositories abstract data sources:
```dart
abstract class TripRepository {
  Future<List<Trip>> getAllTrips();
  Future<Trip> getTripById(String id);
  Future<void> saveTrip(Trip trip);
  Future<void> deleteTrip(String id);
}

class TripRepositoryImpl implements TripRepository {
  final DatabaseProvider _db;
  
  TripRepositoryImpl(this._db);
  
  @override
  Future<List<Trip>> getAllTrips() async {
    // Implementation
  }
}
```

## Next Steps

After initial setup, development should proceed in this order:

1. **Domain Models** (Phase 1)
   - Implement entity classes
   - Define value objects
   - Create enumerations

2. **Database Setup** (Phase 1)
   - Create database schema
   - Implement migrations
   - Build repository implementations

3. **State Management** (Phase 2)
   - Implement BLoCs
   - Define state classes
   - Set up providers

4. **UI Implementation** (Phase 3)
   - Create screen widgets
   - Build reusable components
   - Implement navigation

5. **Service Integration** (Phase 4)
   - Integrate Mapbox
   - Implement location services
   - Add geocoding

See individual architecture documents in `docs/architecture/` for detailed guidance on each phase.

## Troubleshooting

### Common Issues

**Issue**: Build fails with dependency conflicts  
**Solution**: Run `flutter pub upgrade --major-versions` and test thoroughly

**Issue**: Code generation fails  
**Solution**: Clean and rebuild: `flutter clean && flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs`

**Issue**: Location permissions not working  
**Solution**: Ensure permissions are declared in AndroidManifest.xml and Info.plist, and request at runtime

**Issue**: Mapbox not rendering  
**Solution**: Verify API key is correct in `lib/secrets.dart` and has appropriate scopes

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Mapbox Flutter SDK](https://docs.mapbox.com/android/maps/guides/)
- [sqflite Documentation](https://pub.dev/packages/sqflite)
- [VanVoyage Architecture Docs](architecture/)

## Maintenance

This document should be updated when:
- Dependencies are added or updated
- Project structure changes
- New tools or patterns are introduced
- Build configuration changes

Last Updated: October 2024
