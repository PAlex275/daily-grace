import 'package:equatable/equatable.dart';

abstract class FriendsReadingEvent extends Equatable {
  const FriendsReadingEvent();

  @override
  List<Object> get props => [];
}

class LoadFriendsReadingStatus extends FriendsReadingEvent {}

class UpdateFriendsReadingStatus extends FriendsReadingEvent {}
