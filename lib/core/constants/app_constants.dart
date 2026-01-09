class AppConstants {
  // App Info
  static const String appName = 'MaterKu';
  static const String appVersion = '1.0.0';

  // File Types (Simplified - Image only)
  static const List<String> supportedFileTypes = [
    'jpg',
    'jpeg',
    'png',
  ];

  // Material Categories
  static const List<String> materialCategories = [
    'Matematika',
    'Fisika',
    'Kimia',
    'Biologi',
    'Pemrograman',
    'Database',
    'Jaringan',
    'Sistem Operasi',
    'Algoritma',
    'Lainnya',
  ];

  // Max file size (in bytes) - 5MB untuk image
  static const int maxFileSize = 5 * 1024 * 1024;

  // Pagination
  static const int itemsPerPage = 20;
}
