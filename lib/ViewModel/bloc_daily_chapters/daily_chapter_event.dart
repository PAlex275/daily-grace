abstract class DailyChapterEvent {}

class LoadDailyChapters extends DailyChapterEvent {
  final int numberOfChapters;

  LoadDailyChapters(this.numberOfChapters);

  List<Object> get props => [numberOfChapters];
}

class LoadStoredChapters extends DailyChapterEvent {
  LoadStoredChapters();

  List<Object> get props => [];
}
