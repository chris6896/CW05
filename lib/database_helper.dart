import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "aquarium.db";
  static final _databaseVersion = 2; 

  static final tableSettings = 'settings';

  static final columnId = 'id'; 
  static final columnName = 'name'; 
  static final columnColor = 'color';
  static final columnSpeed = 'speed';
  static final columnFishCount = 'fish_count';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableSettings (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnColor INTEGER,
        $columnSpeed REAL,
        $columnFishCount INTEGER
      )
    ''');
  }

  Future<int> saveSettings(String name, int color, double speed, int fishCount) async {
    Database db = await instance.database;

    return await db.insert(tableSettings, {
      columnName: name,
      columnColor: color,
      columnSpeed: speed,
      columnFishCount: fishCount,
    });
  }

  Future<List<Map<String, dynamic>>> loadSettingsList() async {
    Database db = await instance.database;
    return await db.query(tableSettings);
  }

  Future<Map<String, dynamic>?> loadSettingsById(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      tableSettings,
      where: '$columnId = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }
}
