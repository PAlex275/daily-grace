import 'package:all_booked/Model/chapter.dart';

abstract class DailyChapterEvent {}

class LoadDailyChapters extends DailyChapterEvent {
  final int numberOfChapters;

  LoadDailyChapters(this.numberOfChapters);

  List<Object> get props => [numberOfChapters];
}

class LoadStoredChapters extends DailyChapterEvent {
  final List<Chapter> storedChapters;

  LoadStoredChapters(this.storedChapters);

  List<Object> get props => [storedChapters];
}
