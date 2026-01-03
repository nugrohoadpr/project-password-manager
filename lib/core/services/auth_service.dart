import 'package:flutter/material.dart';
import 'secure_storage_service.dart';
import '../database/database_helper.dart';
import '../../features/auth/pages/login_page.dart';

class AuthService {
  /// Lock app - kembali ke login tanpa hapus data
  static Future<void> logout(BuildContext context) async {
    await DatabaseHelper.reset();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  /// Clear semua data (master password + database)
  static Future<void> clearAllData(BuildContext context) async {
    final storage = SecureStorageService();
    await storage.clearAll();
    await DatabaseHelper.reset();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}
