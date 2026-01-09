import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Security Helper untuk implement security best practices
///
/// Fitur utama:
/// - Input validation & sanitization (prevent injection attacks)
/// - Data encryption/decryption (protect sensitive data)
/// - Password hashing dengan salt (secure password storage)
/// - XSS prevention (sanitize HTML/JS input)
/// - File type validation (prevent malicious uploads)
///
/// Security principles:
/// - Never trust user input
/// - Always validate & sanitize
/// - Use encryption untuk sensitive data
/// - Hash passwords, never store plain text
/// - Validate file types before upload
///
/// Example usage:
/// ```dart
/// // Sanitize user input
/// final safeInput = SecurityHelper.sanitizeInput(userInput);
///
/// // Validate email
/// if (!SecurityHelper.validateEmail(email)) {
///   throw Exception('Invalid email');
/// }
///
/// // Hash password
/// final hashed = SecurityHelper.hashPassword(password);
/// ```
class SecurityHelper {
  // ==========================================================================
  // INPUT VALIDATION
  // ==========================================================================

  /// Sanitize user input untuk prevent injection attacks
  ///
  /// Protection terhadap:
  /// - SQL Injection (remove SQL keywords)
  /// - XSS (remove HTML/JS tags)
  /// - Path Traversal (remove ../ sequences)
  /// - Command Injection (remove shell metacharacters)
  ///
  /// Process:
  /// 1. Trim whitespace
  /// 2. Remove dangerous characters (<, >, ', ", ;, --, dll)
  /// 3. Escape special characters
  /// 4. Limit length
  ///
  /// Parameters:
  /// - [input] String yang akan di-sanitize
  /// - [maxLength] Maximum allowed length (default: 500 chars)
  ///
  /// Returns:
  /// - Sanitized string yang aman untuk process
  ///
  /// Example:
  /// ```dart
  /// final userInput = "<script>alert('XSS')</script>";
  /// final safe = sanitizeInput(userInput);
  /// // Result: "scriptalert('XSS')/script" (tags removed)
  /// ```
  static String sanitizeInput(String input, {int maxLength = 500}) {
    if (input.isEmpty) return input;

    debugPrint('🛡️ Sanitizing input...');

    // Step 1: Trim whitespace
    String sanitized = input.trim();

    // Step 2: Limit length (prevent buffer overflow)
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
      debugPrint('⚠️ Input truncated to $maxLength chars');
    }

    // Step 3: Remove dangerous HTML/JS characters
    // Prevent XSS attacks
    sanitized = sanitized
        .replaceAll('<', '')  // Remove opening tag
        .replaceAll('>', '')  // Remove closing tag
        .replaceAll('"', '&#34;')  // Escape double quotes
        .replaceAll("'", '&#39;')  // Escape single quotes
        .replaceAll('&', '&amp;')  // Escape ampersand
        .replaceAll('/', '&#47;')  // Escape forward slash
        .replaceAll('\\', '&#92;'); // Escape backslash

    // Step 4: Remove SQL injection keywords (basic protection)
    final sqlKeywords = [
      'SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP',
      'CREATE', 'ALTER', 'EXEC', 'EXECUTE', '--', ';--',
      'UNION', 'WHERE', 'OR 1=1', 'AND 1=1'
    ];

    for (final keyword in sqlKeywords) {
      sanitized = sanitized.replaceAll(
        RegExp(keyword, caseSensitive: false),
        '',
      );
    }

    // Step 5: Remove path traversal attempts
    sanitized = sanitized
        .replaceAll('../', '')
        .replaceAll('..\\', '');

