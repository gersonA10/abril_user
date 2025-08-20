import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DBHelper {
  DBHelper._internal();
  static final DBHelper instance = DBHelper._internal();

  static const _dbName = 'xploremore.db';
  static const _dbVersion = 1;
  static const _table = 'request_store';

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            request_id TEXT NOT NULL,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
    );
  }

  /// Guarda el último requestId (solo uno).
  Future<void> saveRequestId(String id) async {
    final db = await database;
    await db.delete(_table); // Mantener un solo registro
    await db.insert(_table, {'request_id': id});
  }

  /// Devuelve el requestId almacenado o null.
  Future<String?> getRequestId() async {
    final db = await database;
    final res = await db.query(_table, limit: 1);
    if (res.isNotEmpty) return res.first['request_id'] as String;
    return null;
  }

  Future<void> clearRequestId() async {
    final db = await database;
    await db.delete(_table);
  }
}
