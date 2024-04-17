import 'package:all_booked/View/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:all_booked/database/shared.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';

  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

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

  void _updateSelectedFrequency(int frequency) {
    setState(() {
      selectedFrequency = frequency;
      dailyChaptersNeeded = (frequency * 1189 / 365).ceil();
    });
  }

  void _saveAndNavigate(BuildContext context) async {
    setState(() {
      isSaving = true;
    });
    await SharedPreferencesManager.setReadingTarget(selectedFrequency);
    await SharedPreferencesManager.setDailyChaptersNeeded(dailyChaptersNeeded);

    await Future.delayed(const Duration(seconds: 2));
    print(await SharedPreferencesManager.getDailyChaptersNeeded());
    print(await SharedPreferencesManager.getReadingTarget());
    setState(() {
      isSaving = false;
    });
    // context.go(HomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        leading: IconButton(
          onPressed: () {
            context.go(HomeScreen.routeName);
          },
          icon: const Icon(
            Icons.navigate_before_outlined,
            size: 25,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(widget.user.photoURL!),
            ),
            const SizedBox(height: 20),
            Text(
              '${widget.user.displayName}',
              style: GoogleFonts.robotoSerif(
                fontSize: 25,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(
              flex: 2,
            ),
            const Text(
              'Selectați de câte ori doriți să citiți Biblia pe an:',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Slider(
              value: selectedFrequency.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: selectedFrequency.round().toString(),
              onChanged: (value) {
                _updateSelectedFrequency(value.toInt());
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  10,
                  (index) {
                    final frequency = index + 1;
                    return Padding(
                      padding: const EdgeInsets.only(left: 3),
                      child: Text(
                        frequency.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Trebuie să citiți zilnic $dailyChaptersNeeded capitole.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: isSaving
                  ? Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white.withOpacity(0.9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.1), // Culoarea umbrei
                            spreadRadius: 1,
                            offset: const Offset(
                                0, 0.5), // Offset-ul umbrei (poziția)
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.check,
                          size: 25,
                          key: ValueKey<bool>(isSaving),
                          color: Colors.green,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () => _saveAndNavigate(context),
                      child: const Text('Salvați'),
                    ),
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