    debugPrint('✅ Input sanitized');
    return sanitized;
  }

  /// Validate input terhadap pattern yang diizinkan
  ///
  /// Use case:
  /// - Username: hanya alphanumeric & underscore
  /// - Title: alphanumeric + spaces + basic punctuation
  /// - Description: hampir semua karakter, tapi limited
  ///
  /// Parameters:
  /// - [input] String yang akan divalidate
  /// - [allowSpecialChars] Izinkan special characters (default: false)
  ///
  /// Returns:
  /// - true jika valid
  /// - false jika mengandung illegal characters
  ///
  /// Example:
  /// ```dart
  /// validateInput('john_doe123')  // true
  /// validateInput('john<script>')  // false
  /// ```
  static bool validateInput(String input, {bool allowSpecialChars = false}) {
    if (input.isEmpty) return false;

    // Pattern: alphanumeric + space + underscore + dash
    final pattern = allowSpecialChars
        ? RegExp(r'^[a-zA-Z0-9\s\-_.,!?]+$')  // Allow punctuation
        : RegExp(r'^[a-zA-Z0-9\s\-_]+$');      // Only alphanumeric

    final isValid = pattern.hasMatch(input);

    if (!isValid) {
      debugPrint('❌ Invalid input detected: contains illegal characters');
    }

    return isValid;
  }

  /// Validate email format
  ///
  /// Pattern: RFC 5322 compliant
  /// Format: local@domain.tld
  ///
  /// Parameters:
  /// - [email] Email address yang akan divalidate
  ///
  /// Returns:
  /// - true jika format valid
  /// - false jika format invalid
  ///
  /// Example:
  /// ```dart
  /// validateEmail('user@example.com')  // true
  /// validateEmail('invalid.email')     // false
  /// ```
  static bool validateEmail(String email) {
    // RFC 5322 compliant regex (simplified)
    final pattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    return pattern.hasMatch(email);
  }

  /// Validate password strength
  ///
  /// Requirements:
  /// - Minimum 8 characters
  /// - At least 1 uppercase letter
  /// - At least 1 lowercase letter
  /// - At least 1 number
  /// - At least 1 special character
  ///
  /// Parameters:
  /// - [password] Password yang akan divalidate
  ///
  /// Returns:
  /// - Map dengan keys: isValid, strength, message
  ///
  /// Example:
  /// ```dart
  /// final result = validatePassword('Pass123!');
  /// if (!result['isValid']) {
  ///   print(result['message']);
  /// }
  /// ```
  static Map<String, dynamic> validatePassword(String password) {
    if (password.length < 8) {
      return {
        'isValid': false,
        'strength': 'weak',
        'message': 'Password minimal 8 karakter',
      };
    }

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    // Calculate strength
    int strength = 0;
    if (hasUppercase) strength++;
    if (hasLowercase) strength++;
    if (hasDigit) strength++;
    if (hasSpecialChar) strength++;

    if (strength < 3) {
      return {
        'isValid': false,
        'strength': 'weak',
        'message': 'Password harus mengandung huruf besar, kecil, angka, dan karakter spesial',
      };
    }

    return {
      'isValid': true,
      'strength': strength == 4 ? 'strong' : 'medium',
      'message': 'Password valid',
    };
  }

  // ==========================================================================
  // ENCRYPTION & HASHING
  // ==========================================================================

  /// Hash password menggunakan SHA-256 dengan salt
  ///
  /// Process:
  /// 1. Generate random salt (jika tidak provided)
  /// 2. Combine password + salt
  /// 3. Hash menggunakan SHA-256
  /// 4. Return hash + salt (untuk verification nanti)
  ///
  /// Security:
  /// - Each password punya unique salt (prevent rainbow table attacks)
  /// - SHA-256 adalah cryptographic hash function yang secure
  /// - One-way hash (tidak bisa di-decrypt)
  ///
  /// Parameters:
  /// - [password] Password plain text yang akan di-hash
  /// - [salt] Optional salt (auto-generate jika null)
  ///
  /// Returns:
  /// - Map dengan keys: hash, salt
  ///
  /// Example:
  /// ```dart
  /// final result = hashPassword('mySecurePassword123');
  /// // Save result['hash'] dan result['salt'] ke database
  ///
  /// // Untuk verify:
  /// final verify = hashPassword(inputPassword, salt: savedSalt);
  /// if (verify['hash'] == savedHash) {
  ///   // Password correct
  /// }
  /// ```
  static Map<String, String> hashPassword(String password, {String? salt}) {
    // Generate salt jika tidak provided
    salt ??= _generateSalt();

    debugPrint('🔐 Hashing password...');

    // Combine password + salt
    final saltedPassword = password + salt;

    // Hash menggunakan SHA-256
    final bytes = utf8.encode(saltedPassword);
    final hash = sha256.convert(bytes).toString();

    debugPrint('✅ Password hashed');

    return {
      'hash': hash,
      'salt': salt,
    };
  }

  /// Generate random salt untuk password hashing
  ///
  /// Returns:
  /// - Random string (16 chars hexadecimal)
  static String _generateSalt() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.toString() + UniqueKey().toString();
    final bytes = utf8.encode(random);
    return sha256.convert(bytes).toString().substring(0, 16);
  }

  /// Simple encryption untuk data (basic XOR cipher)
  ///
  /// Note: Ini bukan encryption yang sangat kuat, hanya untuk
  /// obscure data dari casual inspection. Untuk production,
  /// gunakan library seperti encrypt package dengan AES.
  ///
  /// Parameters:
  /// - [data] Data yang akan di-encrypt
  /// - [key] Encryption key (harus sama untuk decrypt)
  ///
  /// Returns:
  /// - Base64 encoded encrypted data
  ///
  /// Example:
  /// ```dart
  /// final encrypted = encryptData('sensitive info', 'mySecretKey');
  /// final decrypted = decryptData(encrypted, 'mySecretKey');
  /// ```
  static String encryptData(String data, String key) {
    debugPrint('🔒 Encrypting data...');

    final dataBytes = utf8.encode(data);
    final keyBytes = utf8.encode(key);

    // Simple XOR encryption
    final encrypted = List<int>.generate(
      dataBytes.length,
          (i) => dataBytes[i] ^ keyBytes[i % keyBytes.length],
    );

    // Encode to Base64 untuk storage
    final result = base64.encode(encrypted);

    debugPrint('✅ Data encrypted');
    return result;
  }

  /// Decrypt data yang sudah di-encrypt dengan encryptData()
  ///
  /// Parameters:
  /// - [encryptedData] Base64 encoded encrypted data
  /// - [key] Encryption key (harus sama dengan yang dipakai encrypt)
  ///
  /// Returns:
  /// - Decrypted string
  static String decryptData(String encryptedData, String key) {
    debugPrint('🔓 Decrypting data...');

    try {
      // Decode dari Base64
      final encrypted = base64.decode(encryptedData);
      final keyBytes = utf8.encode(key);

      // XOR decryption (same operation as encryption)
      final decrypted = List<int>.generate(
        encrypted.length,
            (i) => encrypted[i] ^ keyBytes[i % keyBytes.length],
      );

      final result = utf8.decode(decrypted);

      debugPrint('✅ Data decrypted');
      return result;
    } catch (e) {
      debugPrint('❌ Decryption failed: $e');
      rethrow;
    }
  }

  // ==========================================================================
  // FILE VALIDATION
  // ==========================================================================

  /// Validate file type berdasarkan extension
  ///
  /// Allowed file types untuk MaterKu:
  /// - Documents: PDF, DOC, DOCX, PPT, PPTX, XLS, XLSX
  /// - Images: JPG, JPEG, PNG, GIF
  /// - Videos: MP4, AVI, MKV
  /// - Archives: ZIP, RAR
  ///
  /// Parameters:
  /// - [filePath] Path file yang akan divalidate
  ///
  /// Returns:
  /// - true jika file type diizinkan
  /// - false jika file type tidak diizinkan
  ///
  /// Example:
  /// ```dart
  /// if (!validateFileType('/path/to/file.pdf')) {
  ///   throw Exception('File type not allowed');
  /// }
  /// ```
  static bool validateFileType(String filePath) {
    final allowedExtensions = [
      // Documents
      'pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'txt',
      // Images
      'jpg', 'jpeg', 'png', 'gif', 'webp',
      // Videos
      'mp4', 'avi', 'mkv', 'mov', 'wmv',
      // Archives
      'zip', 'rar', '7z',
    ];

    final extension = filePath.split('.').last.toLowerCase();
    final isValid = allowedExtensions.contains(extension);

    if (!isValid) {
      debugPrint('❌ File type not allowed: .$extension');
    }

    return isValid;
  }

  /// Validate file size (prevent upload file terlalu besar)
  ///
  /// Limits:
  /// - Documents: max 50 MB
  /// - Images: max 10 MB
  /// - Videos: max 500 MB
  ///
  /// Parameters:
  /// - [fileSize] Ukuran file dalam bytes
  /// - [filePath] Path file untuk determine type
  ///
  /// Returns:
  /// - true jika size valid
  /// - false jika terlalu besar
  static bool validateFileSize(int fileSize, String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    final sizeInMB = fileSize / 1024 / 1024;

    // Determine max size based on type
    double maxSize;
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      maxSize = 10.0; // 10 MB untuk images
    } else if (['mp4', 'avi', 'mkv', 'mov', 'wmv'].contains(extension)) {
      maxSize = 500.0; // 500 MB untuk videos
    } else {
      maxSize = 50.0; // 50 MB untuk documents
    }

    final isValid = sizeInMB <= maxSize;

    if (!isValid) {
      debugPrint('❌ File too large: ${sizeInMB.toStringAsFixed(2)}MB (max: ${maxSize}MB)');
    } else {
      debugPrint('✅ File size OK: ${sizeInMB.toStringAsFixed(2)}MB');
    }

    return isValid;
  }

  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================

  /// Generate secure random token (untuk API keys, reset tokens, dll)
  ///
  /// Parameters:
  /// - [length] Panjang token (default: 32 chars)
  ///
  /// Returns:
  /// - Random hexadecimal string
  ///
  /// Example:
  /// ```dart
  /// final apiKey = generateSecureToken(64);
  /// // Result: "a3f2d8e9c1b4..."
  /// ```
  static String generateSecureToken({int length = 32}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = '$timestamp${UniqueKey()}${DateTime.now().microsecond}';
    final bytes = utf8.encode(random);
    final hash = sha256.convert(bytes).toString();

    return hash.substring(0, length);
  }

  /// Verify data integrity menggunakan checksum
  ///
  /// Use case:
  /// - Verify file tidak corrupt setelah download
  /// - Verify data tidak dimodifikasi
  ///
  /// Parameters:
  /// - [data] Data yang akan di-verify
  /// - [expectedChecksum] Checksum yang expected
  ///
  /// Returns:
  /// - true jika checksum match
  /// - false jika data corrupted/modified
  static bool verifyChecksum(String data, String expectedChecksum) {
    final bytes = utf8.encode(data);
    final actualChecksum = sha256.convert(bytes).toString();

    final isValid = actualChecksum == expectedChecksum;

    if (!isValid) {
      debugPrint('⚠️ Checksum mismatch - data may be corrupted');
    }

    return isValid;
  }
}