import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Database provider for managing SQLite database initialization and migrations.
class DatabaseProvider {
  static Database? _database;
  static const String dbName = 'vanvoyage.db';
  static const int dbVersion = 2;

  /// Gets the database instance, initializing if necessary
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Configures database settings
  static Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Creates database tables on first initialization
  static Future<void> _onCreate(Database db, int version) async {
    await _createTablesV1(db);
    await _createTablesV2(db);
  }

  /// Handles database upgrades
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Future migrations will go here
    if (oldVersion < 2) {
      // Upgrade to version 2: Add settings and vehicles tables
      await _createTablesV2(db);
    }
  }

  /// Creates version 1 schema
  static Future<void> _createTablesV1(Database db) async {
    // Create trips table
    await db.execute('''
      CREATE TABLE trips (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        status TEXT NOT NULL CHECK(status IN ('PLANNING', 'ACTIVE', 'COMPLETED', 'ARCHIVED')),
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create trip_phases table
    await db.execute('''
      CREATE TABLE trip_phases (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        name TEXT NOT NULL,
        phase_type TEXT NOT NULL CHECK(phase_type IN ('OUTBOUND', 'EXPLORATION', 'RETURN')),
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        sequence_order INTEGER NOT NULL,
        FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
      )
    ''');

    // Create waypoints table
    await db.execute('''
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
      )
    ''');

    // Create activities table
    await db.execute('''
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
      )
    ''');

    // Create trip_preferences table
    await db.execute('''
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
      )
    ''');

    // Create routes table
    await db.execute('''
      CREATE TABLE routes (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        from_waypoint_id TEXT NOT NULL,
        to_waypoint_id TEXT NOT NULL,
        geometry TEXT NOT NULL,
        distance REAL NOT NULL,
        duration INTEGER NOT NULL,
        calculated_at INTEGER NOT NULL,
        route_provider TEXT NOT NULL,
        FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE,
        FOREIGN KEY (from_waypoint_id) REFERENCES waypoints(id) ON DELETE CASCADE,
        FOREIGN KEY (to_waypoint_id) REFERENCES waypoints(id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for trips
    await db.execute('CREATE INDEX idx_trips_status ON trips(status)');
    await db.execute('CREATE INDEX idx_trips_start_date ON trips(start_date)');
    await db.execute('CREATE INDEX idx_trips_updated_at ON trips(updated_at)');

    // Create indexes for trip_phases
    await db.execute('CREATE INDEX idx_trip_phases_trip_id ON trip_phases(trip_id)');
    await db.execute('CREATE INDEX idx_trip_phases_sequence ON trip_phases(trip_id, sequence_order)');
    await db.execute('CREATE UNIQUE INDEX idx_trip_phases_unique_order ON trip_phases(trip_id, sequence_order)');

    // Create indexes for waypoints
    await db.execute('CREATE INDEX idx_waypoints_trip_id ON waypoints(trip_id)');
    await db.execute('CREATE INDEX idx_waypoints_phase_id ON waypoints(phase_id)');
    await db.execute('CREATE INDEX idx_waypoints_sequence ON waypoints(trip_id, sequence_order)');
    await db.execute('CREATE INDEX idx_waypoints_location ON waypoints(latitude, longitude)');
    await db.execute('CREATE UNIQUE INDEX idx_waypoints_unique_order ON waypoints(trip_id, sequence_order)');

    // Create indexes for activities
    await db.execute('CREATE INDEX idx_activities_waypoint_id ON activities(waypoint_id)');
    await db.execute('CREATE INDEX idx_activities_priority ON activities(priority)');
    await db.execute('CREATE INDEX idx_activities_completed ON activities(is_completed)');

    // Create indexes for trip_preferences
    await db.execute('CREATE UNIQUE INDEX idx_trip_preferences_trip_id ON trip_preferences(trip_id)');

    // Create indexes for routes
    await db.execute('CREATE INDEX idx_routes_trip_id ON routes(trip_id)');
    await db.execute('CREATE INDEX idx_routes_waypoints ON routes(from_waypoint_id, to_waypoint_id)');
    await db.execute('CREATE INDEX idx_routes_calculated_at ON routes(calculated_at)');
  }

  /// Creates version 2 schema (settings and vehicles)
  static Future<void> _createTablesV2(Database db) async {
    // Create vehicles table
    await db.execute('''
      CREATE TABLE vehicles (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        fuel_type TEXT NOT NULL CHECK(fuel_type IN ('GASOLINE', 'DIESEL', 'ELECTRIC', 'HYBRID', 'LPG')),
        fuel_consumption REAL NOT NULL CHECK(fuel_consumption > 0),
        height REAL CHECK(height IS NULL OR (height > 0 AND height <= 10)),
        width REAL CHECK(width IS NULL OR (width > 0 AND width <= 10)),
        length REAL CHECK(length IS NULL OR (length > 0 AND length <= 30)),
        weight REAL CHECK(weight IS NULL OR (weight > 0 AND weight <= 100)),
        max_speed INTEGER CHECK(max_speed IS NULL OR (max_speed > 0 AND max_speed <= 200)),
        is_default INTEGER NOT NULL DEFAULT 0 CHECK(is_default IN (0, 1)),
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create app_settings table (single row)
    await db.execute('''
      CREATE TABLE app_settings (
        id TEXT PRIMARY KEY DEFAULT 'default',
        home_location_name TEXT,
        home_location_latitude REAL CHECK(home_location_latitude IS NULL OR (home_location_latitude >= -90 AND home_location_latitude <= 90)),
        home_location_longitude REAL CHECK(home_location_longitude IS NULL OR (home_location_longitude >= -180 AND home_location_longitude <= 180)),
        home_location_address TEXT,
        default_vehicle_id TEXT,
        distance_unit TEXT NOT NULL DEFAULT 'km' CHECK(distance_unit IN ('km', 'mi')),
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (default_vehicle_id) REFERENCES vehicles(id) ON DELETE SET NULL
      )
    ''');

    // Create indexes for vehicles
    await db.execute('CREATE INDEX idx_vehicles_is_default ON vehicles(is_default)');
    await db.execute('CREATE INDEX idx_vehicles_name ON vehicles(name)');

    // Insert default settings row
    await db.execute('''
      INSERT INTO app_settings (id, distance_unit, updated_at) 
      VALUES ('default', 'km', ${DateTime.now().millisecondsSinceEpoch})
    ''');
  }

  /// Closes the database
  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Deletes the database (for testing purposes)
  static Future<void> deleteDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    await deleteDatabase(path);
    _database = null;
  }
}
