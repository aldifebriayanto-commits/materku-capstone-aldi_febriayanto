import '../models/material_model.dart';

class SyncManager {
  static Future<List<MaterialModel>> getMaterials() async {
    return [];
  }

  static Future<bool> addMaterial(MaterialModel material) async {
    return true;
  }

  static Future<bool> updateMaterial(MaterialModel material) async {
    return true;
  }

  static Future<bool> deleteMaterial(String id) async {
    return true;
  }

  static Future<List<MaterialModel>> searchMaterials(String query) async {
    return [];
  }

  static Future<void> syncAllToServer() async {
    return;
  }
}
