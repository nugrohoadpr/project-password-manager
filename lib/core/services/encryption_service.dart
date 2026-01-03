import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class EncryptionService {
  late final encrypt.Key _key;
  late final encrypt.IV _iv;
  late final encrypt.Encrypter _encrypter;

  EncryptionService(String masterPassword) {
    // Derive 32-byte key dari master password menggunakan SHA-256
    final keyBytes = sha256.convert(utf8.encode(masterPassword)).bytes;
    _key = encrypt.Key(Uint8List.fromList(keyBytes));

    // IV static untuk simplicity (di produksi bisa random per record)
    _iv = encrypt.IV.fromLength(16);

    _encrypter = encrypt.Encrypter(encrypt.AES(_key));
  }

  /// Enkripsi plaintext menjadi base64 string
  String encryptText(String plainText) {
    if (plainText.isEmpty) return '';
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      return '';
    }
  }

  /// Dekripsi base64 string menjadi plaintext
  String decryptText(String encryptedBase64) {
    if (encryptedBase64.isEmpty) return '';
    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedBase64);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      // Jika gagal dekripsi (corrupt data), return string kosong
      return '';
    }
  }

  // Alias methods untuk compatibility
  String encryptData(String plainText) => encryptText(plainText);
  String decryptData(String encryptedBase64) => decryptText(encryptedBase64);
}
