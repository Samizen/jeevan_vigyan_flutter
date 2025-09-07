import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'jeevan_vigyan.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create the 'Members' table from the ERD
        await db.execute('''
          CREATE TABLE Members(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            contact_no TEXT,
            member_added_date TEXT NOT NULL
          )
        ''');

        // Create the 'Category' table from the ERD
        await db.execute('''
          CREATE TABLE Category(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            name TEXT NOT NULL
          )
        ''');

        // Create the 'Transaction' table from the ERD
        await db.execute('''
          CREATE TABLE Transaction(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            member_id INTEGER,
            amount REAL NOT NULL,
            category_id INTEGER NOT NULL,
            description TEXT,
            transaction_date TEXT NOT NULL,
            FOREIGN KEY (member_id) REFERENCES Members(id),
            FOREIGN KEY (category_id) REFERENCES Category(id)
          )
        ''');
      },
    );
  }

  // Placeholder methods for database operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(String table) async {
    final db = await database;
    return await db.query(table);
  }
}
