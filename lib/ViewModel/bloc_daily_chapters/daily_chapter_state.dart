import 'package:all_booked/Model/chapter.dart';

import 'package:equatable/equatable.dart';

abstract class DailyChapterState extends Equatable {
  const DailyChapterState();

  @override
  List<Object> get props => [];
}

class DailyChapterLoading extends DailyChapterState {}

class DailyChapterLoaded extends DailyChapterState {
  final List<Chapter> dailyChapters;

  const DailyChapterLoaded(this.dailyChapters);

  @override
  List<Object> get props => [dailyChapters];
}

class DailyChapterError extends DailyChapterState {
  final String message;

  const DailyChapterError(this.message);

  @override
  List<Object> get props => [message];
}
