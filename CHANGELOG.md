# Changelog

All notable changes to the VanVoyage project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial Flutter project structure
- Complete dependency configuration:
  - State Management: flutter_riverpod, riverpod_annotation, riverpod_generator
  - Maps: mapbox_maps_flutter
  - Database: sqflite
  - Location: geolocator, geocoding
  - Navigation: go_router
  - Utilities: uuid, intl, equatable
- Android platform configuration (SDK 21+, Kotlin)
- iOS platform configuration with location permissions
- GitHub Actions CI/CD pipeline
  - Automated testing
  - Code formatting checks
  - Static analysis
  - Debug APK builds
- Basic app structure with splash screen
- Testing infrastructure with example test
- Project documentation:
  - README with setup instructions
  - CONTRIBUTING guidelines
  - PROJECT_SETUP comprehensive guide
  - SETUP_VERIFICATION checklist
- Code quality tools:
  - .gitignore for Flutter projects
  - analysis_options.yaml with flutter_lints
- Directory structure following clean architecture:
  - core/ for shared utilities
  - domain/ for business entities
  - application/ for BLoCs and state
  - infrastructure/ for data access
  - presentation/ for UI

## [0.1.0] - 2024-10-07

### Added
- Initial project setup
- Architecture documentation in docs/architecture/
- Domain models specification
- State management architecture (BLoC + Riverpod)
- Data persistence strategy (SQLite)
- UI navigation flow design
- Class diagrams
- Data flow documentation
