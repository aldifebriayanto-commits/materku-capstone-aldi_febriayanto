class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  
  factory DatabaseService() => _instance;
  
  DatabaseService._internal();

  Future<bool> checkServerHealth() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> syncToServer() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearAllData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      rethrow;
    }
  }
}