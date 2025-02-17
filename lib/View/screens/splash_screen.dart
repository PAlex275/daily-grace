import 'package:all_booked/View/screens/home_screen.dart';
import 'package:all_booked/View/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    init(GoRouter.of(context));
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Center(
        child: Image(
          image: AssetImage('assets/images/daily_grace.png'),
        ),
      ),
    );
  }

  Future<void> init(GoRouter router) async {
    FirebaseAuth.instance.currentUser != null
        ? Future.delayed(const Duration(milliseconds: 1500),
            () => router.pushReplacement(HomeScreen.routeName))
        : Future.delayed(const Duration(milliseconds: 1500),
            () => router.pushReplacement(LoginScreen.routeName));
  }
}
