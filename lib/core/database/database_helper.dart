import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../services/encryption_service.dart';

class DatabaseHelper {
  static const _dbName = 'lockpass.db';
  static const _dbVersion = 1;

  static DatabaseHelper? _instance;

  final String dbPassword;
  final EncryptionService encryptionService;
  Database? _database;

  DatabaseHelper._internal(this.dbPassword, this.encryptionService);

  static void init(String password) {
    final encryptionService = EncryptionService(password);
    _instance = DatabaseHelper._internal(password, encryptionService);
  }

  static DatabaseHelper get instance {
    if (_instance == null) {
      throw StateError(
          'DatabaseHelper not initialized. Call DatabaseHelper.init(password) first.');
    }
    return _instance!;
  }

  static Future<void> reset() async {
    if (_instance?._database != null) {
      await _instance!._database!.close();
    }
    _instance = null;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      password: dbPassword,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE passwords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        email TEXT,
        password TEXT NOT NULL,
        website TEXT,
        created_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT,
        created_at INTEGER
      )
    ''');
  }
}
