import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'materku.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE materials(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        subject TEXT NOT NULL,
        type TEXT NOT NULL,
        filePath TEXT NOT NULL,
        uploadedBy TEXT NOT NULL,
        uploadDate TEXT NOT NULL,
        downloadCount INTEGER DEFAULT 0,
        isFavorite INTEGER DEFAULT 0,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE downloads(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        materialId INTEGER NOT NULL,
        materialTitle TEXT NOT NULL,
        downloadDate TEXT NOT NULL,
        FOREIGN KEY (materialId) REFERENCES materials (id)
      )
    ''');
  }

  // Insert material
  Future<int> insertMaterial(Map<String, dynamic> material) async {
    final db = await database;
    return await db.insert('materials', material);
  }

  // Get all materials
  Future<List<Map<String, dynamic>>> getAllMaterials() async {
    final db = await database;
    return await db.query('materials', orderBy: 'uploadDate DESC');
  }

  // Update material
  Future<int> updateMaterial(Map<String, dynamic> material) async {
    final db = await database;
    return await db.update(
      'materials',
      material,
      where: 'id = ?',
      whereArgs: [material['id']],
    );
  }

  // Delete material
  Future<int> deleteMaterial(int id) async {
    final db = await database;
    return await db.delete(
      'materials',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Insert download record
  Future<int> insertDownload(Map<String, dynamic> download) async {
    final db = await database;
    return await db.insert('downloads', download);
  }

  // Get all downloads
  Future<List<Map<String, dynamic>>> getAllDownloads() async {
    final db = await database;
    return await db.query('downloads', orderBy: 'downloadDate DESC');
  }

  // Delete download record
  Future<int> deleteDownload(int id) async {
    final db = await database;
    return await db.delete(
      'downloads',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear all downloads
  Future<int> clearAllDownloads() async {
    final db = await database;
    return await db.delete('downloads');
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}