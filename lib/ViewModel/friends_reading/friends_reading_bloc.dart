import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'friends_reading_event.dart';
import 'friends_reading_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsReadingBloc
    extends Bloc<FriendsReadingEvent, FriendsReadingState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FriendsReadingBloc() : super(FriendsReadingInitial()) {
    on<LoadFriendsReadingStatus>(_onLoadFriendsReadingStatus);
    on<UpdateFriendsReadingStatus>(_onUpdateFriendsReadingStatus);
  }

  Future<void> _onLoadFriendsReadingStatus(
    LoadFriendsReadingStatus event,
    Emitter<FriendsReadingState> emit,
  ) async {
    try {
      emit(FriendsReadingLoading());

      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not authenticated");

      final friendsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .where('status', isEqualTo: 'accepted')
          .get();

      List<FriendReadingStatus> friendsStatus = [];

      for (var friend in friendsSnapshot.docs) {
        final friendId = friend.id;

        // Verifică progresul

        final progressSnapshot =
            await _firestore.collection('user_progress').doc(friendId).get();

        if (progressSnapshot.exists) {
          final progressData = progressSnapshot.data()!;

          final List<String> readDays =
              List<String>.from(progressData['readDays'] ?? []);

          // Verifică dacă prietenul a citit azi
          final bool hasReadToday = readDays.any((day) =>
              DateTime.parse(day).day == DateTime.now().day &&
              DateTime.parse(day).month == DateTime.now().month &&
              DateTime.parse(day).year == DateTime.now().year);

          // Obține capitolele citite azi
          List<String> chaptersRead = [];
          if (hasReadToday) {
            final todayReadingsSnapshot = await _firestore
                .collection('user_progress')
                .doc(friendId)
                .collection('daily_readings')
                .doc(DateTime.now().toIso8601String().split('T')[0])
                .get();

            if (todayReadingsSnapshot.exists) {
              chaptersRead = List<String>.from(
                  todayReadingsSnapshot.data()?['chapters'] ?? []);
            }
          }

          // Obține datele utilizatorului
          final userSnapshot =
              await _firestore.collection('users').doc(friendId).get();

          final userData = userSnapshot.data() ?? {};

          friendsStatus.add(FriendReadingStatus(
            userId: friendId,
            name: userData['name'] ?? 'Utilizator necunoscut',
            avatarUrl: userData['image_url'] ?? '',
            hasReadToday: hasReadToday,
            chaptersRead: chaptersRead,
          ));
        }
      }

      emit(FriendsReadingLoaded(friendsStatus));
    } catch (e) {
      if (kDebugMode) {
        print('Error caught: $e');
      }
      emit(FriendsReadingError(e.toString()));
    }
  }

  Future<void> _onUpdateFriendsReadingStatus(
    UpdateFriendsReadingStatus event,
    Emitter<FriendsReadingState> emit,
  ) async {
    try {
      add(LoadFriendsReadingStatus());
    } catch (e) {
      emit(FriendsReadingError(e.toString()));
    }
  }
}
