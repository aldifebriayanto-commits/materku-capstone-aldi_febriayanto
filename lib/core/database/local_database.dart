import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/material_model.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('materku.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // ✅ FORCE DELETE OLD DATABASE untuk fix datatype mismatch
    // Comment setelah fix berhasil
    await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 3, // ✅ Increment version dari 2 ke 3
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // ✅ Create materials table dengan struktur yang benar
    await db.execute('''
      CREATE TABLE materials(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subject TEXT NOT NULL,
        type TEXT NOT NULL,
        filePath TEXT NOT NULL,
        uploadedBy TEXT NOT NULL,
        uploadDate TEXT NOT NULL,
        downloadCount INTEGER NOT NULL DEFAULT 0,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        description TEXT
      )
    ''');

    // ✅ Create downloads table
    await db.execute('''
      CREATE TABLE downloads(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        materialId TEXT NOT NULL,
        materialTitle TEXT NOT NULL,
        downloadDate TEXT NOT NULL
      )
    ''');

    print('✅ Database created successfully with version $version');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Upgrading database from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      // Upgrade dari v1 ke v2 - tambah downloads table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS downloads(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          materialId TEXT NOT NULL,
          materialTitle TEXT NOT NULL,
          downloadDate TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 3) {
      // ✅ Upgrade dari v2 ke v3 - Fix isFavorite datatype
      // Drop dan recreate materials table dengan struktur yang benar

      // 1. Backup existing data (jika ada)
      final List<Map<String, dynamic>> existingMaterials = await db.query('materials');

      // 2. Drop old table
      await db.execute('DROP TABLE IF EXISTS materials');

      // 3. Create new table dengan struktur yang benar
      await db.execute('''
        CREATE TABLE materials(
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          subject TEXT NOT NULL,
          type TEXT NOT NULL,
          filePath TEXT NOT NULL,
          uploadedBy TEXT NOT NULL,
          uploadDate TEXT NOT NULL,
          downloadCount INTEGER NOT NULL DEFAULT 0,
          isFavorite INTEGER NOT NULL DEFAULT 0,
          description TEXT
        )
      ''');

      // 4. Restore data dengan konversi isFavorite ke INTEGER
      for (var material in existingMaterials) {
        // Convert isFavorite to INTEGER if it's not already
        final isFavorite = material['isFavorite'];
        int isFavoriteInt = 0;

        if (isFavorite is int) {
          isFavoriteInt = isFavorite;
        } else if (isFavorite is String) {
          isFavoriteInt = (isFavorite.toLowerCase() == 'true' || isFavorite == '1') ? 1 : 0;
        } else if (isFavorite is bool) {
          isFavoriteInt = isFavorite ? 1 : 0;
        }

        await db.insert('materials', {
          ...material,
          'isFavorite': isFavoriteInt,
        });
      }

      print('✅ Upgraded to v3: Fixed isFavorite datatype');
    }
  }

  Future<List<MaterialModel>> getAllMaterials() async {
    try {
      final db = await database;
      final result = await db.query('materials', orderBy: 'uploadDate DESC');
      return result.map((json) => MaterialModel.fromMap(json)).toList();
    } catch (e) {
      print('❌ Error getting materials: $e');
      return [];
    }
  }

  Future<bool> insertMaterial(MaterialModel material) async {
    try {
      final db = await database;

      // ✅ Ensure isFavorite is INTEGER
      final materialMap = material.toMap();
      materialMap['isFavorite'] = material.isFavorite ? 1 : 0;
      materialMap['downloadCount'] = material.downloadCount;

      await db.insert(
        'materials',
        materialMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('✅ Material inserted successfully: ${material.title}');
      return true;
    } catch (e) {
      print('❌ Error inserting material: $e');
      return false;
    }
  }

  Future<void> updateMaterial(MaterialModel material) async {
    try {
      final db = await database;

      // ✅ Ensure isFavorite is INTEGER
      final materialMap = material.toMap();
      materialMap['isFavorite'] = material.isFavorite ? 1 : 0;

      await db.update(
        'materials',
        materialMap,
        where: 'id = ?',
        whereArgs: [material.id],
      );

      print('✅ Material updated: ${material.title}');
    } catch (e) {
      print('❌ Error updating material: $e');
    }
  }

  Future<void> deleteMaterial(String id) async {
    try {
      final db = await database;
      await db.delete('materials', where: 'id = ?', whereArgs: [id]);
      print('✅ Material deleted: $id');
    } catch (e) {
      print('❌ Error deleting material: $e');
    }
  }

  Future<List<MaterialModel>> getFavoriteMaterials() async {
    try {
      final db = await database;
      final result = await db.query(
        'materials',
        where: 'isFavorite = ?',
        whereArgs: [1],
        orderBy: 'uploadDate DESC',
      );
      return result.map((json) => MaterialModel.fromMap(json)).toList();
    } catch (e) {
      print('❌ Error getting favorites: $e');
      return [];
    }
  }

  Future<void> incrementDownloadCount(String materialId) async {
    try {
      final db = await database;
      await db.rawUpdate(
        'UPDATE materials SET downloadCount = downloadCount + 1 WHERE id = ?',
        [materialId],
      );
      print('✅ Download count incremented for: $materialId');
    } catch (e) {
      print('❌ Error incrementing download count: $e');
    }
  }

  Future<void> recordDownload(String materialId, String materialTitle) async {
    try {
      final db = await database;
      await db.insert('downloads', {
        'materialId': materialId,
        'materialTitle': materialTitle,
        'downloadDate': DateTime.now().toIso8601String(),
      });
      print('✅ Download recorded: $materialTitle');
    } catch (e) {
      print('❌ Error recording download: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllDownloads() async {
    try {
      final db = await database;
      return await db.query('downloads', orderBy: 'downloadDate DESC');
    } catch (e) {
      print('❌ Error getting downloads: $e');
      return [];
    }
  }

  Future<void> deleteDownload(int downloadId) async {
    try {
      final db = await database;
      await db.delete('downloads', where: 'id = ?', whereArgs: [downloadId]);
      print('✅ Download deleted: $downloadId');
    } catch (e) {
      print('❌ Error deleting download: $e');
    }
  }

  Future<void> clearAllDownloads() async {
    try {
      final db = await database;
      await db.delete('downloads');
      print('✅ All downloads cleared');
    } catch (e) {
      print('❌ Error clearing downloads: $e');
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}