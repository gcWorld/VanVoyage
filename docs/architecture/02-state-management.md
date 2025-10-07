# State Management Architecture

This document outlines the state management approach for VanVoyage, including the chosen pattern, rationale, and implementation guidelines.

## Chosen Approach: BLoC Pattern with Riverpod

### Decision Summary

After evaluating various Flutter state management solutions, we recommend **BLoC (Business Logic Component) pattern with Riverpod** for the following reasons:

1. **Separation of Concerns**: Clear separation between UI and business logic
2. **Testability**: Easy to test business logic independently
3. **Scalability**: Proven pattern for medium to large applications
4. **Stream-based**: Natural fit for reactive data flows
5. **Flutter Integration**: Excellent support for Flutter's reactive paradigm
6. **Type Safety**: Strong typing with compile-time safety (via Riverpod)
7. **Community Support**: Widely adopted with extensive documentation

### Alternative Considerations

| Pattern | Pros | Cons | Decision |
|---------|------|------|----------|
| **Provider** | Simple, official recommendation | Can become complex in larger apps | Too basic for our needs |
| **Riverpod** | Modern, compile-safe, flexible | Learning curve | ✅ **Selected as foundation** |
| **GetX** | All-in-one, simple API | Too opinionated, magic behavior | Not selected |
| **Redux** | Predictable, time-travel debugging | Boilerplate-heavy, steep learning curve | Overkill for MVP |
| **MobX** | Minimal boilerplate, reactive | Less structure, reflection-based | Not selected |
| **BLoC** | Proven pattern, clear structure | More code than some alternatives | ✅ **Selected with Riverpod** |

---

## Architecture Overview

### Layer Structure

```
┌─────────────────────────────────────────────┐
│           Presentation Layer                │
│  (Widgets, Screens, UI Components)          │
└────────────────┬────────────────────────────┘
                 │ Events & State
┌────────────────▼────────────────────────────┐
│         BLoC/Provider Layer                 │
│  (Business Logic, State Management)         │
└────────────────┬────────────────────────────┘
                 │ Method Calls
┌────────────────▼────────────────────────────┐
│          Repository Layer                   │
│  (Data Access Abstraction)                  │
└────────────────┬────────────────────────────┘
                 │ CRUD Operations
┌────────────────▼────────────────────────────┐
│         Data Source Layer                   │
│  (SQLite, API, Cache)                       │
└─────────────────────────────────────────────┘
```

---

## Core State Management Components

### 1. Providers (Riverpod)

Providers are used for dependency injection and simple state management.

**Types of Providers to Use:**

#### Provider
For immutable, computed values or dependencies:
```dart
final mapboxServiceProvider = Provider<MapboxService>((ref) {
  return MapboxService(apiKey: MAPBOX_API_KEY);
});
```

#### StateProvider
For simple mutable state:
```dart
final selectedWaypointIdProvider = StateProvider<String?>((ref) => null);
```

#### StateNotifierProvider
For complex state objects (used with BLoC):
```dart
final tripListProvider = StateNotifierProvider<TripListBloc, TripListState>((ref) {
  final repository = ref.watch(tripRepositoryProvider);
  return TripListBloc(repository);
});
```

#### FutureProvider
For async operations:
```dart
final currentLocationProvider = FutureProvider<Location>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.getCurrentLocation();
});
```

#### StreamProvider
For continuous data streams:
```dart
final locationStreamProvider = StreamProvider<Location>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return locationService.locationStream;
});
```

---

### 2. BLoC Components

Each major feature area should have its own BLoC.

#### BLoC Structure

