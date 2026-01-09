import 'package:flutter/foundation.dart';
import '../models/material_model.dart';
import '../core/database/local_database.dart';

class MaterialProvider with ChangeNotifier {
  List<MaterialModel> _materials = [];
  List<MaterialModel> _filteredMaterials = [];
  List<MaterialModel> _favoriteMaterials = [];
  List<Map<String, dynamic>> _downloads = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedSubject = 'Semua';

  // Getters
  List<MaterialModel> get materials => _filteredMaterials.isEmpty && _searchQuery.isEmpty
      ? _materials
      : _filteredMaterials;

  List<MaterialModel> get favoriteMaterials => _favoriteMaterials;
  List<Map<String, dynamic>> get downloads => _downloads;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedSubject => _selectedSubject;

  // ✅ ALIAS: fetchMaterials → loadMaterials (for compatibility)
  Future<void> fetchMaterials() async {
    await loadMaterials();
  }

  // Initialize method
  Future<void> initialize() async {
    await loadMaterials();
    await loadFavorites();
    await loadDownloads();
  }

  // Load all materials from database
  Future<void> loadMaterials() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = LocalDatabase.instance;
      _materials = await db.getAllMaterials();
      _filteredMaterials = _materials;
    } catch (e) {
      debugPrint('Error loading materials: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load favorite materials
  Future<void> loadFavorites() async {
    try {
      final db = LocalDatabase.instance;
      _favoriteMaterials = await db.getFavoriteMaterials();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  // Load downloads
  Future<void> loadDownloads() async {
    try {
      final db = LocalDatabase.instance;
      _downloads = await db.getAllDownloads();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading downloads: $e');
    }
  }

  // Search materials
  List<MaterialModel> searchMaterials(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredMaterials = _materials;
    } else {
      _filteredMaterials = _materials.where((material) {
        final titleMatch = material.title.toLowerCase().contains(query.toLowerCase());
        final subjectMatch = material.subject.toLowerCase().contains(query.toLowerCase());
        final descMatch = material.description.toLowerCase().contains(query.toLowerCase());
        return titleMatch || subjectMatch || descMatch;
      }).toList();
    }

    notifyListeners();
    return _filteredMaterials;
  }

  // Filter by subject
  void filterBySubject(String subject) {
    _selectedSubject = subject;

    if (subject == 'Semua') {
      _filteredMaterials = _materials;
    } else {
      _filteredMaterials = _materials.where((material) {
        return material.subject == subject;
      }).toList();
    }

    notifyListeners();
  }

  // Add new material
  Future<bool> addMaterial(MaterialModel material) async {
    try {
      final db = LocalDatabase.instance;
      await db.insertMaterial(material);
      await loadMaterials();
      return true;
    } catch (e) {
      debugPrint('Error adding material: $e');
      return false;
    }
  }

  // Update existing material
  Future<bool> updateMaterial(String id, MaterialModel material) async {
    try {
      final db = LocalDatabase.instance;
      await db.updateMaterial(material);
      await loadMaterials();
      return true;
    } catch (e) {
      debugPrint('Error updating material: $e');
      return false;
    }
  }

  // Delete material
  Future<bool> deleteMaterial(String id) async {
    try {
      final db = LocalDatabase.instance;
      await db.deleteMaterial(id);
      await loadMaterials();
      return true;
    } catch (e) {
      debugPrint('Error deleting material: $e');
      return false;
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(MaterialModel material) async {
    try {
      final db = LocalDatabase.instance;
      final updatedMaterial = material.copyWith(isFavorite: !material.isFavorite);
      await db.updateMaterial(updatedMaterial);
      await loadMaterials();
      await loadFavorites();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  // Get favorite materials
  Future<List<MaterialModel>> getFavoriteMaterials() async {
    try {
      final db = LocalDatabase.instance;
      return await db.getFavoriteMaterials();
    } catch (e) {
      debugPrint('Error getting favorites: $e');
      return [];
    }
  }

  // ✅ FIXED: recordDownload - accepts both signatures
  /// Record download with String id and title
  Future<void> recordDownload(String id, String title) async {
    try {
      final db = LocalDatabase.instance;
      await db.incrementDownloadCount(id);
      await db.recordDownload(id, title);
      await loadMaterials();
      await loadDownloads();
    } catch (e) {
      debugPrint('Error recording download: $e');
    }
  }

  // ✅ NEW: recordDownloadFromMaterial - convenience method
  /// Record download from MaterialModel object
  Future<void> recordDownloadFromMaterial(MaterialModel material) async {
    if (material.id != null) {
      await recordDownload(material.id!, material.title);
    }
  }

  // Get all downloads
  Future<List<Map<String, dynamic>>> getAllDownloads() async {
    try {
      final db = LocalDatabase.instance;
      return await db.getAllDownloads();
    } catch (e) {
      debugPrint('Error getting downloads: $e');
      return [];
    }
  }

  // Delete download record
  Future<void> deleteDownload(int downloadId) async {
    try {
      final db = LocalDatabase.instance;
      await db.deleteDownload(downloadId);
      await loadDownloads();
    } catch (e) {
      debugPrint('Error deleting download: $e');
    }
  }

  // Clear all downloads
  Future<void> clearAllDownloads() async {
    try {
      final db = LocalDatabase.instance;
      await db.clearAllDownloads();
      await loadDownloads();
    } catch (e) {
      debugPrint('Error clearing downloads: $e');
    }
  }

  // Check if material is downloaded
  bool isMaterialDownloaded(String materialId) {
    return _downloads.any((download) => download['materialId'] == materialId);
  }

  // Get material by ID
  MaterialModel? getMaterialById(String id) {
    try {
      return _materials.firstWhere((material) => material.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final totalMaterials = _materials.length;
    final totalDownloads = _materials.fold<int>(
      0,
          (sum, material) => sum + material.downloadCount,
    );
    final favorites = _materials.where((m) => m.isFavorite).length;

    // Count by subject
    final bySubject = <String, int>{};
    for (var material in _materials) {
      bySubject[material.subject] = (bySubject[material.subject] ?? 0) + 1;
    }

    return {
      'totalMaterials': totalMaterials,
      'totalDownloads': totalDownloads,
      'favorites': favorites,
      'bySubject': bySubject,
    };
  }
}