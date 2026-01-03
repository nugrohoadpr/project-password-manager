import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/pages/login_page.dart';
import '../database/database_helper.dart';

class SessionManager {
  static const _timeoutKey = 'session_timeout_minutes';
  static const _storage = FlutterSecureStorage();
  
  Timer? _inactivityTimer;
  int _timeoutMinutes = 5;
  
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  int get timeoutMinutes => _timeoutMinutes;

  Future<void> loadTimeoutSetting() async {
    final value = await _storage.read(key: _timeoutKey);
    if (value != null) {
      _timeoutMinutes = int.tryParse(value) ?? 5;
    }
  }

  Future<void> saveTimeoutSetting(int minutes) async {
    _timeoutMinutes = minutes;
    await _storage.write(key: _timeoutKey, value: minutes.toString());
  }

  void startMonitoring(BuildContext context) {
    resetTimer(context);
  }

  void resetTimer(BuildContext context) {
    _inactivityTimer?.cancel();
    
    if (_timeoutMinutes > 0) {
      _inactivityTimer = Timer(Duration(minutes: _timeoutMinutes), () {
        _lockApp(context);
      });
    }
  }

  void stopMonitoring() {
    _inactivityTimer?.cancel();
  }

  void _lockApp(BuildContext context) {
    if (!context.mounted) return;
    
    DatabaseHelper.reset();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}
