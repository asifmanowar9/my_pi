import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Standalone database inspector for My Pi app
/// Run this script with: dart run db_inspector.dart
void main() async {
  print('🔍 My Pi Database Inspector');
  print('==========================');

  try {
    // Find the database file
    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, 'my_pi.db');

    print('Looking for database at: $dbPath');

    // Check if database exists
    if (!await File(dbPath).exists()) {
      print('❌ Database file not found!');
      print('Please run the My Pi app first to create the database.');
      return;
    }

    print('✅ Database found!');
    print('');

    // Open the database
    final db = await openDatabase(dbPath, version: 1);

    // Get all table names
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );

    if (tables.isEmpty) {
      print('❌ No tables found in the database.');
      await db.close();
      return;
    }

    print('📊 Database Overview:');
    print('Tables found: ${tables.length}');

    // Show overview of each table
    for (final table in tables) {
      final tableName = table['name'] as String;
      final count = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      final rowCount = count.first['count'] as int;
      print('  - $tableName: $rowCount rows');
    }

    print('');

    // Show detailed information for each table
    for (final table in tables) {
      final tableName = table['name'] as String;
      await _showTableDetails(db, tableName);
    }

    await db.close();
    print('🎉 Database inspection completed!');
  } catch (e) {
    print('❌ Error inspecting database: $e');
  }
}

Future<void> _showTableDetails(Database db, String tableName) async {
  print('📋 Table: $tableName');
  print('${'-' * (tableName.length + 9)}');

  try {
    // Get table schema
    final schema = await db.rawQuery("PRAGMA table_info('$tableName')");
    print('Schema:');
    for (final column in schema) {
      final name = column['name'];
      final type = column['type'];
      final notNull = column['notnull'] == 1 ? 'NOT NULL' : '';
      final pk = column['pk'] == 1 ? 'PRIMARY KEY' : '';
      print('  $name: $type $notNull $pk'.trim());
    }

    // Get table data
    final data = await db.query(tableName);
    print('');
    print('Data (${data.length} rows):');

    if (data.isEmpty) {
      print('  No data found');
    } else {
      // Show first few rows
      final maxRows = data.length > 5 ? 5 : data.length;
      for (int i = 0; i < maxRows; i++) {
        print('  Row ${i + 1}: ${_formatRow(data[i])}');
      }

      if (data.length > 5) {
        print('  ... and ${data.length - 5} more rows');
      }
    }

    print('');
  } catch (e) {
    print('❌ Error reading table $tableName: $e');
    print('');
  }
}

String _formatRow(Map<String, dynamic> row) {
  final formattedEntries = row.entries.map((entry) {
    var value = entry.value?.toString() ?? 'null';
    if (value.length > 50) {
      value = '${value.substring(0, 47)}...';
    }
    return '${entry.key}: $value';
  });
  return '{${formattedEntries.join(', ')}}';
}
