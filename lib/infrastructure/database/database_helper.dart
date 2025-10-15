import 'package:sqflite/sqflite.dart';
import 'database_provider.dart';

/// Helper class for database operations
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  
  DatabaseHelper._internal();
  
  /// Gets the database instance
  Future<Database> get database async {
    return await DatabaseProvider.database;
  }
}
