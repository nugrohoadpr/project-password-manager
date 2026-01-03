import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _masterHashKey = 'auth_master_hash';
  static const _dbKeyKey = 'auth_db_key';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveMasterHash(String hash) async {
    await _storage.write(key: _masterHashKey, value: hash);
  }

  Future<String?> getMasterHash() async {
    return _storage.read(key: _masterHashKey);
  }

  Future<void> saveDbKey(String key) async {
    await _storage.write(key: _dbKeyKey, value: key);
  }

  Future<String?> getDbKey() async {
    return _storage.read(key: _dbKeyKey);
  }

  Future<bool> hasMasterPassword() async {
    final hash = await getMasterHash();
    final key = await getDbKey();
    return hash != null && key != null;
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _masterHashKey);
    await _storage.delete(key: _dbKeyKey);
  }
}
