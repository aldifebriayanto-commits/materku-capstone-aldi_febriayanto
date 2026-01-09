/// ============================================================================
/// FILE: api_config.dart
/// DESCRIPTION: Centralized API configuration with environment support
/// ============================================================================

class ApiConfig {
  // ===========================================================================
  // ENVIRONMENT CONFIGURATION
  // ===========================================================================

  static const Environment currentEnvironment = Environment.development;

  // ===========================================================================
  // BASE URLS
  // ===========================================================================

  static const String developmentBaseUrl = 'http://localhost:3000/api';
  static const String productionBaseUrl = 'https://api.materku.com/api';
  static const String stagingBaseUrl = 'https://staging-api.materku.com/api';

  /// Get base URL based on current environment
  static String get baseUrl {
    switch (currentEnvironment) {
      case Environment.development:
        return developmentBaseUrl;
      case Environment.staging:
        return stagingBaseUrl;
      case Environment.production:
        return productionBaseUrl;
    }
  }

  /// ✅ ADDED: activeBaseUrl getter (alias for baseUrl)
  /// This is used by api_service.dart and api_service_advanced.dart
  static String get activeBaseUrl => baseUrl;

  // ===========================================================================
  // TIMEOUT CONFIGURATION
  // ===========================================================================

  static const Duration timeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ===========================================================================
  // ENDPOINTS
  // ===========================================================================

  static const String materialsEndpoint = '/materials';
  static const String uploadEndpoint = '/materials/upload';
  static const String downloadEndpoint = '/materials/download';
  static const String searchEndpoint = '/materials/search';
  static const String favoritesEndpoint = '/materials/favorites';
  static const String healthEndpoint = '/health';

  // ===========================================================================
  // API KEYS & TOKENS
  // ===========================================================================

  static const String apiKey = 'your_api_key_here';
  static const String secretKey = 'your_secret_key_here';

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  /// Build full URL for endpoint
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  /// Get headers for API requests
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-API-Key': apiKey,
  };

  /// Get headers with auth token
  static Map<String, String> getAuthHeaders(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
}

// =============================================================================
// ENVIRONMENT ENUM
// =============================================================================

enum Environment {
  development,
  staging,
  production,
}