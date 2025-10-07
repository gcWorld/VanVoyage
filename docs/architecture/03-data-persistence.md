# Data Persistence Strategy

This document outlines the data persistence architecture for VanVoyage, including database schema, data access patterns, and offline capabilities.

## Overview

VanVoyage uses **SQLite** as the primary local database for offline-first data persistence. This choice enables:
- Full offline functionality
- Fast local data access
- No dependency on network connectivity
- Complete data privacy (all data stored locally)

## Database Architecture

### Technology Stack

- **Database Engine**: SQLite 3
- **Flutter Package**: `sqflite` (official SQLite plugin)
- **Migration Management**: Custom migration system
- **Query Builder**: Raw SQL with parameterized queries
- **Serialization**: Manual mapping with `fromJson`/`toJson`

### Database Location
- **Android**: `/data/data/com.vanvoyage.app/databases/vanvoyage.db`
- **iOS**: `Documents/vanvoyage.db`

---

## Database Schema

### Version 1 - Initial Schema

#### Table: trips

```sql
CREATE TABLE trips (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  start_date INTEGER NOT NULL,  -- Unix timestamp (milliseconds)
  end_date INTEGER NOT NULL,    -- Unix timestamp (milliseconds)
  status TEXT NOT NULL CHECK(status IN ('PLANNING', 'ACTIVE', 'COMPLETED', 'ARCHIVED')),
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX idx_trips_status ON trips(status);
CREATE INDEX idx_trips_start_date ON trips(start_date);
CREATE INDEX idx_trips_updated_at ON trips(updated_at);
```

---

#### Table: trip_phases

```sql
CREATE TABLE trip_phases (
  id TEXT PRIMARY KEY,
  trip_id TEXT NOT NULL,
  name TEXT NOT NULL,
  phase_type TEXT NOT NULL CHECK(phase_type IN ('OUTBOUND', 'EXPLORATION', 'RETURN')),
  start_date INTEGER NOT NULL,
  end_date INTEGER NOT NULL,
  sequence_order INTEGER NOT NULL,
  FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
);

CREATE INDEX idx_trip_phases_trip_id ON trip_phases(trip_id);
CREATE INDEX idx_trip_phases_sequence ON trip_phases(trip_id, sequence_order);
CREATE UNIQUE INDEX idx_trip_phases_unique_order ON trip_phases(trip_id, sequence_order);
```

---

#### Table: waypoints

```sql
CREATE TABLE waypoints (
  id TEXT PRIMARY KEY,
  trip_id TEXT NOT NULL,
  phase_id TEXT,
  name TEXT NOT NULL,
  description TEXT,
  latitude REAL NOT NULL CHECK(latitude >= -90 AND latitude <= 90),
  longitude REAL NOT NULL CHECK(longitude >= -180 AND longitude <= 180),
  address TEXT,
  waypoint_type TEXT NOT NULL CHECK(waypoint_type IN ('OVERNIGHT_STAY', 'POI', 'TRANSIT')),
  arrival_date INTEGER,
  departure_date INTEGER,
  stay_duration INTEGER,
  sequence_order INTEGER NOT NULL,
  estimated_driving_time INTEGER,
  estimated_distance REAL,
  FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE,
  FOREIGN KEY (phase_id) REFERENCES trip_phases(id) ON DELETE SET NULL
);

CREATE INDEX idx_waypoints_trip_id ON waypoints(trip_id);
CREATE INDEX idx_waypoints_phase_id ON waypoints(phase_id);
CREATE INDEX idx_waypoints_sequence ON waypoints(trip_id, sequence_order);
CREATE INDEX idx_waypoints_location ON waypoints(latitude, longitude);
CREATE UNIQUE INDEX idx_waypoints_unique_order ON waypoints(trip_id, sequence_order);
```

---

#### Table: activities

```sql
CREATE TABLE activities (
  id TEXT PRIMARY KEY,
  waypoint_id TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL CHECK(category IN ('SIGHTSEEING', 'HIKING', 'DINING', 'SHOPPING', 'CULTURAL', 'OUTDOOR', 'RELAXATION', 'OTHER')),
  estimated_duration INTEGER,
  cost REAL,
  priority TEXT NOT NULL CHECK(priority IN ('HIGH', 'MEDIUM', 'LOW')),
  notes TEXT,
  is_completed INTEGER NOT NULL DEFAULT 0 CHECK(is_completed IN (0, 1)),
  FOREIGN KEY (waypoint_id) REFERENCES waypoints(id) ON DELETE CASCADE
);

CREATE INDEX idx_activities_waypoint_id ON activities(waypoint_id);
CREATE INDEX idx_activities_priority ON activities(priority);
CREATE INDEX idx_activities_completed ON activities(is_completed);
```

