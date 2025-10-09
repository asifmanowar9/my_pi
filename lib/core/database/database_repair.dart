import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_helper_clean.dart';

/// Utility class to repair and reset database
class DatabaseRepair {
  static Future<void> resetDatabase() async {
    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      print('🔧 Starting database repair...');

      // Get all table names
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );

      print('📋 Found tables: ${tables.map((t) => t['name']).join(', ')}');

      // Drop all tables
      for (final table in tables) {
        final tableName = table['name'] as String;
        print('🗑️ Dropping table: $tableName');
        await db.execute('DROP TABLE IF EXISTS $tableName');
      }

      print('✅ All tables dropped');

      // Close database
      await db.close();

      print('🔄 Recreating database with correct schema...');

      // Delete the database file to force recreation
      await deleteDatabase(db.path);

      print('✅ Database reset complete! Restart the app.');
    } catch (e) {
      print('❌ Failed to reset database: $e');
    }
  }

  static Future<void> checkDatabaseSchema() async {
    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      print('\n📊 DATABASE SCHEMA CHECK\n${'=' * 50}');

      // Get all tables
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );

      for (final table in tables) {
        final tableName = table['name'] as String;
        print('\n📋 Table: $tableName');

        // Get columns for this table
        final columns = await db.rawQuery('PRAGMA table_info($tableName)');

        for (final column in columns) {
          print(
            '  └─ ${column['name']} (${column['type']}) ${column['notnull'] == 1 ? 'NOT NULL' : ''} ${column['dflt_value'] != null ? 'DEFAULT ${column['dflt_value']}' : ''}',
          );
        }
      }

      print('\n${'=' * 50}\n');
    } catch (e) {
      print('❌ Failed to check schema: $e');
    }
  }
}
