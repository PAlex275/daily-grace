import 'package:all_booked/View/screens/friends_screen.dart';
import 'package:all_booked/View/screens/home_screen.dart';
import 'package:all_booked/View/screens/reading_target_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:all_booked/database/shared.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:all_booked/ViewModel/bloc_reading_target/reading_target_bloc.dart';
import 'package:all_booked/ViewModel/bloc_reading_target/reading_target_state.dart';
import 'package:all_booked/ViewModel/cubit/google_auth_cubit.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';

  final User? user;

  const ProfileScreen({super.key, required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int selectedFrequency = 1;
  int dailyChaptersNeeded = 4;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSharedPreferences();
  }

  void _loadSharedPreferences() async {
    final int? targetReading =
        await SharedPreferencesManager.getReadingTarget();
    setState(() {
      selectedFrequency = targetReading ?? 1;
      dailyChaptersNeeded = (selectedFrequency * 1189 / 365).ceil();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = CupertinoTheme.of(context).primaryColor;
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    final Color backgroundColor =
        isDarkMode ? const Color(0xFF1a1a1a) : CupertinoColors.systemBackground;

    return BlocListener<ReadingTargetBloc, ReadingTargetState>(
      listener: (context, state) {
        if (state is ReadingTargetError) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Text(
                'Eroare',
                style: GoogleFonts.robotoSerif(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemRed,
                ),
              ),
              content: Text(
                state.message,
                style: GoogleFonts.robotoSerif(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
      },
      child: CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: backgroundColor.withOpacity(0.8),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              CupertinoIcons.back,
              color: primaryColor,
              size: 28,
            ),
            onPressed: () => context.go(HomeScreen.routeName),
          ),
          middle: Text(
            'Profil',
            style: GoogleFonts.robotoSerif(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ).copyWith(decoration: TextDecoration.none),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor.withOpacity(0.3),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.1),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: widget.user?.photoURL != null
                          ? NetworkImage(widget.user!.photoURL!)
                          : null,
                      backgroundColor: CupertinoColors.systemGrey6,
                      child: widget.user?.photoURL == null
                          ? Icon(
                              CupertinoIcons.person_alt,
                              size: 60,
                              color: primaryColor.withOpacity(0.7),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.user?.displayName ?? 'Utilizator',
                    style: GoogleFonts.robotoSerif(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: 0.5,
                    ).copyWith(decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 50),
                  _buildMenuItem(
                    icon: CupertinoIcons.person_2_fill,
                    title: 'Prieteni',
                    onTap: () => context.push(FriendsScreen.routeName),
                    color: primaryColor,
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    icon: CupertinoIcons.chart_bar_fill,
                    title: 'Modifica obiectivul anual',
                    onTap: () => context.push(ReadingTargetScreen.routeName),
                    color: primaryColor,
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    icon: CupertinoIcons.trash,
                    title: 'Șterge contul',
                    onTap: () => _showDeleteAccountConfirmationDialog(context),
                    color: primaryColor,
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    icon: CupertinoIcons.power,
                    title: 'Deconectare',
                    onTap: () => _showLogoutConfirmationDialog(context),
                    color: primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final Color containerColor =
        isDarkMode ? const Color(0xFF2c2c2c) : CupertinoColors.white;
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.robotoSerif(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  letterSpacing: 0.3,
                ).copyWith(decoration: TextDecoration.none),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: color.withOpacity(0.5),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Ești sigur că vrei să te deconectezi?'),
        actions: [
          CupertinoDialogAction(
            child: Text('Anulează'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: Text('Deconectează-mă'),
            onPressed: () {
              context.read<GoogleAuthCubit>().logout(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmationDialog(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Ești sigur că vrei să îți ștergi contul?'),
        actions: [
          CupertinoActionSheetAction(
            child: Text(
              'Șterge contul',
              style: GoogleFonts.robotoSerif(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.systemRed,
              ),
            ),
            onPressed: () {
              // Logica pentru ștergerea contului
              context.read<GoogleAuthCubit>().deleteAccount(context);
              Navigator.pop(context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: true,
          child: Text(
            'Anulează',
            style: GoogleFonts.robotoSerif(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
      ),
    );
  }
}
