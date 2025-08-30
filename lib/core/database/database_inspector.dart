import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';

class DatabaseInspector {
  static final DatabaseInspector _instance = DatabaseInspector._internal();
  factory DatabaseInspector() => _instance;
  DatabaseInspector._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Get all table names in the database
  Future<List<String>> getTableNames() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );
    return result.map((row) => row['name'] as String).toList();
  }

  /// Get table schema information
  Future<List<Map<String, dynamic>>> getTableSchema(String tableName) async {
    final db = await _dbHelper.database;
    return await db.rawQuery("PRAGMA table_info('$tableName')");
  }

  /// Get all data from a specific table
  Future<List<Map<String, dynamic>>> getTableData(String tableName) async {
    final db = await _dbHelper.database;
    return await db.query(tableName);
  }

  /// Get table row count
  Future<int> getTableRowCount(String tableName) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM $tableName",
    );
    return result.first['count'] as int;
  }

  /// Print database overview
  Future<void> printDatabaseOverview() async {
    try {
      debugPrint('=== DATABASE OVERVIEW ===');

      final tables = await getTableNames();
      debugPrint('Tables found: ${tables.length}');

      for (String table in tables) {
        final rowCount = await getTableRowCount(table);
        debugPrint('- $table: $rowCount rows');
      }

      debugPrint('========================');
    } catch (e) {
      debugPrint('Error inspecting database: $e');
    }
  }

  /// Print detailed table information
  Future<void> printTableDetails(String tableName) async {
    try {
      debugPrint('=== TABLE: $tableName ===');

      // Print schema
      final schema = await getTableSchema(tableName);
      debugPrint('Schema:');
      for (var column in schema) {
        debugPrint(
          '  ${column['name']}: ${column['type']} ${column['notnull'] == 1 ? 'NOT NULL' : ''} ${column['pk'] == 1 ? 'PRIMARY KEY' : ''}',
        );
      }

      // Print data
      final data = await getTableData(tableName);
      debugPrint('Data (${data.length} rows):');

      if (data.isEmpty) {
        debugPrint('  No data found');
      } else {
        for (var i = 0; i < data.length && i < 10; i++) {
          // Limit to first 10 rows
          debugPrint('  Row ${i + 1}: ${data[i]}');
        }
        if (data.length > 10) {
          debugPrint('  ... and ${data.length - 10} more rows');
        }
      }

      debugPrint('====================');
    } catch (e) {
      debugPrint('Error inspecting table $tableName: $e');
    }
  }

  /// Print all database content
  Future<void> printFullDatabase() async {
    try {
      await printDatabaseOverview();

      final tables = await getTableNames();
      for (String table in tables) {
        await printTableDetails(table);
      }
    } catch (e) {
      debugPrint('Error printing full database: $e');
    }
  }

  /// Export database as JSON-like string for debugging
  Future<Map<String, dynamic>> exportDatabaseAsMap() async {
    final result = <String, dynamic>{};

    try {
      final tables = await getTableNames();

      for (String table in tables) {
        final data = await getTableData(table);
        result[table] = data;
      }
    } catch (e) {
      result['error'] = e.toString();
    }

    return result;
  }

  /// Execute custom SQL query (for debugging)
  Future<List<Map<String, dynamic>>> executeQuery(String sql) async {
    final db = await _dbHelper.database;
    return await db.rawQuery(sql);
  }

  /// Clear all data from all tables (for testing)
  Future<void> clearAllData() async {
    try {
      final tables = await getTableNames();
      final db = await _dbHelper.database;

      for (String table in tables) {
        await db.delete(table);
        debugPrint('Cleared table: $table');
      }

      debugPrint('All tables cleared successfully');
    } catch (e) {
      debugPrint('Error clearing database: $e');
    }
  }

  /// Insert sample data for testing
  Future<void> insertSampleData() async {
    try {
      final db = await _dbHelper.database;

      // Insert sample user
      await db.insert('users', {
        'id': 'user_1',
        'email': 'student@example.com',
        'name': 'John Doe',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Insert sample course
      await db.insert('courses', {
        'id': 'course_1',
        'user_id': 'user_1',
        'name': 'Computer Science 101',
        'code': 'CS101',
        'credits': 3,
        'instructor': 'Dr. Smith',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Insert sample assignment
      await db.insert('assignments', {
        'id': 'assignment_1',
        'course_id': 'course_1',
        'title': 'Programming Assignment 1',
        'description': 'Create a simple calculator app',
        'due_date': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        'status': 'pending',
        'grade': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Insert sample grade
      await db.insert('grades', {
        'id': 'grade_1',
        'course_id': 'course_1',
        'assignment_id': 'assignment_1',
        'grade': 85.5,
        'max_grade': 100.0,
        'type': 'assignment',
        'date': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      debugPrint('Sample data inserted successfully');
    } catch (e) {
      debugPrint('Error inserting sample data: $e');
    }
  }
}
