import 'dart:async';
import 'dart:convert';
import 'package:all_booked/Model/chapter.dart';
import 'package:all_booked/Model/verset.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;

class BibleDatabase {
  static Database? _database;
  static final BibleDatabase instance = BibleDatabase._();

  BibleDatabase._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'bible_database.db');
    bool exists = await databaseExists(path);

    if (!exists) {
      // Crează baza de date dacă aceasta nu există
      await _createDB(path);
    } else {
      debugPrint("Database already exists");
    }

    return await openDatabase(path);
  }

  Future<void> deleteDatabaseFile() async {
    try {
      String path = join(await getDatabasesPath(), 'bible_database.db');
      await deleteDatabase(path);
      print('Database deleted successfully');
    } catch (e) {
      print('Error deleting database: $e');
    }
  }

  Future<void> _createDB(String path) async {
    // Deschide fișierul JSON și citește datele
    String jsonString =
        await rootBundle.loadString('assets/database/biblie.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);
    List<dynamic> verses = jsonData['verses'];

    // Creează baza de date și tabela
    // ignore: unused_local_variable
    Database db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE bible_verses(
          id INTEGER PRIMARY KEY,
          book_name TEXT,
          book INTEGER,
          chapter INTEGER,
          verse INTEGER,
          text TEXT
        )
      ''');
      // Creează și tabela pentru progresul zilnic
      await db.execute('''
      CREATE TABLE daily_progress(
        id INTEGER PRIMARY KEY,
        current_book INTEGER,
        current_chapter INTEGER
      )
    ''');

      // Inserează datele din fișierul JSON în baza de date
      Batch batch = db.batch();
      verses.forEach((verse) {
        batch.insert('bible_verses', verse);
      });
      await batch.commit();
    });
  }

  Future<int> getTotalChaptersInBook(int bookNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> chaptersData = await db.rawQuery(
      'SELECT MAX(chapter) as totalChapters FROM bible_verses WHERE book = ?',
      [bookNumber],
    );
    return chaptersData.isNotEmpty ? chaptersData[0]['totalChapters'] ?? 0 : 0;
  }

  Future<int> getTotalVersesInChapter(int bookNumber, int chapterNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> versesData = await db.rawQuery(
      'SELECT MAX(verse) as totalVerses FROM bible_verses WHERE book = ? AND chapter = ?',
      [bookNumber, chapterNumber],
    );
    return versesData.isNotEmpty ? versesData[0]['totalVerses'] ?? 0 : 0;
  }

  Future<void> updateDailyProgress(int currentBook, int currentChapter) async {
    final db = await database;
    await db.delete('daily_progress'); // Șterge progresul anterior
    await db.insert('daily_progress', {
      'current_book': currentBook,
      'current_chapter': currentChapter,
    });
  }

  Future<Map<String, int>> getDailyProgress() async {
    final db = await database;
    final List<Map<String, dynamic>> progressData =
        await db.query('daily_progress');
    if (progressData.isEmpty) {
      return {
        'current_book': 1,
        'current_chapter': 1
      }; // Dacă nu există progres, începeți cu prima carte și primul capitol
    } else {
      final progress = progressData.first;
      return {
        'current_book': progress['current_book'],
        'current_chapter': progress['current_chapter'],
      };
    }
  }

  Future<List<Chapter>> getDailyChapters(int numberOfChaptersPerDay) async {
    final db = await database;

    // Obținem progresul zilnic
    final progress = await getDailyProgress();
    int currentBook = progress['current_book']!;
    int currentChapter = progress['current_chapter']!;

    // Lista în care vom stoca capitolele pentru ziua curentă
    List<Chapter> dailyChapters = [];

    // Parcurgem numărul de capitole pe zi
    for (int i = 0; i < numberOfChaptersPerDay; i++) {
      // Obținem versetele pentru capitolul curent
      final List<Map<String, dynamic>> chapterVerses = await db.query(
        'bible_verses',
        where: 'book = ? AND chapter = ?',
        whereArgs: [currentBook, currentChapter],
      );

      // Obținem numele cărții pentru capitolul curent
      String bookName =
          chapterVerses.isNotEmpty ? chapterVerses[0]['book_name'] : '';

      // Mapăm datele în obiecte Verset
      List<Verset> verses = chapterVerses.map((verseJson) {
        return Verset.fromJson(verseJson);
      }).toList();

      // Creăm un obiect Chapter și îl adăugăm la lista de capitole pentru ziua curentă
      Chapter chapter = Chapter(
        bookName: bookName,
        bookNumber: currentBook,
        chapterNumber: currentChapter,
        verses: verses,
      );
      dailyChapters.add(chapter);

      // Trecem la următorul capitol
      currentChapter++;

      // Verificăm dacă am terminat toate capitolele din cartea curentă
      int totalChaptersInCurrentBook =
          await getTotalChaptersInBook(currentBook);
      if (currentChapter > totalChaptersInCurrentBook) {
        // Trecem la următoarea carte
        currentBook++;
        currentChapter = 1; // Resetează numărul capitolului la început
      }
    }

    // Actualizăm progresul zilnic
    await updateDailyProgress(currentBook, currentChapter);
    return dailyChapters;
  }

  // Future<List<Verset>> getVersesInChapterRange(
  //     int startChapter, int endChapter) async {
  //   final db = await database;

  //   // Lista în care vom stoca versetele din intervalul de capitole
  //   List<Verset> verses = [];

  //   // Parcurgem intervalul de capitole și extragem versetele corespunzătoare fiecărui capitol
  //   for (int chapter = startChapter; chapter <= endChapter; chapter++) {
  //     final List<Map<String, dynamic>> chapterVerses = await db.query(
  //       'bible_verses',
  //       where: 'chapter = ?',
  //       whereArgs: [chapter],
  //     );

  //     // Mapăm datele în obiecte Verset și le adăugăm la lista de versete
  //     verses
  //         .addAll(chapterVerses.map((verseJson) => Verset.fromJson(verseJson)));
  //   }

  //   return verses;
  // }

  // Future<List<Verset>> getVersesForChapter(int chapterNumber) async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> versesData = await db.query(
  //     'bible_verses',
  //     where: 'chapter = ?',
  //     whereArgs: [chapterNumber],
  //   );

  //   // Mapăm datele în obiecte Verset
  //   List<Verset> verses = versesData.map((verseJson) {
  //     return Verset.fromJson(verseJson);
  //   }).toList();

  //   return verses;
  // }

  // Future<List<Verset>> getVersesInRange(int startVerse, int endVerse) async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> versesData = await db.query(
  //     'bible_verses',
  //     where: 'verse >= ? AND verse <= ?',
  //     whereArgs: [startVerse, endVerse],
  //   );

  //   // Mapăm datele în obiecte Verset
  //   List<Verset> verses = versesData.map((verseJson) {
  //     return Verset.fromJson(verseJson);
  //   }).toList();

  //   return verses;
  // }
}