---

#### Table: trip_preferences

```sql
CREATE TABLE trip_preferences (
  id TEXT PRIMARY KEY,
  trip_id TEXT NOT NULL UNIQUE,
  max_daily_driving_distance INTEGER NOT NULL DEFAULT 300,
  max_daily_driving_time INTEGER NOT NULL DEFAULT 240,
  preferred_driving_speed INTEGER NOT NULL DEFAULT 80,
  include_rest_stops INTEGER NOT NULL DEFAULT 1 CHECK(include_rest_stops IN (0, 1)),
  rest_stop_interval INTEGER DEFAULT 120,
  avoid_tolls INTEGER NOT NULL DEFAULT 0 CHECK(avoid_tolls IN (0, 1)),
  avoid_highways INTEGER NOT NULL DEFAULT 0 CHECK(avoid_highways IN (0, 1)),
  prefer_scenic_routes INTEGER NOT NULL DEFAULT 0 CHECK(prefer_scenic_routes IN (0, 1)),
  FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX idx_trip_preferences_trip_id ON trip_preferences(trip_id);
```

---

#### Table: routes

```sql
CREATE TABLE routes (
  id TEXT PRIMARY KEY,
  trip_id TEXT NOT NULL,
  from_waypoint_id TEXT NOT NULL,
  to_waypoint_id TEXT NOT NULL,
  geometry TEXT NOT NULL,  -- GeoJSON LineString
  distance REAL NOT NULL,
  duration INTEGER NOT NULL,
  calculated_at INTEGER NOT NULL,
  route_provider TEXT NOT NULL,
  FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE,
  FOREIGN KEY (from_waypoint_id) REFERENCES waypoints(id) ON DELETE CASCADE,
  FOREIGN KEY (to_waypoint_id) REFERENCES waypoints(id) ON DELETE CASCADE
);

CREATE INDEX idx_routes_trip_id ON routes(trip_id);
CREATE INDEX idx_routes_waypoints ON routes(from_waypoint_id, to_waypoint_id);
CREATE INDEX idx_routes_calculated_at ON routes(calculated_at);
```

---

## Data Access Layer

### Repository Pattern

All database access goes through repository classes that abstract the data source implementation.

#### Base Repository Interface

```dart
abstract class Repository<T> {
  Future<T?> findById(String id);
  Future<List<T>> findAll();
  Future<String> insert(T entity);
  Future<int> update(T entity);
  Future<int> delete(String id);
}
```

---

### Repository Implementations

#### TripRepository

```dart
class TripRepository implements Repository<Trip> {
  final Database _db;
  
  TripRepository(this._db);
  
  @override
  Future<Trip?> findById(String id) async {
    final results = await _db.query(
      'trips',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (results.isEmpty) return null;
    return Trip.fromMap(results.first);
  }
  
  @override
  Future<List<Trip>> findAll() async {
    final results = await _db.query(
      'trips',
      orderBy: 'updated_at DESC',
    );
    
    return results.map((map) => Trip.fromMap(map)).toList();
  }
  
  Future<List<Trip>> findByStatus(TripStatus status) async {
    final results = await _db.query(
      'trips',
      where: 'status = ?',
      whereArgs: [status.toString().split('.').last],
      orderBy: 'start_date DESC',
    );
    
    return results.map((map) => Trip.fromMap(map)).toList();
  }
  
  @override
  Future<String> insert(Trip trip) async {
    await _db.insert(
      'trips',
      trip.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return trip.id;
  }
  
  @override
  Future<int> update(Trip trip) async {
    return await _db.update(
      'trips',
      trip.toMap(),
      where: 'id = ?',
      whereArgs: [trip.id],
    );
  }
  
  @override
  Future<int> delete(String id) async {
    return await _db.delete(
      'trips',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Complex queries
  Future<Trip?> findTripWithDetails(String id) async {
    final trip = await findById(id);
    if (trip == null) return null;
    
    // Load related data
    final phases = await _loadPhases(id);
    final waypoints = await _loadWaypoints(id);
    final preferences = await _loadPreferences(id);
    
    return trip.copyWith(
      phases: phases,
      waypoints: waypoints,
      preferences: preferences,
    );
  }
}
```

