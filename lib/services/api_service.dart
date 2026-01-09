/// ============================================================================
/// FILE: api_service_advanced.dart
/// DESCRIPTION: Advanced API service using Dio with caching & progress support
/// ============================================================================

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class ApiServiceAdvanced {
  // ===========================================================================
  // SINGLETON
  // ===========================================================================

  static final ApiServiceAdvanced _instance = ApiServiceAdvanced._internal();
  factory ApiServiceAdvanced() => _instance;
  ApiServiceAdvanced._internal() {
    _initDio();
  }

  late final Dio _dio;

  // ===========================================================================
  // SIMPLE IN-MEMORY CACHE
  // ===========================================================================

  final Map<String, _CacheEntry> _cache = {};
  static const Duration _cacheValidity = Duration(minutes: 5);

  // ===========================================================================
  // DIO INITIALIZATION
  // ===========================================================================

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.activeBaseUrl,
        connectTimeout: ApiConfig.timeout,
        receiveTimeout: ApiConfig.timeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // DEBUG LOGGER
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }
  }

  // ===========================================================================
  // CACHE HELPERS
  // ===========================================================================

  bool _isCacheValid(String key) {
    if (!_cache.containsKey(key)) return false;
    final entry = _cache[key]!;
    return DateTime.now().difference(entry.timestamp) <= _cacheValidity;
  }

  dynamic _getCache(String key) {
    if (_isCacheValid(key)) {
      debugPrint('📦 Using cache: $key');
      return _cache[key]!.data;
    }
    return null;
  }

  void _setCache(String key, dynamic data) {
    _cache[key] = _CacheEntry(data);
  }

  void clearCache() {
    _cache.clear();
    debugPrint('🗑️ API cache cleared');
  }

  // ===========================================================================
  // FETCH MATERIALS
  // ===========================================================================

  /// Fetch materials (cached)
  Future<List<Map<String, dynamic>>> fetchMaterials() async {
    const cacheKey = 'materials';

    final cached = _getCache(cacheKey);
    if (cached != null) {
      return List<Map<String, dynamic>>.from(cached);
    }

    try {
      final response = await _dio.get('/materials');

      final List<dynamic> data =
      response.data is Map ? response.data['data'] : response.data;

      final materials = List<Map<String, dynamic>>.from(data);

      _setCache(cacheKey, materials);
      debugPrint('✅ Fetched ${materials.length} materials from API');

      return materials;
    } catch (e) {
      debugPrint('❌ fetchMaterials error: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // UPLOAD MATERIAL
  // ===========================================================================

  /// Upload material with progress callback
  Future<Map<String, dynamic>> uploadMaterial(
      String filePath,
      Map<String, dynamic> metadata, {
        Function(double progress)? onProgress,
      }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        ...metadata,
      });

      final response = await _dio.post(
        '/materials/upload',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            onProgress?.call(sent / total);
          }
        },
      );

      clearCache();
      debugPrint('✅ Upload success');

      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ uploadMaterial error: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // HEALTH CHECK
  // ===========================================================================

  /// Check API connection
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Health check failed: $e');
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }
}

// ============================================================================
// CACHE ENTRY
// ============================================================================

class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;

  _CacheEntry(this.data) : timestamp = DateTime.now();
}
