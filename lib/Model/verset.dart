class Verset {
  final int id;
  final String bookName;
  final int chapter;
  final int book;
  final int verse;
  final String text;

  Verset({
    required this.id,
    required this.bookName,
    required this.chapter,
    required this.book,
    required this.verse,
    required this.text,
  });

  factory Verset.fromJson(Map<String, dynamic> json) {
    return Verset(
      id: json['id'],
      bookName: json['book_name'],
      chapter: json['chapter'],
      verse: json['verse'],
      book: json['book'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_name': bookName,
      'chapter': chapter,
      'book': book,
      'verse': verse,
      'text': text,
    };
  }
}
