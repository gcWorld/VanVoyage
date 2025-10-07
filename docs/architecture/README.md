# VanVoyage Architecture Documentation

This directory contains comprehensive architecture documentation for the VanVoyage application.

## Document Overview

### [01. Domain Models](01-domain-models.md)
Detailed description of core domain entities, their relationships, and data structures.

**Contents:**
- Core entity definitions (Trip, Waypoint, Activity, etc.)
- Entity relationships and cardinality
- Enumerations and value objects
- Entity relationship diagrams
- Domain design principles
- Future enhancements

### [02. State Management](02-state-management.md)
State management approach using BLoC pattern with Riverpod.

**Contents:**
- State management pattern selection and rationale
- BLoC architecture and implementation
- Provider configuration
- Key BLoCs for each feature area
- Best practices and testing strategies
- Integration with UI layer

### [03. Data Persistence](03-data-persistence.md)
Local database architecture using SQLite for offline-first functionality.

**Contents:**
- Database schema design
- Table definitions and relationships
- Repository pattern implementation
- Database initialization and migrations
- Query optimization strategies
- Backup and restore capabilities

### [04. UI Navigation](04-ui-navigation.md)
User interface structure and navigation patterns.

**Contents:**
- App navigation hierarchy
- Screen definitions and purposes
- Navigation flows and user journeys
- Modal workflows
- Bottom navigation configuration
- Deep linking support
- Accessibility considerations

### [05. Class Diagrams](05-class-diagrams.md)
Detailed UML-style class diagrams for all architectural layers.

**Contents:**
- Domain layer classes (entities, value objects)
- Application layer classes (BLoCs, state)
- Infrastructure layer classes (repositories, services)
- Presentation layer classes (screens, widgets)
- Class relationships and dependencies
- Design patterns applied

### [06. Data Flow](06-data-flow.md)
How data flows through the application from user interaction to persistence.

**Contents:**
- Unidirectional data flow pattern
- Complete user workflow examples
- State update propagation
- Error handling flows
- Offline mode behavior
- Performance optimization patterns
- Data validation flow

---

## Architecture Principles

### 1. Offline-First
The application is designed to work completely offline. All core functionality is available without internet connectivity. Network is only required for:
- Map tile loading (cached for offline use)
- Route calculation (results cached)
- Future: Cloud synchronization

### 2. Clean Architecture
The application follows clean architecture principles with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│      Presentation Layer                 │  ← UI, Widgets, Screens
├─────────────────────────────────────────┤
│      Application Layer                  │  ← BLoCs, State Management
├─────────────────────────────────────────┤
│      Domain Layer                       │  ← Entities, Business Rules
├─────────────────────────────────────────┤
│      Infrastructure Layer               │  ← Data Access, External APIs
└─────────────────────────────────────────┘
```

### 3. Unidirectional Data Flow
Data flows in one direction: from user interactions through BLoCs to repositories and back to UI via state updates.

### 4. Immutable State
State objects are immutable. Updates create new state instances rather than modifying existing ones.

### 5. Dependency Injection
Riverpod providers manage dependencies, making the codebase testable and maintainable.

### 6. Repository Pattern
All data access goes through repository interfaces, abstracting the data source implementation.

---

## Technology Stack Summary

### Frontend Framework
- **Flutter**: Cross-platform UI framework (Android focus for MVP)
- **Dart**: Programming language

### State Management
- **Riverpod**: Dependency injection and provider management
- **BLoC Pattern**: Business logic separation

### Data Persistence
- **SQLite** (via sqflite): Local database
- **Structured schema**: Normalized data model

### Maps & Location
- **Mapbox**: Interactive maps and routing
- **Flutter Geolocator**: Location services

### Testing
- **flutter_test**: Widget and unit testing
- **mockito**: Mocking for tests
- **integration_test**: End-to-end testing

---

## Development Phases

### Phase 1: MVP (Current Focus)
Core functionality for single-user trip planning with offline support.

**Features:**
- Trip creation and management
- Waypoint management
- Basic route calculation
- Interactive map view
- Local data persistence
- Offline functionality

**Architecture Components:**
- Core domain models
- Basic BLoCs
- SQLite database
- Essential screens

### Phase 2: Enhanced Features
Additional capabilities and refinements.

**Planned Features:**
- Route optimization algorithms
- Advanced trip planning tools
- Data export/import
- Enhanced UI/UX
- Performance optimizations

**Architecture Additions:**
- Additional BLoCs for advanced features
- Optimization services
- Export/import services

### Phase 3: Cloud & Collaboration
Cloud synchronization and sharing capabilities.

**Planned Features:**
- User accounts and authentication
- Cloud backup and sync
- Trip sharing with other users
- Real-time collaboration
- Cross-device synchronization

**Architecture Additions:**
- Authentication service
- Sync service with conflict resolution
- API client for backend
- WebSocket for real-time updates

---

## Key Design Decisions

### 1. Why BLoC with Riverpod?
**Decision**: Use BLoC pattern with Riverpod for state management.

**Rationale**:
- Clear separation between UI and business logic
- Excellent testability
- Strong typing and compile-time safety
- Scalable for growing application
- Good Flutter ecosystem support

**Alternatives Considered**: Provider (too basic), GetX (too opinionated), Redux (too much boilerplate)

### 2. Why SQLite?
**Decision**: Use SQLite for local data persistence.

**Rationale**:
- No server dependencies
- Excellent offline support
- Mature, reliable, and fast
- Perfect for structured relational data
- Easy to backup and restore

**Alternatives Considered**: Hive (less query power), SharedPreferences (not suitable for complex data)

### 3. Why Mapbox?
**Decision**: Use Mapbox for mapping and routing.

**Rationale**:
- Excellent Flutter SDK support
- Powerful routing API
- Customizable map styles
- Offline map support
- Generous free tier

**Alternatives Considered**: Google Maps (more expensive, less customizable), OpenStreetMap (requires more setup)

### 4. Why Offline-First?
**Decision**: Design for offline operation as the default mode.

**Rationale**:
- Van travelers often in areas with poor connectivity
- Better user experience (instant response)
- Privacy - user data stays local
- Simpler initial implementation
- Cloud sync can be added later without major refactoring

---

## Code Organization

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # App widget, routing, theme
│
├── core/                        # Core utilities and constants
│   ├── constants/
│   ├── utils/
│   └── errors/
│
├── domain/                      # Domain layer
│   ├── entities/                # Entity classes
│   │   ├── trip.dart
│   │   ├── waypoint.dart
│   │   ├── activity.dart
│   │   └── ...
│   ├── value_objects/           # Value objects
│   │   ├── location.dart
│   │   ├── date_range.dart
│   │   └── ...
│   └── enums/                   # Enumerations
│       ├── trip_status.dart
│       └── ...
│
├── application/                 # Application layer
│   ├── blocs/                   # BLoC classes
│   │   ├── trip/
│   │   ├── waypoint/
│   │   ├── map/
│   │   └── ...
│   └── states/                  # State classes
│
├── infrastructure/              # Infrastructure layer
│   ├── repositories/            # Repository implementations
│   │   ├── trip_repository.dart
│   │   └── ...
│   ├── services/                # External services
│   │   ├── mapbox_service.dart
│   │   ├── location_service.dart
│   │   └── ...
│   └── database/                # Database setup
│       ├── database_provider.dart
│       └── migrations/
│
├── presentation/                # Presentation layer
│   ├── screens/                 # Screen widgets
│   │   ├── home/
│   │   ├── map/
│   │   ├── planning/
│   │   └── settings/
│   ├── widgets/                 # Reusable widgets
│   │   ├── common/
│   │   ├── trip/
│   │   └── ...
│   └── theme/                   # App theme
│
└── providers.dart               # Riverpod provider definitions
```

