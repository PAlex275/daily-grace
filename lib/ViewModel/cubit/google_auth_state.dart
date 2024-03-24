part of 'google_auth_cubit.dart';

abstract class GoogleAuthState {}

final class GoogleAuthInitialState extends GoogleAuthState {}

final class GoogleAuthLoadingState extends GoogleAuthState {}

final class GoogleAuthDismissedState extends GoogleAuthState {}

final class GoogleAuthSuccesState extends GoogleAuthState {
  final User user;

  GoogleAuthSuccesState(this.user);
}

final class GoogleAuthFailedState extends GoogleAuthState {
  final String error;

  GoogleAuthFailedState(this.error);
}