```dart
// State classes
abstract class TripDetailState {}
class TripDetailInitial extends TripDetailState {}
class TripDetailLoading extends TripDetailState {}
class TripDetailLoaded extends TripDetailState {
  final Trip trip;
  final List<Waypoint> waypoints;
  TripDetailLoaded(this.trip, this.waypoints);
}
class TripDetailError extends TripDetailState {
  final String message;
  TripDetailError(this.message);
}

// Event classes
abstract class TripDetailEvent {}
class LoadTrip extends TripDetailEvent {
  final String tripId;
  LoadTrip(this.tripId);
}
class UpdateTrip extends TripDetailEvent {
  final Trip trip;
  UpdateTrip(this.trip);
}
class AddWaypoint extends TripDetailEvent {
  final Waypoint waypoint;
  AddWaypoint(this.waypoint);
}

// BLoC implementation
class TripDetailBloc extends StateNotifier<TripDetailState> {
  final TripRepository _repository;
  
  TripDetailBloc(this._repository) : super(TripDetailInitial());
  
  Future<void> loadTrip(String tripId) async {
    state = TripDetailLoading();
    try {
      final trip = await _repository.getTripById(tripId);
      final waypoints = await _repository.getWaypointsByTripId(tripId);
      state = TripDetailLoaded(trip, waypoints);
    } catch (e) {
      state = TripDetailError(e.toString());
    }
  }
  
  Future<void> updateTrip(Trip trip) async {
    try {
      await _repository.updateTrip(trip);
      await loadTrip(trip.id);
    } catch (e) {
      state = TripDetailError(e.toString());
    }
  }
  
  Future<void> addWaypoint(Waypoint waypoint) async {
    try {
      await _repository.addWaypoint(waypoint);
      if (state is TripDetailLoaded) {
        final currentState = state as TripDetailLoaded;
        await loadTrip(currentState.trip.id);
      }
    } catch (e) {
      state = TripDetailError(e.toString());
    }
  }
}
```

---

## Key BLoCs for VanVoyage

### 1. Trip Management

#### TripListBloc
**Responsibility**: Manage the list of all trips
**State**: `TripListState` (initial, loading, loaded, error)
**Operations**:
- Load all trips
- Create new trip
- Delete trip
- Filter trips by status

#### TripDetailBloc
**Responsibility**: Manage single trip details
**State**: `TripDetailState`
**Operations**:
- Load trip with waypoints
- Update trip metadata
- Change trip status
- Add/remove/reorder waypoints

---

### 2. Navigation & Routing

#### MapBloc
**Responsibility**: Manage map state and interactions
**State**: `MapState` (camera position, selected waypoint, route overlay)
**Operations**:
- Update camera position
- Select waypoint
- Show/hide route
- Add marker

#### RouteCalculationBloc
**Responsibility**: Calculate routes between waypoints
**State**: `RouteCalculationState` (idle, calculating, completed, error)
**Operations**:
- Calculate route between two waypoints
- Calculate full trip route
- Optimize waypoint order

---

### 3. Waypoint Management

#### WaypointEditorBloc
**Responsibility**: Edit waypoint details
**State**: `WaypointEditorState`
**Operations**:
- Load waypoint
- Update waypoint details
- Add/remove activities
- Geocode address

---

### 4. App-Wide State

#### AppSettingsBloc
**Responsibility**: Manage app settings
**State**: `AppSettingsState`
**Operations**:
- Update theme
- Update language
- Update units (metric/imperial)

#### ConnectivityBloc
**Responsibility**: Monitor network connectivity
**State**: `ConnectivityState` (online, offline)
**Operations**:
- Listen to connectivity changes
- Trigger offline mode

---

## State Management Best Practices

### 1. Single Source of Truth
- Each piece of state should have one authoritative source
- Derived state should be computed, not stored
- Use selectors/computed properties for derived data

### 2. Immutable State
- Never mutate state objects directly
- Always create new state objects for updates
- Use `copyWith` methods or immutable collections

```dart
// Good
state = state.copyWith(tripName: newName);

// Bad
state.tripName = newName; // DON'T DO THIS
```

### 3. Error Handling
- Always include error states in your state classes
- Provide meaningful error messages
- Log errors for debugging

### 4. Loading States
- Show loading indicators during async operations
- Provide feedback for user actions
- Use optimistic updates where appropriate

