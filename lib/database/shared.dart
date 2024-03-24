import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_booked/Model/chapter.dart';

class SharedPreferencesManager {
  static const String lastGeneratedKey = 'last_generated';
  static const String dailyChaptersKey = 'daily_chapters';
  static const String storedChaptersKey = 'stored_chapters';
  static const String readDaysKey = 'read_days';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setStoredChapters(List<Chapter> chapters) async {
    final List<String> serializedChapters =
        chapters.map((chapter) => jsonEncode(chapter.toJson())).toList();
    await _prefs.setStringList(storedChaptersKey, serializedChapters);
  }

  static Future<List<Chapter>?> getStoredChapters() async {
    final List<String>? serializedChapters =
        _prefs.getStringList(storedChaptersKey);
    if (serializedChapters != null) {
      final List<Chapter> chapters = serializedChapters
          .map((serializedChapter) {
            return Chapter.fromJson(jsonDecode(serializedChapter));
          })
          .toList()
          .cast<Chapter>(); // Convertiți din List<dynamic> în List<Chapter>
      return chapters;
    }
    return null;
  }

  static DateTime? getLastGeneratedDate() {
    final String? dateString = _prefs.getString(lastGeneratedKey);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  static Future<void> setLastGeneratedDate(DateTime dateTime) async {
    final String dateString = dateTime.toIso8601String();
    await _prefs.setString(lastGeneratedKey, dateString);
  }

  static Future<void> setReadingTarget(int targetReading) async {
    await _prefs.setInt('targetReading', targetReading);
  }

  static Future<int?> getReadingTarget() async {
    return _prefs.getInt('targetReading');
  }

  static Future<void> setDailyChaptersNeeded(int dailyChaptersNeeded) async {
    await _prefs.setInt('dailyChaptersNeeded', dailyChaptersNeeded);
  }

  static Future<int?> getDailyChaptersNeeded() async {
    return _prefs.getInt('dailyChaptersNeeded');
  }

  // Adăugați o nouă zi în care utilizatorul a citit
  static Future<void> addReadDay(DateTime day) async {
    List<String> readDays = _prefs.getStringList(readDaysKey) ?? [];
    final String dateString = day.toIso8601String();
    if (!readDays.contains(dateString)) {
      readDays.add(dateString);
      await _prefs.setStringList(readDaysKey, readDays);
    }
  }

  // Obțineți lista tuturor zilelor în care utilizatorul a citit
  static List<DateTime> getReadDays() {
    List<String> readDaysString = _prefs.getStringList(readDaysKey) ?? [];
    List<DateTime> readDays = readDaysString.map((dateString) {
      return DateTime.parse(dateString);
    }).toList();
    return readDays;
  }
}
