import 'package:encrypt/encrypt.dart';

class EncryptionHelper {
  // AES encryption key (32 characters for AES-256)
  static const String _encryptionKey = 'my32characterlongsecretkey123456';
  
  // Initialization Vector (16 characters)
  static const String _ivString = 'my16characteriv1';

  static final _key = Key.fromUtf8(_encryptionKey);
  static final _iv = IV.fromUtf8(_ivString);
  static final _encrypter = Encrypter(AES(_key));

  /// Encrypt a plain text string
  static String encrypt(String plainText) {
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      return plainText; // Return original if encryption fails
    }
  }

  /// Decrypt an encrypted string
  static String decrypt(String encryptedText) {
    try {
      final decrypted = _encrypter.decrypt64(encryptedText, iv: _iv);
      return decrypted;
    } catch (e) {
      return encryptedText; // Return original if decryption fails
    }
  }

  /// Generate a random encryption key
  static String generateKey() {
    return Key.fromSecureRandom(32).base64;
  }
}