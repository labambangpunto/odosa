import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

class EncryptionService {
  // Initialization Vector statis untuk konsistensi, atau bisa diekstrak dinamis
  static final enc.IV _iv = enc.IV.fromLength(16);

  static String _generateKey(String password) {
    // Hash password menggunakan SHA-256 untuk mendapatkan panjang 32 karakter yang valid
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 32);
  }

  static String encryptData(String plainJson, String password) {
    final keyString = _generateKey(password);
    final key = enc.Key.fromUtf8(keyString);
    final encrypter = enc.Encrypter(enc.AES(key));

    final encrypted = encrypter.encrypt(plainJson, iv: _iv);
    return encrypted.base64;
  }

  static String decryptData(String encryptedBase64, String password) {
    final keyString = _generateKey(password);
    final key = enc.Key.fromUtf8(keyString);
    final encrypter = enc.Encrypter(enc.AES(key));

    return encrypter.decrypt64(encryptedBase64, iv: _iv);
  }
}
