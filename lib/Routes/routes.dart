import 'package:all_booked/View/screens/add_friend_screen.dart';
import 'package:all_booked/View/screens/daily_chapters_screen.dart';
import 'package:all_booked/View/screens/friends_screen.dart';
import 'package:all_booked/View/screens/home_screen.dart';
import 'package:all_booked/View/screens/login_screen.dart';
import 'package:all_booked/View/screens/profile_screen.dart';
import 'package:all_booked/View/screens/reading_target_screen.dart';
import 'package:all_booked/View/screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: SplashScreen.routeName,
  routes: <RouteBase>[
    GoRoute(
      path: SplashScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: LoginScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: HomeScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: DailyChapterScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const DailyChapterScreen();
      },
    ),
    GoRoute(
      path: ReadingTargetScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const ReadingTargetScreen();
      },
    ),
    GoRoute(
      path: ProfileScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        final User? user = FirebaseAuth.instance.currentUser;
        return ProfileScreen(user: user);
      },
    ),
    GoRoute(
      path: FriendsScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return FriendsScreen();
      },
    ),
    GoRoute(
      path: AddFriendScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const AddFriendScreen();
      },
    ),
  ],
);
