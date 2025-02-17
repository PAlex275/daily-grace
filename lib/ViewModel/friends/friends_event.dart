abstract class FriendEvent {}

class LoadFriends extends FriendEvent {}

class LoadingFriendsEvent extends FriendEvent {
  LoadingFriendsEvent();
}

class AddFriend extends FriendEvent {
  final String friendId;
  final String friendName;
  final String friendEmail;
  final String imageUrl;

  AddFriend(this.friendId, this.friendName, this.friendEmail, this.imageUrl);
}

class AcceptFriendRequest extends FriendEvent {
  final String friendId;

  AcceptFriendRequest(this.friendId);
}

class RejectFriendRequest extends FriendEvent {
  final String friendId;

  RejectFriendRequest(this.friendId);
}

class SearchUsers extends FriendEvent {
  final String query;

  SearchUsers(this.query);
}

class DeleteFriend extends FriendEvent {
  final String friendId;
  DeleteFriend(this.friendId);
}
