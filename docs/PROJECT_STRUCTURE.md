# VanVoyage Project Structure

## Directory Tree

```
VanVoyage/
│
├── 📱 lib/                          # Flutter application code
│   ├── 🚀 main.dart                 # Entry point with ProviderScope
│   ├── 📲 app.dart                  # MaterialApp configuration
│   ├── 🔌 providers.dart            # Global Riverpod providers
│   ├── 🔐 secrets.dart.template     # API keys template
│   │
│   ├── 🎯 core/                     # Shared utilities and constants
│   │   ├── constants/               # App-wide constants
│   │   ├── utils/                   # Helper functions
│   │   └── errors/                  # Error handling classes
│   │
│   ├── 🏢 domain/                   # Business logic (pure Dart)
│   │   ├── entities/                # Domain entities
│   │   │   ├── trip.dart
│   │   │   ├── waypoint.dart
│   │   │   └── activity.dart
│   │   ├── value_objects/           # Immutable value objects
│   │   │   ├── location.dart
│   │   │   └── date_range.dart
│   │   └── enums/                   # Enumerations
│   │       ├── trip_status.dart
│   │       └── waypoint_type.dart
│   │
│   ├── 🎮 application/              # Application logic (BLoCs)
│   │   ├── blocs/                   # Business logic components
│   │   │   ├── trip/
│   │   │   │   ├── trip_list_bloc.dart
│   │   │   │   └── trip_detail_bloc.dart
│   │   │   ├── waypoint/
│   │   │   └── map/
│   │   └── states/                  # State definitions
│   │       ├── trip_list_state.dart
│   │       └── trip_detail_state.dart
│   │
│   ├── 🔧 infrastructure/           # External interfaces
│   │   ├── repositories/            # Data access implementations
│   │   │   ├── trip_repository.dart
│   │   │   └── waypoint_repository.dart
│   │   ├── services/                # External service integrations
│   │   │   ├── mapbox_service.dart
│   │   │   ├── location_service.dart
│   │   │   └── geocoding_service.dart
│   │   └── database/                # Database setup
│   │       ├── database_provider.dart
│   │       └── migrations/
│   │
│   └── 🎨 presentation/             # UI layer (Flutter widgets)
│       ├── screens/                 # Full-screen pages
│       │   ├── home/
│       │   │   └── trip_list_screen.dart
│       │   ├── map/
│       │   │   └── interactive_map_screen.dart
│       │   ├── planning/
│       │   └── settings/
│       ├── widgets/                 # Reusable components
│       │   ├── common/
│       │   │   ├── loading_indicator.dart
│       │   │   └── error_message.dart
│       │   └── trip/
│       │       └── trip_card.dart
│       └── theme/                   # App theming
│           └── app_theme.dart
│
├── 🧪 test/                         # Tests
│   ├── widget_test.dart            # Widget tests
│   ├── unit/                       # Unit tests
│   └── integration/                # Integration tests
│
├── 🤖 android/                      # Android platform code
│   ├── app/
│   │   ├── build.gradle            # App build configuration
│   │   └── src/main/
│   │       ├── AndroidManifest.xml # App manifest & permissions
│   │       ├── kotlin/             # Kotlin code
│   │       │   └── com/vanvoyage/app/
│   │       │       └── MainActivity.kt
│   │       └── res/                # Android resources
│   │           ├── drawable/
│   │           ├── mipmap-*/       # App icons
│   │           └── values/
│   │               └── styles.xml
│   ├── build.gradle                # Project build configuration
│   ├── settings.gradle             # Project settings
│   └── gradle.properties           # Gradle properties
│
├── 🍎 ios/                          # iOS platform code
│   └── Runner/
│       └── Info.plist              # iOS configuration & permissions
│
├── 🔄 .github/                      # GitHub configuration
│   └── workflows/
│       └── flutter-ci.yml          # CI/CD pipeline
│
├── 📚 docs/                         # Documentation
│   ├── architecture/               # Architecture documents
│   │   ├── README.md
│   │   ├── 01-domain-models.md
│   │   ├── 02-state-management.md
│   │   ├── 03-data-persistence.md
│   │   ├── 04-ui-navigation.md
│   │   ├── 05-class-diagrams.md
│   │   └── 06-data-flow.md
│   ├── PROJECT_SETUP.md            # Complete setup guide
│   ├── SETUP_VERIFICATION.md       # Verification checklist
│   ├── SETUP_SUMMARY.md            # Setup summary
│   └── PROJECT_STRUCTURE.md        # This file
│
├── 📄 Configuration Files
│   ├── .gitignore                  # Git ignore rules
│   ├── analysis_options.yaml       # Dart analyzer config
│   ├── pubspec.yaml                # Flutter dependencies
│   ├── pubspec.lock                # Locked dependency versions
│   ├── README.md                   # Project README
│   ├── QUICKSTART.md               # Quick start guide
│   ├── CONTRIBUTING.md             # Contribution guidelines
│   └── CHANGELOG.md                # Version history
│
└── 🏗️ Build Output (gitignored)
    ├── build/                      # Build artifacts
    └── .dart_tool/                 # Dart tooling cache
```

## Layer Responsibilities

### 🏢 Domain Layer (Pure Business Logic)
- **No Flutter dependencies**
- **No external package dependencies**
- Contains core business entities and rules
- Defines interfaces for repositories

**Key Files**:
- `entities/` - Core domain objects (Trip, Waypoint, Activity)
- `value_objects/` - Immutable values (Location, DateRange)
- `enums/` - Type-safe enumerations

