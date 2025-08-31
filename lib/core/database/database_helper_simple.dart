import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelperSimple {
  static final DatabaseHelperSimple _instance =
      DatabaseHelperSimple._internal();
  static Database? _database;

  factory DatabaseHelperSimple() => _instance;

  DatabaseHelperSimple._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'my_pi_simple.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            email TEXT NOT NULL,
            name TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