### 5. State Persistence
- Persist critical state to local storage
- Restore state on app restart
- Clear stale state appropriately

---

## Integration with UI

### Using Providers in Widgets

```dart
class TripDetailScreen extends ConsumerWidget {
  final String tripId;
  
  const TripDetailScreen({required this.tripId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripDetailProvider(tripId));
    
    return Scaffold(
      appBar: AppBar(title: Text('Trip Details')),
      body: state.when(
        initial: () => Center(child: Text('Loading...')),
        loading: () => Center(child: CircularProgressIndicator()),
        loaded: (trip, waypoints) => TripDetailContent(
          trip: trip,
          waypoints: waypoints,
        ),
        error: (message) => Center(child: Text('Error: $message')),
      ),
    );
  }
}
```

### Dispatching Actions

```dart
// In a widget
class AddWaypointButton extends ConsumerWidget {
  final String tripId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final bloc = ref.read(tripDetailProvider(tripId).notifier);
        final waypoint = await _showAddWaypointDialog(context);
        if (waypoint != null) {
          await bloc.addWaypoint(waypoint);
        }
      },
      child: Text('Add Waypoint'),
    );
  }
}
```

---

## Testing Strategy

### Unit Testing BLoCs

```dart
void main() {
  group('TripDetailBloc', () {
    late MockTripRepository mockRepository;
    late TripDetailBloc bloc;
    
    setUp(() {
      mockRepository = MockTripRepository();
      bloc = TripDetailBloc(mockRepository);
    });
    
    test('initial state is TripDetailInitial', () {
      expect(bloc.state, isA<TripDetailInitial>());
    });
    
    test('loadTrip emits loading then loaded states', () async {
      final trip = Trip(id: '1', name: 'Test Trip');
      when(mockRepository.getTripById('1'))
          .thenAnswer((_) async => trip);
      when(mockRepository.getWaypointsByTripId('1'))
          .thenAnswer((_) async => []);
      
      await bloc.loadTrip('1');
      
      expect(bloc.state, isA<TripDetailLoaded>());
      expect((bloc.state as TripDetailLoaded).trip, equals(trip));
    });
  });
}
```

### Widget Testing with Providers

```dart
testWidgets('TripDetailScreen shows trip name', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tripDetailProvider('1').overrideWith((ref) {
          return MockTripDetailBloc();
        }),
      ],
      child: MaterialApp(
        home: TripDetailScreen(tripId: '1'),
      ),
    ),
  );
  
  expect(find.text('Test Trip'), findsOneWidget);
});
```

---

## Performance Considerations

### 1. Provider Scope
- Keep provider scope as narrow as possible
- Use `.select()` to listen to specific parts of state
- Avoid rebuilding entire widget trees

```dart
// Only rebuild when trip name changes
final tripName = ref.watch(
  tripDetailProvider(tripId).select((state) {
    return state.maybeWhen(
      loaded: (trip, _) => trip.name,
      orElse: () => '',
    );
  }),
);
```

### 2. Debouncing
- Debounce rapid state updates (e.g., search input)
- Use `Stream.debounceTime()` for user input

### 3. Pagination
- Implement pagination for large lists
- Load data incrementally
- Use infinite scroll where appropriate

### 4. Caching
- Cache computed values
- Avoid recalculating expensive operations
- Clear cache when data changes

---

## Migration Path

### Phase 1: Foundation (MVP)
- Set up Riverpod
- Implement core BLoCs (Trip, Waypoint)
- Basic state management for map

### Phase 2: Enhancement
- Add advanced BLoCs (Route calculation, preferences)
- Implement state persistence
- Add optimistic updates

### Phase 3: Optimization
- Performance tuning
- Advanced caching strategies
- State normalization for complex relationships

---

## Resources

- [Riverpod Documentation](https://riverpod.dev/)
- [BLoC Pattern Guide](https://bloclibrary.dev/)
- [Flutter State Management Options](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options)
- [Provider Migration to Riverpod](https://riverpod.dev/docs/from_provider/motivation)
