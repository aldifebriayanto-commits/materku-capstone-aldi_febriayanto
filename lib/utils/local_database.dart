import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class LocalDatabase {
  // Record a download
  Future<void> recordDownload(int? materialId, String filePath) async {
    if (materialId == null) return;
    
    final db = await DatabaseHelper().database;
    
    await db.insert(
      'downloads',
      {
        'materialId': materialId,
        'downloadDate': DateTime.now().toIso8601String(),
        'filePath': filePath,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Increment download count in materials table
    await db.rawUpdate(
      'UPDATE materials SET downloadCount = downloadCount + 1 WHERE id = ?',
      [materialId],
    );
  }

  // Get all downloads
  Future<List<Map<String, dynamic>>> getDownloads() async {
    final db = await DatabaseHelper().database;
    return await db.query(
      'downloads',
      orderBy: 'downloadDate DESC',
    );
  }

  // Delete a download
  Future<void> deleteDownload(int downloadId) async {
    final db = await DatabaseHelper().database;
    await db.delete(
      'downloads',
      where: 'id = ?',
      whereArgs: [downloadId],
    );
  }

  // Clear all downloads
  Future<void> clearAllDownloads() async {
    final db = await DatabaseHelper().database;
    await db.delete('downloads');
  }

  // Get download by material ID
  Future<Map<String, dynamic>?> getDownloadByMaterialId(int? materialId) async {
    if (materialId == null) return null;
    
    final db = await DatabaseHelper().database;
    final results = await db.query(
      'downloads',
      where: 'materialId = ?',
      whereArgs: [materialId],
      limit: 1,
    );
    
    return results.isNotEmpty ? results.first : null;
  }
}