import 'package:equatable/equatable.dart';

abstract class ReadingTargetState extends Equatable {
  const ReadingTargetState();

  @override
  List<Object?> get props => [];
}

class ReadingTargetInitial extends ReadingTargetState {}

class ReadingTargetLoading extends ReadingTargetState {}

class ReadingTargetSet extends ReadingTargetState {
  final int targetReading;
  final int dailyChaptersNeeded;

  const ReadingTargetSet(this.targetReading, this.dailyChaptersNeeded);

  @override
  List<Object?> get props => [targetReading, dailyChaptersNeeded];
}

class ReadingTargetError extends ReadingTargetState {
  final String message;

  const ReadingTargetError(this.message);

  @override
  List<Object?> get props => [message];
}