#### WaypointRepository

```dart
class WaypointRepository implements Repository<Waypoint> {
  final Database _db;
  
  WaypointRepository(this._db);
  
  Future<List<Waypoint>> findByTripId(String tripId) async {
    final results = await _db.query(
      'waypoints',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'sequence_order ASC',
    );
    
    return results.map((map) => Waypoint.fromMap(map)).toList();
  }
  
  Future<List<Waypoint>> findByPhaseId(String phaseId) async {
    final results = await _db.query(
      'waypoints',
      where: 'phase_id = ?',
      whereArgs: [phaseId],
      orderBy: 'sequence_order ASC',
    );
    
    return results.map((map) => Waypoint.fromMap(map)).toList();
  }
  
  Future<void> reorderWaypoints(String tripId, List<String> waypointIds) async {
    await _db.transaction((txn) async {
      for (int i = 0; i < waypointIds.length; i++) {
        await txn.update(
          'waypoints',
          {'sequence_order': i},
          where: 'id = ? AND trip_id = ?',
          whereArgs: [waypointIds[i], tripId],
        );
      }
    });
  }
  
  // Implement other CRUD methods...
}
```

---

## Database Initialization & Migration

### Database Provider

```dart
class DatabaseProvider {
  static Database? _database;
  static const String DB_NAME = 'vanvoyage.db';
  static const int DB_VERSION = 1;
  
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DB_NAME);
    
    return await openDatabase(
      path,
      version: DB_VERSION,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }
  
  static Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }
  
  static Future<void> _onCreate(Database db, int version) async {
    await _createTablesV1(db);
  }
  
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Future migrations will go here
    if (oldVersion < 2) {
      // Upgrade to version 2
    }
  }
  
  static Future<void> _createTablesV1(Database db) async {
    // Create all tables
    await db.execute('''
      CREATE TABLE trips (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        -- ... rest of schema
      )
    ''');
    
    // Create all indexes
    await db.execute('CREATE INDEX idx_trips_status ON trips(status)');
    
    // ... create other tables and indexes
  }
}
```

---

## Migration Strategy

### Version Management

Each schema change increments the database version number:

| Version | Changes | Migration Strategy |
|---------|---------|-------------------|
| 1 | Initial schema | Create all tables |
| 2 | Add user preferences table | ALTER TABLE / INSERT |
| 3 | Add weather forecast table | CREATE TABLE |

### Migration Scripts

```dart
// Example: Adding a new column in version 2
static Future<void> _migrateV1toV2(Database db) async {
  await db.execute('''
    ALTER TABLE trips 
    ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0
  ''');
  
  await db.execute('''
    CREATE INDEX idx_trips_favorite ON trips(is_favorite)
  ''');
}
```

---

## Transaction Management

### Atomic Operations

Use transactions for operations that must be atomic:

```dart
Future<void> createTripWithDefaults(Trip trip) async {
  final db = await DatabaseProvider.database;
  
  await db.transaction((txn) async {
    // Insert trip
    await txn.insert('trips', trip.toMap());
    
    // Insert default preferences
    final preferences = TripPreferences.defaults(trip.id);
    await txn.insert('trip_preferences', preferences.toMap());
    
    // Insert initial waypoints if any
    for (final waypoint in trip.waypoints) {
      await txn.insert('waypoints', waypoint.toMap());
    }
  });
}
```

### Error Handling

```dart
try {
  await db.transaction((txn) async {
    // Database operations
  });
} on DatabaseException catch (e) {
  if (e.isUniqueConstraintError()) {
    throw DuplicateEntityException('Trip already exists');
  } else if (e.isForeignKeyConstraintError()) {
    throw InvalidReferenceException('Referenced entity not found');
  }
  rethrow;
}
```

---

## Data Serialization

### Entity Mapping

Each entity class implements `toMap()` and `fromMap()`:

```dart
class Trip {
  final String id;
  final String name;
  final DateTime startDate;
  // ... other fields
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate.millisecondsSinceEpoch,
      'status': status.toString().split('.').last,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
  
  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'],
      name: map['name'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date']),
      status: TripStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }
}
```

