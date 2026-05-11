import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/game_state.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'broken_paths.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE saves (
        slot INTEGER PRIMARY KEY,
        currentChapter INTEGER,
        currentSceneId TEXT,
        unlockedChapter INTEGER,
        iman INTEGER,
        knowledge INTEGER,
        wealth INTEGER,
        respect INTEGER,
        coins INTEGER
      )
    ''');
  }

  Future<void> saveGame(int slot, GameState state) async {
    final db = await database;
    Map<String, dynamic> data = state.toJson();
    data['slot'] = slot;

    await db.insert(
      'saves',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<GameState?> loadGame(int slot) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saves',
      where: 'slot = ?',
      whereArgs: [slot],
    );

    if (maps.isNotEmpty) {
      return GameState.fromJson(maps.first);
    }
    return null;
  }
}
