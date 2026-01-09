import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/material_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('materku.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE materials (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        subject TEXT NOT NULL,
        type TEXT NOT NULL,
        filePath TEXT NOT NULL,
        uploadedBy TEXT NOT NULL,
        uploadDate TEXT NOT NULL,
        downloadCount INTEGER NOT NULL,
        isFavorite INTEGER NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE downloads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        materialId INTEGER NOT NULL,
        downloadDate TEXT NOT NULL,
        FOREIGN KEY (materialId) REFERENCES materials (id)
      )
    ''');
  }

  // Materials CRUD
  Future<int> insertMaterial(MaterialModel material) async {
    final db = await database;
    return await db.insert('materials', material.toMap());
  }

  Future<List<MaterialModel>> getAllMaterials() async {
    final db = await database;
    final result = await db.query('materials', orderBy: 'uploadDate DESC');
    return result.map((json) => MaterialModel.fromMap(json)).toList();
  }

  Future<int> updateMaterial(MaterialModel material) async {
    final db = await database;
    return await db.update(
      'materials',
      material.toMap(),
      where: 'id = ?',
      whereArgs: [material.id],
    );
  }

  Future<int> deleteMaterial(int id) async {
    final db = await database;
    return await db.delete(
      'materials',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Downloads tracking
  Future<int> recordDownload(int materialId) async {
    final db = await database;
    return await db.insert('downloads', {
      'materialId': materialId,
      'downloadDate': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllDownloads() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT materials.*, downloads.downloadDate
      FROM downloads
      INNER JOIN materials ON downloads.materialId = materials.id
      ORDER BY downloads.downloadDate DESC
    ''');
  }

  Future<int> clearAllDownloads() async {
    final db = await database;
    return await db.delete('downloads');
  }

  Future<int> deleteDownload(int materialId) async {
    final db = await database;
    return await db.delete(
      'downloads',
      where: 'materialId = ?',
      whereArgs: [materialId],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}