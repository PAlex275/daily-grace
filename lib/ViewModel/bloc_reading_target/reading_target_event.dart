import 'package:equatable/equatable.dart';

abstract class ReadingTargetEvent extends Equatable {
  const ReadingTargetEvent();

  @override
  List<Object?> get props => [];
}

class SetTargetReading extends ReadingTargetEvent {
  final int targetReading;

  const SetTargetReading(this.targetReading);

  @override
  List<Object?> get props => [targetReading];
}

class InitializeReadingTarget extends ReadingTargetEvent {
  @override
  List<Object?> get props => [];
}