---

## Query Optimization

### Indexing Strategy

1. **Primary Keys**: All tables have indexed primary keys
2. **Foreign Keys**: All foreign key columns are indexed
3. **Query Columns**: Columns used in WHERE clauses are indexed
4. **Sort Columns**: Columns used in ORDER BY are indexed

### Query Performance Tips

1. **Use Parameterized Queries**: Always use `whereArgs` for dynamic values
2. **Limit Results**: Use `limit` and `offset` for pagination
3. **Select Specific Columns**: Don't use `SELECT *` unnecessarily
4. **Batch Operations**: Use transactions for multiple inserts/updates
5. **Analyze Queries**: Use `EXPLAIN QUERY PLAN` to optimize slow queries

```dart
// Good: Specific columns, indexed WHERE clause
final results = await db.query(
  'waypoints',
  columns: ['id', 'name', 'latitude', 'longitude'],
  where: 'trip_id = ?',
  whereArgs: [tripId],
  limit: 50,
);

// Bad: SELECT *, no indexes used
final results = await db.rawQuery(
  'SELECT * FROM waypoints WHERE name LIKE "%${searchTerm}%"',
);
```

---

## Backup & Restore

### Export Data

```dart
Future<File> exportDatabase() async {
  final db = await DatabaseProvider.database;
  final dbPath = db.path;
  
  final timestamp = DateTime.now().toIso8601String();
  final exportPath = join(
    await getApplicationDocumentsDirectory(),
    'backups',
    'vanvoyage_backup_$timestamp.db',
  );
  
  await File(dbPath).copy(exportPath);
  return File(exportPath);
}
```

### Import Data

```dart
Future<void> importDatabase(File backupFile) async {
  final db = await DatabaseProvider.database;
  await db.close();
  
  final dbPath = await getDatabasesPath();
  final targetPath = join(dbPath, DatabaseProvider.DB_NAME);
  
  await backupFile.copy(targetPath);
  
  // Reopen database
  DatabaseProvider._database = null;
  await DatabaseProvider.database;
}
```

---

## Data Validation

### Database Constraints

- **NOT NULL**: Enforced at database level
- **CHECK**: Used for enum values and ranges
- **UNIQUE**: Ensures data integrity
- **FOREIGN KEY**: Maintains referential integrity

### Application-Level Validation

```dart
class TripValidator {
  static void validate(Trip trip) {
    if (trip.name.isEmpty) {
      throw ValidationException('Trip name cannot be empty');
    }
    
    if (trip.endDate.isBefore(trip.startDate)) {
      throw ValidationException('End date must be after start date');
    }
    
    if (trip.waypoints.isEmpty) {
      throw ValidationException('Trip must have at least one waypoint');
    }
  }
}
```

---

## Future Enhancements

### Cloud Synchronization
- Add `sync_status` column to track changes
- Implement conflict resolution strategy
- Use incremental sync with timestamps

### Full-Text Search
```sql
CREATE VIRTUAL TABLE trips_fts USING fts5(
  name, 
  description, 
  content=trips
);
```

### Spatial Queries
- Consider using SQLite's R*Tree module for geographic queries
- Optimize waypoint proximity searches

### Encryption
- Implement SQLCipher for encrypted database
- Protect sensitive user data

---

## Testing Strategy

### Unit Tests

```dart
test('insert and retrieve trip', () async {
  final db = await createTestDatabase();
  final repository = TripRepository(db);
  
  final trip = Trip(
    id: 'test-1',
    name: 'Test Trip',
    // ...
  );
  
  await repository.insert(trip);
  final retrieved = await repository.findById('test-1');
  
  expect(retrieved, isNotNull);
  expect(retrieved!.name, equals('Test Trip'));
});
```

### Integration Tests

```dart
testWidgets('full trip creation flow', (tester) async {
  // Test complete user journey from UI to database
});
```

---

## Performance Benchmarks

Target performance metrics:
- **Trip List Load**: < 100ms for 100 trips
- **Trip Detail Load**: < 50ms with 20 waypoints
- **Waypoint Insert**: < 20ms
- **Route Calculation Storage**: < 30ms
- **Full Database Query**: < 500ms for complex joins

---

## References

- [sqflite Documentation](https://pub.dev/packages/sqflite)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Flutter Database Best Practices](https://flutter.dev/docs/cookbook/persistence/sqlite)
