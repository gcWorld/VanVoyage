# VanVoyage 🚐

A camper van trip planning application designed to simplify travel planning and route optimization for van life enthusiasts.

## Overview

VanVoyage is an application focused on planning camper van trips with flexible time frames and location preferences. The app aims to solve common challenges faced by van travelers:
- Planning routes with optimal driving distances per day
- Managing multi-day stays at specific locations
- Handling two-phase journeys (getting to the general area/returning home and traveling on location)
- Offline capability for on-the-road modifications
- Setting start/end dates for trips and calculating travel timeframes

## Features (Planned)

- **Interactive Route Planning**: Create, view, and modify travel routes on an interactive map
- **Flexible Scheduling**: Set preferences for daily driving distances and duration of stays
- **Two-Phase Journey Planning**: Separate planning for getting to the destination region and exploring within it
- **Offline Support**: View and modify trip plans without internet connection
- **Time Constraints**: Set start/end dates or preferred duration in specific areas
- **Points of Interest**: Add and manage locations you want to visit
- **Route Optimization**: Suggestions for the most efficient routes between selected destinations

## Technical Architecture

### Mobile Application (MVP)
- **Framework**: Flutter for cross-platform development (Android focus initially)
- **Maps**: Mapbox for interactive mapping features
- **State Management**: BLoC pattern with Riverpod
- **Local Storage**: SQLite for offline data persistence
- **Geolocation**: Flutter location services

### Architecture Documentation
Comprehensive architecture documentation is available in the [`/docs/architecture`](docs/architecture/) directory:
- [Domain Models](docs/architecture/01-domain-models.md) - Core entities and relationships
- [State Management](docs/architecture/02-state-management.md) - BLoC pattern with Riverpod
- [Data Persistence](docs/architecture/03-data-persistence.md) - SQLite database schema and repositories
- [UI Navigation](docs/architecture/04-ui-navigation.md) - Screen hierarchy and navigation flows
- [Class Diagrams](docs/architecture/05-class-diagrams.md) - Detailed class structures
- [Data Flow](docs/architecture/06-data-flow.md) - How data flows through the application

### Future Extensions
- Web application
- iOS support
- Cloud synchronization
- Trip sharing capabilities

## Development Setup

1. **Prerequisites**:
   - Flutter SDK 3.0.0 or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
   - Android Studio / VS Code with Flutter extensions
   - Mapbox API key ([Get one here](https://account.mapbox.com/))

2. **Installation**:
   ```bash
   git clone https://github.com/gcWorld/VanVoyage.git
   cd VanVoyage
   flutter pub get
   ```

3. **Configuration**:
   - Copy `lib/secrets.dart.template` to `lib/secrets.dart`
   - Add your Mapbox API key to `lib/secrets.dart`:
     ```dart
     const String mapboxApiKey = 'your-api-key-here';
     ```

4. **Run the app**:
   ```bash
   # Check that Flutter is set up correctly
   flutter doctor

   # Run the app
   flutter run
   ```

5. **Testing**:
   ```bash
   # Run tests
   flutter test

   # Check code formatting
   dart format .

   # Analyze code
   flutter analyze
   ```

## Current Status

The project has completed initial setup with:
- ✅ Flutter project structure
- ✅ Dependency configuration (Mapbox GL, sqflite, Riverpod)
- ✅ CI/CD pipeline with GitHub Actions
- ✅ Architecture documentation

See the GitHub Issues for current development tasks and progress.

## Contributing

As this is a personal project, please reach out before contributing. Future collaboration may be welcome as the project matures.

## License

[To be determined]
