import 'package:sqflite_sqlcipher/sqflite.dart';
import '../database/database_helper.dart';
import '../models/password_model.dart';

class PasswordRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<PasswordItem>> getAllPasswords() async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('passwords', orderBy: 'title ASC');

    return maps.map((m) {
      final encryptedPassword = m['password'] as String;
      final decryptedPassword =
          _dbHelper.encryptionService.decryptText(encryptedPassword);

      return PasswordItem(
        id: m['id'] as int,
        title: m['title'] as String,
        email: (m['email'] ?? '') as String,
        password: decryptedPassword,
        website: (m['website'] ?? '') as String,
      );
    }).toList();
  }

  Future<int> insertPassword(PasswordItem item) async {
    final Database db = await _dbHelper.database;

    final encryptedPassword =
        _dbHelper.encryptionService.encryptText(item.password);

    return await db.insert('passwords', {
      'title': item.title,
      'email': item.email,
      'password': encryptedPassword,
      'website': item.website,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<int> updatePassword(PasswordItem item) async {
    final Database db = await _dbHelper.database;

    final encryptedPassword =
        _dbHelper.encryptionService.encryptText(item.password);

    return await db.update(
      'passwords',
      {
        'title': item.title,
        'email': item.email,
        'password': encryptedPassword,
        'website': item.website,
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deletePassword(int id) async {
    final Database db = await _dbHelper.database;
    return await db.delete(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get weak passwords berdasarkan aturan strength
  Future<List<PasswordItem>> getWeakPasswords() async {
    final allPasswords = await getAllPasswords();
    return allPasswords.where((item) => item.isWeak).toList();
  }

  /// Get reused passwords (password yang dipakai lebih dari 1 akun)
  Future<Map<String, List<PasswordItem>>> getReusedPasswords() async {
    final allPasswords = await getAllPasswords();
    
    final Map<String, List<PasswordItem>> grouped = {};
    for (var item in allPasswords) {
      if (item.password.isEmpty) continue;
      
      if (!grouped.containsKey(item.password)) {
        grouped[item.password] = [];
      }
      grouped[item.password]!.add(item);
    }
    
    final reused = <String, List<PasswordItem>>{};
    grouped.forEach((password, items) {
      if (items.length > 1) {
        reused[password] = items;
      }
    });
    
    return reused;
  }

  /// Get count weak passwords
  Future<int> getWeakPasswordsCount() async {
    final weak = await getWeakPasswords();
    return weak.length;
  }

  /// Get count reused passwords (total accounts)
  Future<int> getReusedPasswordsCount() async {
    final reused = await getReusedPasswords();
    int count = 0;
    reused.forEach((password, items) {
      count += items.length;
    });
    return count;
  }
}
