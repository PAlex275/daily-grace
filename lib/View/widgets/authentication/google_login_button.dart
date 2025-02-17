import 'package:all_booked/ViewModel/cubit/google_auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

ElevatedButton googleLoginButton(GoogleAuthState state, BuildContext context) {
  // Obținem tema curentă
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return ElevatedButton(
    style: ButtonStyle(
        padding: WidgetStateProperty.resolveWith(
            (states) => const EdgeInsets.only(left: 15)),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        )),
        elevation: WidgetStateProperty.resolveWith((states) => 0.5),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => isDarkMode ? Colors.grey[800] : Colors.white,
        ),
        // Adăugăm border pentru contrast mai bun
        side: WidgetStateProperty.resolveWith((states) => BorderSide(
            color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!))),
    onPressed: state is GoogleAuthLoadingState
        ? null
        : () => context.read<GoogleAuthCubit>().login(context),
    child: state is GoogleAuthLoadingState
        ? const Padding(
            padding: EdgeInsets.all(2.0),
            child: CircularProgressIndicator(),
          )
        : Row(
            children: [
              const SizedBox(
                height: 40,
                width: 40,
                child: Image(
                  image: AssetImage('assets/images/google.png'),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Text(
                'Login With Google',
                style: GoogleFonts.robotoSerif(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  // Adaptăm culoarea textului la temă
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
  );
}
