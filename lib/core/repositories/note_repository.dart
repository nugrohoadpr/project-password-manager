import 'package:sqflite_sqlcipher/sqflite.dart';
import '../database/database_helper.dart';
import '../models/note_model.dart';

class NoteRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<NoteItem>> getAllNotes() async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('notes', orderBy: 'title ASC');

    return maps.map((m) {
      // Dekripsi content saat membaca dari DB
      final encryptedContent = (m['content'] ?? '') as String;
      final decryptedContent =
          _dbHelper.encryptionService.decryptText(encryptedContent);

      return NoteItem(
        id: m['id'] as int,
        title: m['title'] as String,
        content: decryptedContent,
      );
    }).toList();
  }

  Future<int> insertNote(NoteItem item) async {
    final Database db = await _dbHelper.database;

    // Enkripsi content sebelum simpan
    final encryptedContent =
        _dbHelper.encryptionService.encryptText(item.content);

    return await db.insert('notes', {
      'title': item.title,
      'content': encryptedContent,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<int> updateNote(NoteItem item) async {
    final Database db = await _dbHelper.database;

    // Enkripsi content sebelum update
    final encryptedContent =
        _dbHelper.encryptionService.encryptText(item.content);

    return await db.update(
      'notes',
      {
        'title': item.title,
        'content': encryptedContent,
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final Database db = await _dbHelper.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
