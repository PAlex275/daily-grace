import 'package:all_booked/ViewModel/firebase_sync/firebase_sync_manager.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:all_booked/database/shared.dart';
import 'package:go_router/go_router.dart';
import 'package:all_booked/View/screens/login_screen.dart';
import 'package:all_booked/database/bible_database.dart';

part 'google_auth_state.dart';

class GoogleAuthCubit extends Cubit<GoogleAuthState> {
  GoogleAuthCubit(this._firebaseSyncManager) : super(GoogleAuthInitialState());

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _auth = FirebaseAuth.instance;
  final FirebaseSyncManager _firebaseSyncManager;

  void login(BuildContext context) async {
    emit(GoogleAuthLoadingState());
    try {
      final userAccount = await _googleSignIn.signIn();

      if (userAccount == null) {
        emit(GoogleAuthDismissedState());
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await userAccount.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': userCredential.user!.displayName ?? 'Utilizator necunoscut',
        'email': userCredential.user!.email ?? 'Email necunoscut',
        'name_lowercase':
            (userCredential.user!.displayName ?? 'Utilizator necunoscut')
                .toLowerCase(),
        'image_url': userCredential.user!.photoURL ?? '',
        'lastLogin': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      await _firebaseSyncManager.syncUserProgress();

      emit(GoogleAuthSuccesState(userCredential.user!));
    } catch (e) {
      if (kDebugMode) {
        print('Eroare în timpul autentificării: $e');
      }
      emit(GoogleAuthFailedState(e.toString()));
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      emit(GoogleAuthLoadingState());

      // Șterge toate datele din SharedPreferences
      await SharedPreferencesManager.clearAll();

      // Șterge toate datele din baza de date locală
      await BibleDatabase.instance.clearAllData();

      // Deconectare din Firebase
      await _auth.signOut();
      await _googleSignIn.signOut();

      emit(GoogleAuthInitialState());

      if (context.mounted) {
        context.go(LoginScreen.routeName);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Eroare la deconectare: $e');
      }
      emit(GoogleAuthFailedState(e.toString()));
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      emit(GoogleAuthLoadingState());

      // Șterge contul din Firebase
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }

      // Deconectare din cont
      if (context.mounted) {
        await logout(context);
      }

      emit(GoogleAuthInitialState());
    } catch (e) {
      if (kDebugMode) {
        print('Eroare la ștergerea contului: $e');
      }
      emit(GoogleAuthFailedState(e.toString()));
    }
  }
}
