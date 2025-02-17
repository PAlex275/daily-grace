import 'package:all_booked/ViewModel/friends/friends_event.dart';
import 'package:all_booked/ViewModel/friends/friends_state.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  FriendBloc() : super(FriendsInitial()) {
    on<LoadFriends>(_onLoadFriends);
    on<AddFriend>(_onAddFriend);
    on<AcceptFriendRequest>(_onAcceptFriendRequest);
    on<RejectFriendRequest>(_onRejectFriendRequest);
    on<SearchUsers>(_onSearchUsers);
    on<LoadingFriendsEvent>((event, emit) => emit(FriendsLoading()));
    on<DeleteFriend>(_onDeleteFriend);
  }

  Future<void> _onLoadFriends(
      LoadFriends event, Emitter<FriendState> emit) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception("User not authenticated");

      final friendsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('friends')
          .get();

      final friends = await Future.wait(friendsSnapshot.docs.map((doc) async {
        final data = doc.data();
        final friendDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(doc.id)
            .get();

        return {
          ...data,
          'id': doc.id,
          'image_url': friendDoc.data()?['image_url'] ?? '',
        };
      }));

      emit(FriendsLoaded(friends));
    } catch (e) {
      emit(FriendError(e.toString()));
    }
  }

  Future<void> _onAddFriend(AddFriend event, Emitter<FriendState> emit) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception("User not authenticated");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(event.friendId)
          .set({
        'id': event.friendId,
        'status': 'pending',
        'addedAt': DateTime.now().toIso8601String(),
        'name': event.friendName,
        'email': event.friendEmail,
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(event.friendId)
          .collection('friends')
          .doc(userId)
          .set({
        'id': userId,
        'status': 'pending',
        'addedAt': DateTime.now().toIso8601String(),
        'name': event.friendName,
        'email': event.friendEmail,
      });

      emit(FriendRequestSent());
    } catch (e) {
      emit(FriendError(e.toString()));
    }
  }

  Future<void> _onAcceptFriendRequest(
      AcceptFriendRequest event, Emitter<FriendState> emit) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception("User not authenticated");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(event.friendId)
          .update({'status': 'accepted'});

      await FirebaseFirestore.instance
          .collection('users')
          .doc(event.friendId)
          .collection('friends')
          .doc(userId)
          .update({'status': 'accepted'});
      add(LoadFriends());
      emit(FriendRequestAccepted());
    } catch (e) {
      emit(FriendError(e.toString()));
    }
  }

  Future<void> _onRejectFriendRequest(
      RejectFriendRequest event, Emitter<FriendState> emit) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception("User not authenticated");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(event.friendId)
          .delete();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(event.friendId)
          .collection('friends')
          .doc(userId)
          .delete();

      add(LoadFriends());
      emit(FriendRequestRejected());
    } catch (e) {
      emit(FriendError(e.toString()));
    }
  }

  Future<void> _onSearchUsers(
      SearchUsers event, Emitter<FriendState> emit) async {
    try {
      if (event.query.trim().isNotEmpty) {
        emit(FriendsLoading());
      }

      final searchQuery = event.query.trim().toLowerCase();

      if (searchQuery.isEmpty) {
        emit(FriendsInitial());
        return;
      }

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception("User not authenticated");

      // Obține lista prietenilor
      final friendsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('friends')
          .get();

      final friendIds = friendsSnapshot.docs.map((doc) => doc.id).toSet();

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name_lowercase', isGreaterThanOrEqualTo: searchQuery)
          .where('name_lowercase', isLessThan: '${searchQuery}z')
          .get();

      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final results = querySnapshot.docs
          .where(
              (doc) => doc.id != currentUserId && !friendIds.contains(doc.id))
          .map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Utilizator necunoscut',
          'email': data['email'] ?? 'Email necunoscut',
        };
      }).toList();

      emit(SearchResultsLoaded(results));
    } catch (e) {
      if (kDebugMode) {
        print('Eroare în căutare: $e');
      }
      emit(FriendError(e.toString()));
    }
  }

  Future<void> _onDeleteFriend(
      DeleteFriend event, Emitter<FriendState> emit) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception("User not authenticated");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(event.friendId)
          .delete();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(event.friendId)
          .collection('friends')
          .doc(userId)
          .delete();

      add(LoadFriends());
      emit(FriendRequestRejected());
    } catch (e) {
      emit(FriendError(e.toString()));
    }
  }
}
