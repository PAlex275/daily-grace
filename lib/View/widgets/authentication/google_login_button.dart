import 'package:all_booked/ViewModel/cubit/google_auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

ElevatedButton googleLoginButton(GoogleAuthState state, BuildContext context) {
  return ElevatedButton(
    style: ButtonStyle(
        padding: MaterialStateProperty.resolveWith(
            (states) => const EdgeInsets.only(left: 15)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        )),
        elevation: MaterialStateProperty.resolveWith((states) => 0.3),
        backgroundColor: MaterialStateColor.resolveWith(
          (states) => Colors.white,
        )),
    onPressed: state is GoogleAuthLoadingState
        ? null
        : () => context.read<GoogleAuthCubit>().login(),
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
                width: 10,
              ),
              Text(
                'Login With Google',
                style: GoogleFonts.robotoSerif(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
  );
}
