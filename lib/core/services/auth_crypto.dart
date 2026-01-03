import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthCrypto {
  // salt static untuk contoh; di produksi sebaiknya digenerate per user
  static const _salt = 'LOCKPASS_STATIC_SALT_CHANGE_ME';

  static String hashPassword(String password) {
    final salted = '$_salt$password';
    final bytes = utf8.encode(salted);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPassword(String password, String storedHash) {
    final hash = hashPassword(password);
    return hash == storedHash;
  }
}
