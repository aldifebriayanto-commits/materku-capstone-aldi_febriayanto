/// ============================================================================
/// FILE: api_service_advanced.dart
/// DESCRIPTION: Advanced API service using Dio with
///              - Singleton
///              - Retry logic
///              - In-memory caching
///              - Upload & download progress
/// ============================================================================

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class ApiServiceAdvanced {
  // ===========================================================================
  // SINGLETON
  // ===========================================================================

  static final ApiServiceAdvanced _instance =
  ApiServiceAdvanced._internal();

  factory ApiServiceAdvanced() => _instance;

  ApiServiceAdvanced._internal() {
    _initDio();
  }

  late final Dio _dio;

  // ===========================================================================
  // CACHE CONFIG
  // ===========================================================================

  final Map<String, _CacheEntry> _cache = {};
  static const Duration _cacheValidity = Duration(minutes: 5);

  // ===========================================================================
  // RETRY CONFIG
  // ===========================================================================

  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(seconds: 1);

  // ===========================================================================
  // DIO INITIALIZATION
  // ===========================================================================

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.activeBaseUrl,
        connectTimeout: ApiConfig.timeout,
        receiveTimeout: ApiConfig.timeout,
        sendTimeout: ApiConfig.timeout,
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
          logPrint: (obj) => debugPrint('🌐 API: $obj'),
        ),
      );
    }

    // RETRY INTERCEPTOR
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (_shouldRetry(error)) {
            try {
              final response = await _retry(error.requestOptions);
              return handler.resolve(response);
            } catch (_) {
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ===========================================================================
  // RETRY HELPERS
  // ===========================================================================

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        (error.response?.statusCode ?? 0) >= 500;
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    int retryCount = 0;
    Duration delay = _initialRetryDelay;

    while (retryCount < _maxRetries) {
      try {
        await Future.delayed(delay);
        debugPrint('🔄 Retry ${retryCount + 1}/$_maxRetries');

        return await _dio.request(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          ),
        );
      } catch (_) {
        retryCount++;
        delay *= 2;
        if (retryCount >= _maxRetries) rethrow;
      }
    }

    throw Exception('Max retry reached');
  }

  // ===========================================================================
  // CACHE HELPERS
  // ===========================================================================

  bool _isCacheValid(String key) {
    if (!_cache.containsKey(key)) return false;
    return DateTime.now()
        .difference(_cache[key]!.timestamp) <=
        _cacheValidity;
  }

  dynamic _getCache(String key) {
    if (_isCacheValid(key)) {
      debugPrint('📦 Cache hit: $key');
      return _cache[key]!.data;
    }
    debugPrint('📭 Cache miss: $key');
    return null;
  }

  void _setCache(String key, dynamic data) {
    _cache[key] = _CacheEntry(data);
    debugPrint('💾 Cache saved: $key');
  }

  void clearCache() {
    _cache.clear();
    debugPrint('🗑️ Cache cleared');
  }

  void clearCacheEntry(String key) {
    _cache.remove(key);
    debugPrint('🗑️ Cache entry removed: $key');
  }

  // ===========================================================================
  // HEALTH CHECK
  // ===========================================================================

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

  // ===========================================================================
  // FETCH MATERIALS
  // ===========================================================================

  Future<List<Map<String, dynamic>>> fetchMaterials() async {
    const cacheKey = 'materials_list';

    final cached = _getCache(cacheKey);
    if (cached != null) {
      return List<Map<String, dynamic>>.from(cached);
    }

    try {
      final response = await _dio.get('/materials');
      final List<dynamic> data =
      response.data is Map ? response.data['data'] : response.data;

      final materials =
      List<Map<String, dynamic>>.from(data);

      _setCache(cacheKey, materials);
      debugPrint('✅ Loaded ${materials.length} materials');

      return materials;
    } catch (e) {
      debugPrint('❌ fetchMaterials error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchMaterialById(int id) async {
    final cacheKey = 'material_$id';

    final cached = _getCache(cacheKey);
    if (cached != null) {
      return Map<String, dynamic>.from(cached);
    }

    try {
      final response = await _dio.get('/materials/$id');
      final material =
          response.data['data'] ?? response.data;

      _setCache(cacheKey, material);
      return Map<String, dynamic>.from(material);
    } catch (e) {
      debugPrint('❌ fetchMaterialById error: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // UPLOAD MATERIAL
  // ===========================================================================

  Future<Map<String, dynamic>> uploadMaterial(
      String filePath,
      Map<String, dynamic> metadata, {
        Function(double progress)? onProgress,
      }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
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

      clearCacheEntry('materials_list');
      debugPrint('✅ Upload success');

      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ uploadMaterial error: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // DOWNLOAD MATERIAL
  // ===========================================================================

  Future<void> downloadMaterial(
      String materialId,
      String savePath, {
        Function(double progress)? onProgress,
      }) async {
    try {
      await _dio.download(
        '/materials/$materialId/download',
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            onProgress?.call(received / total);
          }
        },
      );

      debugPrint('✅ Download complete: $materialId');
    } catch (e) {
      debugPrint('❌ downloadMaterial error: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // UPDATE & DELETE
  // ===========================================================================

  Future<Map<String, dynamic>> updateMaterial(
      int id,
      Map<String, dynamic> data,
      ) async {
    try {
      final response =
      await _dio.put('/materials/$id', data: data);

      clearCacheEntry('material_$id');
      clearCacheEntry('materials_list');

      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ updateMaterial error: $e');
      rethrow;
    }
  }

  Future<void> deleteMaterial(int id) async {
    try {
      await _dio.delete('/materials/$id');

      clearCacheEntry('material_$id');
      clearCacheEntry('materials_list');

      debugPrint('✅ Material deleted: $id');
    } catch (e) {
      debugPrint('❌ deleteMaterial error: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // SEARCH
  // ===========================================================================

  Future<List<Map<String, dynamic>>> searchMaterials(String query) async {
    try {
      final response = await _dio.get(
        '/materials/search',
        queryParameters: {'q': query},
      );

      final List<dynamic> data =
          response.data['data'] ?? response.data;

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('❌ searchMaterials error: $e');
      rethrow;
    }
  }
}

// ============================================================================
// CACHE ENTRY MODEL
// ============================================================================

class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;

  _CacheEntry(this.data) : timestamp = DateTime.now();
}
