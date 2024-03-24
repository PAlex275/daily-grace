import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'google_auth_state.dart';

class GoogleAuthCubit extends Cubit<GoogleAuthState> {
  GoogleAuthCubit() : super(GoogleAuthInitialState());

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _auth = FirebaseAuth.instance;

  void login() async {
    emit(GoogleAuthLoadingState());
    try {
      //select google account
      final userAccount = await _googleSignIn.signIn();

      //user dismissed the account dialog
      if (userAccount == null) {
        emit(GoogleAuthDismissedState());
        return;
      }

      //get authentication object from account
      final GoogleSignInAuthentication googleAuth =
          await userAccount.authentication;

      //create QAuthCredentials from auth object
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      //Login to firebase using the credentials
      final userCredential = await _auth.signInWithCredential(credential);

      emit(GoogleAuthSuccesState(userCredential.user!));
    } catch (e) {
      emit(GoogleAuthFailedState(e.toString()));
    }
  }
}
