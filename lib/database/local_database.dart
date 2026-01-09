import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../../models/material_model.dart';

/// ============================================================================
/// Unified LocalDatabase - Single Source of Truth
/// Compatible with both DatabaseHelper & LocalDatabase patterns
/// ============================================================================

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

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Materials table - STRING id for compatibility
    await db.execute('''
      CREATE TABLE materials (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subject TEXT NOT NULL,
        type TEXT NOT NULL,
        filePath TEXT NOT NULL,
        uploadedBy TEXT NOT NULL,
        uploadDate TEXT NOT NULL,
        downloadCount INTEGER DEFAULT 0,
        isFavorite INTEGER DEFAULT 0,
        description TEXT DEFAULT ''
      )
    ''');

    // Downloads table
    await db.execute('''
      CREATE TABLE downloads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        materialId TEXT NOT NULL,
        materialTitle TEXT NOT NULL,
        downloadDate TEXT NOT NULL,
        FOREIGN KEY (materialId) REFERENCES materials (id) ON DELETE CASCADE
      )
    ''');

    // Indexes for performance
    await db.execute('CREATE INDEX idx_subject ON materials(subject)');
    await db.execute('CREATE INDEX idx_favorite ON materials(isFavorite)');
    await db.execute('CREATE INDEX idx_upload_date ON materials(uploadDate DESC)');

    // Seed initial data
    await _seedInitialData(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration logic jika diperlukan
      debugPrint('Database upgraded from $oldVersion to $newVersion');
    }
  }

  /// Seed 13 mata kuliah dengan sample data
  Future<void> _seedInitialData(Database db) async {
    final subjects = [
      'Algoritma dan Pemrograman',
      'Struktur Data',
      'Basis Data',
      'Data Mining',
      'Pembelajaran Mesin (Machine Learning)',
      'Kecerdasan Buatan',
      'Big Data',
      'Rekayasa Perangkat Lunak (RPL)',
      'Analisis dan Perancangan Sistem',
      'Manajemen Proyek TI',
      'Pengujian Perangkat Lunak',
      'Grafika Komputer',
      'Multimedia',
    ];

    final sampleMaterials = [
      {
        'subject': 'Algoritma dan Pemrograman',
        'title': 'Pengenalan Algoritma',
        'description': 'Materi dasar algoritma dan flowchart',
        'type': 'pdf',
      },
      {
        'subject': 'Struktur Data',
        'title': 'Array dan Linked List',
        'description': 'Implementasi struktur data dasar',
        'type': 'ppt',
      },
      {
        'subject': 'Basis Data',
        'title': 'Normalisasi Database',
        'description': 'Teknik normalisasi 1NF, 2NF, 3NF',
        'type': 'pdf',
      },
      {
        'subject': 'Data Mining',
        'title': 'Introduction to Data Mining',
        'description': 'Konsep dasar data mining dan KDD',
        'type': 'pdf',
      },
      {
        'subject': 'Pembelajaran Mesin (Machine Learning)',
        'title': 'Supervised vs Unsupervised Learning',
        'description': 'Perbedaan dan implementasi ML',
        'type': 'ppt',
      },
    ];

    for (var material in sampleMaterials) {
      await db.insert('materials', {
        'id': 'mat_seed_${DateTime.now().millisecondsSinceEpoch}_${material['subject'].hashCode}',
        'title': material['title'],
        'subject': material['subject'],
        'type': material['type'],
        'filePath': '/sample/${material['title']}.${material['type']}',
        'uploadedBy': 'System',
        'uploadDate': DateTime.now().toIso8601String(),
        'downloadCount': 0,
        'isFavorite': 0,
        'description': material['description'],
      });
    }

    debugPrint('✅ Seed data inserted: ${sampleMaterials.length} materials');
  }

  // ==================== MATERIALS CRUD ====================

  Future<void> insertMaterial(MaterialModel material) async {
    final db = await database;
    await db.insert(
      'materials',
      material.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('✅ Material inserted: ${material.title}');
  }

  Future<List<MaterialModel>> getAllMaterials() async {
    final db = await database;
    final result = await db.query(
      'materials',
      orderBy: 'uploadDate DESC',
    );
    return result.map((json) => MaterialModel.fromMap(json)).toList();
  }

  Future<MaterialModel?> getMaterialById(String id) async {
    final db = await database;
    final result = await db.query(
      'materials',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return MaterialModel.fromMap(result.first);
  }

  Future<List<MaterialModel>> getMaterialsBySubject(String subject) async {
    final db = await database;
    final result = await db.query(
      'materials',
      where: 'subject = ?',
      whereArgs: [subject],
      orderBy: 'uploadDate DESC',
    );
    return result.map((json) => MaterialModel.fromMap(json)).toList();
  }

  Future<void> updateMaterial(MaterialModel material) async {
    final db = await database;
    await db.update(
      'materials',
      material.toMap(),
      where: 'id = ?',
      whereArgs: [material.id],
    );
    debugPrint('✅ Material updated: ${material.title}');
  }

  Future<void> deleteMaterial(String id) async {
    final db = await database;
    await db.delete(
      'materials',
      where: 'id = ?',
      whereArgs: [id],
    );
    debugPrint('✅ Material deleted: $id');
  }

  // ==================== FAVORITES ====================

  Future<List<MaterialModel>> getFavoriteMaterials() async {
    final db = await database;
    final result = await db.query(
      'materials',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'uploadDate DESC',
    );
    return result.map((json) => MaterialModel.fromMap(json)).toList();
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final db = await database;
    await db.update(
      'materials',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== DOWNLOADS ====================

  Future<void> recordDownload(String materialId, String materialTitle) async {
    final db = await database;
    await db.insert('downloads', {
      'materialId': materialId,
      'materialTitle': materialTitle,
      'downloadDate': DateTime.now().toIso8601String(),
    });
    debugPrint('✅ Download recorded: $materialTitle');
  }

  Future<void> incrementDownloadCount(String materialId) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE materials SET downloadCount = downloadCount + 1 WHERE id = ?',
      [materialId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllDownloads() async {
    final db = await database;
    return await db.query(
      'downloads',
      orderBy: 'downloadDate DESC',
    );
  }

  Future<void> deleteDownload(int downloadId) async {
    final db = await database;
    await db.delete(
      'downloads',
      where: 'id = ?',
      whereArgs: [downloadId],
    );
  }

  Future<void> clearAllDownloads() async {
    final db = await database;
    await db.delete('downloads');
    debugPrint('✅ All downloads cleared');
  }

  // ==================== SEARCH ====================

  Future<List<MaterialModel>> searchMaterials(String query) async {
    final db = await database;
    final result = await db.query(
      'materials',
      where: 'title LIKE ? OR description LIKE ? OR subject LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'uploadDate DESC',
    );
    return result.map((json) => MaterialModel.fromMap(json)).toList();
  }

  // ==================== STATISTICS ====================

  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;

    final totalMaterials = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM materials'),
    ) ?? 0;

    final totalDownloads = Sqflite.firstIntValue(
      await db.rawQuery('SELECT SUM(downloadCount) FROM materials'),
    ) ?? 0;

    final totalFavorites = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM materials WHERE isFavorite = 1'),
    ) ?? 0;

    final bySubject = await db.rawQuery(
      'SELECT subject, COUNT(*) as count FROM materials GROUP BY subject',
    );

    return {
      'totalMaterials': totalMaterials,
      'totalDownloads': totalDownloads,
      'totalFavorites': totalFavorites,
      'bySubject': bySubject,
    };
  }

  // ==================== UTILITY ====================

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete('materials');
    await db.delete('downloads');
    await _seedInitialData(db);
    debugPrint('✅ Database reset complete');
  }
}