### 🎮 Application Layer (Use Cases)
- **Uses domain entities**
- **Implements business logic via BLoCs**
- Coordinates between UI and infrastructure
- Manages application state

**Key Files**:
- `blocs/` - State management with BLoC pattern
- `states/` - State class definitions

### 🔧 Infrastructure Layer (External Interfaces)
- **Implements repository interfaces**
- **Integrates external services**
- Handles data persistence
- Manages API calls

**Key Files**:
- `repositories/` - Data access implementations
- `services/` - External service wrappers (Mapbox, GPS)
- `database/` - SQLite database management

### 🎨 Presentation Layer (UI)
- **Flutter widgets only**
- **Consumes BLoCs via Riverpod**
- Displays data to users
- Handles user interactions

**Key Files**:
- `screens/` - Full-page widgets
- `widgets/` - Reusable components
- `theme/` - Visual styling

## Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      User Interaction                        │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                  Presentation Layer                          │
│  • Screens: trip_list_screen.dart                          │
│  • Widgets: trip_card.dart                                  │
│                                                              │
│  Consumes state via: ConsumerWidget + ref.watch()          │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                 Application Layer (BLoC)                     │
│  • BLoCs: trip_list_bloc.dart                              │
│  • States: trip_list_state.dart                            │
│                                                              │
│  Manages state, implements use cases                        │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                Infrastructure Layer                          │
│  • Repositories: trip_repository.dart                       │
│  • Services: mapbox_service.dart                           │
│  • Database: database_provider.dart                        │
│                                                              │
│  Accesses external systems (DB, APIs)                       │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    Domain Layer                              │
│  • Entities: trip.dart, waypoint.dart                      │
│  • Value Objects: location.dart                            │
│  • Enums: trip_status.dart                                 │
│                                                              │
│  Pure business logic, no dependencies                       │
└─────────────────────────────────────────────────────────────┘
```

## Dependency Rules

```
Presentation ─────► Application ─────► Domain
     │                   │                │
     │                   │                │
     └─────► Infrastructure ◄─────────────┘
                    │
                    ▼
            External Systems
         (Database, APIs, GPS)
```

**Rules**:
1. Inner layers don't depend on outer layers
2. Domain is the innermost layer (no dependencies)
3. Infrastructure implements interfaces defined in Domain
4. Presentation and Application use Domain entities
5. Only Infrastructure talks to external systems

## File Naming Conventions

### Dart Files
- `snake_case.dart` for all Dart files
- `*_bloc.dart` for BLoC classes
- `*_state.dart` for state classes
- `*_repository.dart` for repositories
- `*_service.dart` for services
- `*_screen.dart` for full-screen widgets
- `*_widget.dart` for reusable widgets

### Test Files
- Mirror source file name: `trip_list_bloc_test.dart`
- Place in corresponding test directory

### Configuration Files
- `SCREAMING_SNAKE_CASE.md` for documentation
- `lowercase.yaml` for configuration
- `lowercase.gradle` for Gradle files

## State Management Pattern

```
User Action (Button Tap)
        │
        ▼
ConsumerWidget calls ref.read(provider).method()
        │
        ▼
BLoC processes event
        │
        ▼
BLoC updates StateNotifier.state
        │
        ▼
Riverpod notifies all listeners
        │
        ▼
ConsumerWidget rebuilds with new state
        │
        ▼
UI updates
```

## Platform-Specific Code

### Android
```
android/
├── app/
│   ├── build.gradle              # Dependencies & config
│   └── src/main/
│       ├── AndroidManifest.xml   # Permissions
│       └── kotlin/               # Platform channel code
```

### iOS
```
ios/
└── Runner/
    └── Info.plist                # Permissions & config
```

## Generated Files (gitignored)

These files are auto-generated and should not be edited manually:

- `*.g.dart` - Generated by `build_runner`
- `*.freezed.dart` - Generated by `freezed` (if used)
- `pubspec.lock` - Locked versions (committed, but auto-updated)

To regenerate:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Key Dependencies by Layer

### Domain Layer
- None (pure Dart)

### Application Layer
- `flutter_riverpod`
- `riverpod_annotation`
- `equatable`

### Infrastructure Layer
- `sqflite` (database)
- `mapbox_maps_flutter` (maps)
- `geolocator` (location)
- `geocoding` (address conversion)

### Presentation Layer
- `flutter` (framework)
- `go_router` (navigation)
- `intl` (formatting)

## Expansion Points

When adding new features:

1. **New Entity**: Add to `domain/entities/`
2. **New BLoC**: Add to `application/blocs/{feature}/`
3. **New Repository**: Add to `infrastructure/repositories/`
4. **New Screen**: Add to `presentation/screens/{feature}/`
5. **New Service**: Add to `infrastructure/services/`

## Testing Structure

```
test/
├── widget_test.dart              # Basic widget tests
├── unit/                         # Unit tests
│   ├── domain/                   # Domain logic tests
│   ├── application/              # BLoC tests
│   └── infrastructure/           # Repository tests
├── widget/                       # Widget tests
│   └── presentation/             # UI component tests
└── integration/                  # Integration tests
    └── flows/                    # User flow tests
```

## Resources

- **Setup Guide**: `docs/PROJECT_SETUP.md`
- **Architecture**: `docs/architecture/README.md`
- **Quick Start**: `QUICKSTART.md`
- **Contributing**: `CONTRIBUTING.md`

---

**Note**: This structure follows Flutter best practices and Clean Architecture principles, ensuring maintainability and scalability as the project grows.
