import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DictionaryService {
  static final DictionaryService _instance = DictionaryService._internal();
  static Database? _database;

  factory DictionaryService() {
    return _instance;
  }

  DictionaryService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'gamen_dictionary.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE words(word TEXT PRIMARY KEY)',
    );
  }

  Future<void> loadDictionary() async {
    final db = await database;
    
    // Check if dictionary is already loaded
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM words'));
    if (count != null && count > 0) {
      debugPrint('Dictionary already loaded with $count words.');
      return;
    }

    debugPrint('Loading dictionary from assets...');
    final String content = await rootBundle.loadString('assets/dictionary.txt');
    final List<String> lines = content.split(RegExp(r'\r?\n'));

    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final word in lines) {
        if (word.trim().isNotEmpty) {
          batch.insert(
            'words',
            {'word': word.trim().toUpperCase()},
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
      await batch.commit(noResult: true);
    });
    
    debugPrint('Dictionary loaded successfully.');
  }

  Future<bool> isWordValid(String word) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'word = ?',
      whereArgs: [word.toUpperCase()],
    );
    return maps.isNotEmpty;
  }
}
