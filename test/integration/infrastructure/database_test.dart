import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vanvoyage/infrastructure/database/database_provider.dart';

void main() {
  // Initialize FFI for testing
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Initialize sqflite once at the start
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseProvider', () {
    setUp(() async {
      // Clean up any existing test database
      await DatabaseProvider.close();
      await DatabaseProvider.deleteDb();
    });

    tearDown(() async {
      // Clean up after each test
      await DatabaseProvider.close();
      await DatabaseProvider.deleteDb();
    });

    test('should initialize database successfully', () async {
      final db = await DatabaseProvider.database;
      expect(db, isNotNull);
      expect(db.isOpen, true);
    });

    test('should create all required tables', () async {
      final db = await DatabaseProvider.database;

      // Check if tables exist
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );

      final tableNames = tables.map((t) => t['name'] as String).toList();

      expect(tableNames, contains('trips'));
      expect(tableNames, contains('trip_phases'));
      expect(tableNames, contains('waypoints'));
      expect(tableNames, contains('activities'));
      expect(tableNames, contains('trip_preferences'));
      expect(tableNames, contains('routes'));
    });

    test('should create indexes for trips table', () async {
      final db = await DatabaseProvider.database;

      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='trips'",
      );

      final indexNames = indexes.map((i) => i['name'] as String).toList();

      expect(indexNames, contains('idx_trips_status'));
      expect(indexNames, contains('idx_trips_start_date'));
      expect(indexNames, contains('idx_trips_updated_at'));
    });

    test('should enforce foreign key constraints', () async {
      final db = await DatabaseProvider.database;

      // Check if foreign keys are enabled
      final result = await db.rawQuery('PRAGMA foreign_keys');
      expect(result.first['foreign_keys'], 1);
    });

    test('should return same database instance on multiple calls', () async {
      final db1 = await DatabaseProvider.database;
      final db2 = await DatabaseProvider.database;

      expect(identical(db1, db2), true);
    });
  });
}