---

## Testing Strategy

### Unit Tests
- Domain entities (validation, methods)
- Value objects
- Utility functions
- Repository logic

### Widget Tests
- Individual widgets
- Screen layouts
- User interactions
- State-dependent rendering

### Integration Tests
- Complete user flows
- Navigation
- Database operations
- BLoC integration

### Test Coverage Goals
- Domain layer: 90%+
- Application layer (BLoCs): 80%+
- Infrastructure layer: 70%+
- Presentation layer: 60%+

---

## Performance Considerations

### Database
- Indexed columns for common queries
- Pagination for large result sets
- Efficient query design
- Transaction batching

### State Management
- Selective widget rebuilding
- Debouncing rapid updates
- Lazy loading of data
- Memory-efficient state storage

### Maps
- Tile caching for offline use
- Marker clustering for many waypoints
- Geometry simplification for routes
- Level-of-detail rendering

### General
- Image optimization
- Async operations for heavy tasks
- Background processing where appropriate
- Memory leak prevention

---

## Security Considerations

### Data Privacy
- All data stored locally (no cloud in MVP)
- No analytics or tracking
- User data never leaves device

### Future Security Measures (Phase 3)
- Database encryption (SQLCipher)
- Secure authentication (OAuth 2.0)
- HTTPS for all API calls
- Token-based API authorization
- Encrypted cloud sync

---

## Monitoring & Debugging

### Logging Strategy
- Structured logging with different levels
- Error logging with stack traces
- Performance logging for slow operations
- User action logging (optional, privacy-respecting)

### Debug Tools
- Flutter DevTools
- SQLite database inspection
- BLoC state inspection
- Network request logging

---

## Documentation Maintenance

This documentation should be updated when:
- New features are added
- Architecture patterns change
- Technology decisions are revised
- Database schema is updated
- New screens or workflows are added

Each document includes a "Future Enhancements" section for planned but not yet implemented features.

---

## Contributing to Architecture

When proposing architecture changes:
1. Create an Architecture Decision Record (ADR)
2. Discuss rationale and alternatives
3. Update relevant documentation
4. Ensure backward compatibility or migration path
5. Update tests to reflect changes

---

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev/)
- [BLoC Pattern Guide](https://bloclibrary.dev/)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Mapbox Flutter SDK](https://docs.mapbox.com/android/maps/guides/)
- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

## Questions or Feedback?

For questions about the architecture or suggestions for improvements, please open an issue in the GitHub repository.
