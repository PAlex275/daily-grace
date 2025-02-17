abstract class FriendState {}

class FriendsInitial extends FriendState {}

class FriendsLoading extends FriendState {}

class FriendsLoaded extends FriendState {
  final List<Map<String, dynamic>> friends;

  FriendsLoaded(this.friends);
}

class FriendRequestSent extends FriendState {}

class FriendRequestAccepted extends FriendState {}

class FriendRequestRejected extends FriendState {}

class FriendError extends FriendState {
  final String message;

  FriendError(this.message);
}

class SearchResultsLoaded extends FriendState {
  final List<Map<String, dynamic>> searchResults;

  SearchResultsLoaded(this.searchResults);
}
