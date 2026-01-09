/// ============================================================================
/// FILE: api_config.dart
/// DESCRIPTION: Centralized API configuration with environment support
/// ============================================================================

class ApiConfig {
  // ==========================================================================
  // ENVIRONMENT CONFIGURATION
  // ==========================================================================

  /// Set true untuk production build
  /// Set false untuk development / testing
  static const bool isProduction = false;

  // ==========================================================================
  // BASE URL CONFIGURATION (CUSTOM BACKEND API)
  // ==========================================================================

  /// Base URL untuk PRODUCTION server
  /// Contoh: https://api.yourdomain.com/api
  static const String productionBaseUrl =
      'https://your-api-server.com/api';

  /// Base URL untuk DEVELOPMENT / LOCAL server
  /// Android Emulator : http://10.0.2.2:8000/api
  /// iOS Simulator    : http://localhost:8000/api
  /// Real Device      : http://192.168.x.x:8000/api
  static const String developmentBaseUrl =
      'http://10.0.2.2:8000/api';

  /// Base URL aktif berdasarkan environment
  static String get baseUrl =>
      isProduction ? productionBaseUrl : developmentBaseUrl;

  // ==========================================================================
  // SUPABASE CONFIGURATION (OPTIONAL / ALTERNATIVE BACKEND)
  // ==========================================================================

  /// Supabase project URL
  /// Contoh: https://abcdefghijkl.supabase.co
  static const String supabaseUrl =
      'https://your-project.supabase.co';

  /// Supabase anonymous public key
  static const String supabaseAnonKey =
      'your-anon-key-here';

  // ==========================================================================
  // API ENDPOINTS
  // ==========================================================================

  /// Materials endpoints
  static const String materialsEndpoint = '/materials';
  static const String uploadMaterialEndpoint = '/materials/upload';
  static const String downloadMaterialEndpoint =
      '/materials/{id}/download';

  /// Health check
  static const String healthEndpoint = '/health';

  // ==========================================================================
  // FULL URL HELPERS
  // ==========================================================================

  static String get materialsUrl =>
      '$baseUrl$materialsEndpoint';

  static String get uploadMaterialUrl =>
      '$baseUrl$uploadMaterialEndpoint';

  static String downloadMaterialUrl(String id) =>
      '$baseUrl/materials/$id/download';

  static String get healthCheckUrl =>
      '$baseUrl$healthEndpoint';

  // ==========================================================================
  // REQUEST CONFIGURATION
  // ==========================================================================

  /// Default timeout
  static const Duration timeout = Duration(seconds: 30);

  /// Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // ==========================================================================
  // HEADERS
  // ==========================================================================

  /// Header standar untuk REST API
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Header khusus Supabase REST API
  static Map<String, String> get supabaseHeaders => {
    'Content-Type': 'application/json',
    'apikey': supabaseAnonKey,
    'Authorization': 'Bearer $supabaseAnonKey',
  };

  // ==========================================================================
  // VALIDATION HELPERS
  // ==========================================================================

  /// Cek apakah backend API production sudah diset
  static bool get isProductionReady =>
      productionBaseUrl != 'https://your-api-server.com/api';

  /// Cek apakah Supabase sudah dikonfigurasi
  static bool get isSupabaseConfigured =>
      supabaseUrl != 'https://your-project.supabase.co' &&
          supabaseAnonKey != 'your-anon-key-here';
}
