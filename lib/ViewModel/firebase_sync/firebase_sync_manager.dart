import 'package:all_booked/Model/chapter.dart';
import 'package:all_booked/database/shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:all_booked/database/bible_database.dart';

class FirebaseSyncManager {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  final BibleDatabase _bibleDatabase;

  FirebaseSyncManager(this._bibleDatabase);

  Future<void> syncUserProgress() async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    final userDoc =
        await _firestore.collection('user_progress').doc(user.uid).get();

    if (userDoc.exists) {
      final data = userDoc.data()!;

      // Actualizează datele locale
      await SharedPreferencesManager.setDailyChaptersNeeded(
          data['dailyChaptersNeeded']);

      await SharedPreferencesManager.setTotalChaptersRead(
          data['totalChaptersRead']);
      await SharedPreferencesManager.setReadingTarget(data['readingTarget']);

      // Actualizează zilele citite
      List<String> readDays = List<String>.from(data['readDays']);
      for (String day in readDays) {
        await SharedPreferencesManager.addReadDay(DateTime.parse(day));
      }
      final lastGeneratedDate = DateTime.parse(readDays.last);
      final today = DateTime.now();
      final Map<String, int> chapterAndBook;
      if (lastGeneratedDate.year == today.year &&
          lastGeneratedDate.month == today.month &&
          lastGeneratedDate.day == today.day) {
        var totalChapters = SharedPreferencesManager.getTotalChaptersRead() -
            data['dailyChaptersNeeded'] as int;
        chapterAndBook =
            await _bibleDatabase.getBookAndChapterFromTotalRead(totalChapters);
      } else {
        chapterAndBook = await _bibleDatabase.getBookAndChapterFromTotalRead(
            SharedPreferencesManager.getTotalChaptersRead());
      }
      await SharedPreferencesManager.setLastGeneratedDate(
          DateTime.parse(readDays.last));
      // Verifică dacă utilizatorul a citit deja în ziua curentă

      await _bibleDatabase.updateDailyProgress(
          chapterAndBook['book']!, chapterAndBook['chapter']!);
    } else {
      await _initializeDefaultProgress();
    }
  }

  /// Inițializează progresul implicit pentru un utilizator nou
  Future<void> _initializeDefaultProgress() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Calculează ziua de ieri
    final yesterday = DateTime.now().subtract(Duration(days: 1));

    final defaultProgress = {
      "readingTarget": 1,
      "dailyChaptersNeeded": 4,
      "readDays": [],
      "totalChaptersRead": 0,
      "lastGeneratedDate": yesterday.toIso8601String(), // Setează data de ieri
    };

    await _firestore
        .collection('user_progress')
        .doc(user.uid)
        .set(defaultProgress);

    // Sincronizează progresul local cu cel din Firebase
    await syncUserProgress();
  }

  static Future<void> updateReadingTargetInFirebase(
      int targetReading, int dailyChaptersNeeded) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('user_progress')
        .doc(user.uid)
        .update({
      "readingTarget": targetReading,
      "dailyChaptersNeeded": dailyChaptersNeeded,
    });
  }

  static Future<void> addReadDayInFirebase(DateTime day) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef =
        FirebaseFirestore.instance.collection('user_progress').doc(user.uid);

    await docRef.update({
      "readDays": FieldValue.arrayUnion([day.toIso8601String()]),
    });

    // Actualizează numărul total de capitole citite, dacă este cazul
    int totalChaptersRead = SharedPreferencesManager.getTotalChaptersRead();
    await docRef.update({
      "totalChaptersRead": totalChaptersRead,
    });
  }

  static Future<void> saveDailyChaptersToFirebase(
      List<Chapter> dailyChapters) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    final today = DateTime.now().toIso8601String().split('T')[0];

    final userProgressRef =
        _firestore.collection('user_progress').doc(user.uid);

    // Actualizăm documentul principal user_progress
    await userProgressRef.set({
      'readDays': FieldValue.arrayUnion([today]),
      'totalChaptersRead': FieldValue.increment(dailyChapters.length),
      'lastUpdated': DateTime.now(),
    }, SetOptions(merge: true));

    // Salvăm capitolele citite pentru ziua curentă
    await userProgressRef.collection('daily_readings').doc(today).set({
      'date': today,
      'chapters': dailyChapters
          .map((chapter) => '${chapter.bookName} ${chapter.chapterNumber}')
          .toList(),
      'timestamp': DateTime.now(),
    });

    // Actualizăm data ultimei generări
    await SharedPreferencesManager.setLastGeneratedDate(DateTime.now());
  }
}
