import 'package:all_booked/View/screens/reading_target_screen.dart';
import 'package:all_booked/View/widgets/authentication/google_login_button.dart';
import 'package:all_booked/View/widgets/authentication/logo.dart';
import 'package:all_booked/ViewModel/cubit/google_auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDarkMode ? Theme.of(context).colorScheme.surface : Colors.white,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Spacer(
              flex: 1,
            ),
            Theme(
              data: Theme.of(context).copyWith(
                iconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: logo(),
            ),
            const SizedBox(
              height: 100,
            ),
            BlocConsumer<GoogleAuthCubit, GoogleAuthState>(
              listener: (context, state) {
                state is GoogleAuthSuccesState
                    ? context.replace(ReadingTargetScreen.routeName)
                    : null;
              },
              builder: (context, state) {
                return Container(
                  height: 50,
                  width: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: googleLoginButton(state, context),
                );
              },
            ),
            const SizedBox(
              height: 10,
            ),
            const Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }
}
