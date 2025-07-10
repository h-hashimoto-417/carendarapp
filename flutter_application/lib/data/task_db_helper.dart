import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database.dart';

class TaskDBHelper {
  static final TaskDBHelper _instance = TaskDBHelper._internal();
  factory TaskDBHelper() => _instance;
  TaskDBHelper._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            deadline TEXT,
            requiredHours INTEGER,
            color INTEGER,
            repete INTEGER,
            comment TEXT,
            startTime TEXT,
            excepts TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE tasks ADD COLUMN excepts TEXT');
        }
      },
    );
  }

  Future<void> insertTask(Task task) async {
    final database = await db;
    await database.insert(
      'tasks',
      task.toMap(withoutId: true),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Task>> getTasks() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query('tasks');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<void> updateTask(Task task) async {
    final database = await db;
    await database.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(int id) async {
    final database = await db;
    await database.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
