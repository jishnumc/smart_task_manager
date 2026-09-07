import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

part 'sqlite_database_client.g.dart';

@Riverpod(keepAlive: true)
SqliteDatabaseClient sqliteDatabaseClient(Ref ref) {
  return SqliteDatabaseClient();
}

/// Helper client for local SQLite database management.
class SqliteDatabaseClient {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'smart_task_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            remote_id TEXT,
            user_id TEXT,
            title TEXT NOT NULL,
            description TEXT,
            is_completed INTEGER NOT NULL DEFAULT 0,
            due_date TEXT,
            priority TEXT,
            category TEXT,
            is_synced INTEGER NOT NULL DEFAULT 0,
            created_at TEXT,
            updated_at TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertTask(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(
      'tasks',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getTasks({String? userId}) async {
    final db = await database;
    if (userId != null && userId.isNotEmpty) {
      return await db.query(
        'tasks',
        where: 'user_id = ? OR user_id IS NULL OR user_id = ""',
        whereArgs: [userId],
        orderBy: 'id DESC',
      );
    }
    return await db.query('tasks', orderBy: 'id DESC');
  }

  Future<int> updateTask(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(
      'tasks',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
