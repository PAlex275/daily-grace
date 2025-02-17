import 'package:equatable/equatable.dart';

class FriendReadingStatus {
  final String userId;
  final String name;
  final String avatarUrl;
  final bool hasReadToday;
  final List<String> chaptersRead;

  FriendReadingStatus({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.hasReadToday,
    required this.chaptersRead,
  });
}

abstract class FriendsReadingState extends Equatable {
  const FriendsReadingState();

  @override
  List<Object> get props => [];
}

class FriendsReadingInitial extends FriendsReadingState {}

class FriendsReadingLoading extends FriendsReadingState {}

class FriendsReadingLoaded extends FriendsReadingState {
  final List<FriendReadingStatus> friendsStatus;

  const FriendsReadingLoaded(this.friendsStatus);

  @override
  List<Object> get props => [friendsStatus];
}

class FriendsReadingError extends FriendsReadingState {
  final String message;

  const FriendsReadingError(this.message);

  @override
  List<Object> get props => [message];
}
