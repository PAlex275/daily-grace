import 'package:all_booked/Model/verset.dart';

class Chapter {
  final String bookName;
  final int bookNumber;
  final int chapterNumber;
  final List<Verset> verses;

  Chapter({
    required this.bookName,
    required this.bookNumber,
    required this.chapterNumber,
    required this.verses,
  });

  Map<String, dynamic> toJson() {
    return {
      'book_name': bookName, // Modificăm numele câmpurilor
      'book_number': bookNumber,
      'chapter': chapterNumber,
      'verses': verses.map((verse) => verse.toJson()).toList(),
    };
  }

  factory Chapter.fromJson(Map<String, dynamic> json) {
    final String bookName = json['book_name']; // Modificăm numele câmpurilor
    final int chapterNumber = json['chapter'];
    final int bookNumber = json['book_number'];
    final List<dynamic> versesJson = json['verses'];
    final List<Verset> verses =
        versesJson.map((verseJson) => Verset.fromJson(verseJson)).toList();

    return Chapter(
      bookName: bookName,
      chapterNumber: chapterNumber,
      verses: verses,
      bookNumber: bookNumber,
    );
  }
}
