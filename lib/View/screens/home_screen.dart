import 'package:all_booked/View/screens/login_screen.dart';
import 'package:all_booked/View/screens/profile_screen.dart';
import 'package:all_booked/database/shared.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:all_booked/View/screens/daily_chapters_screen.dart';
import 'package:all_booked/View/widgets/authentication/logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<DateTime> _readingDays = [];

  @override
  void initState() {
    super.initState();
    _loadReadingDays();
  }

  Future<void> _loadReadingDays() async {
    await SharedPreferencesManager.init();
    // Obțineți toate zilele în care s-a citit din SharedPreferences
    List<DateTime>? readDays = SharedPreferencesManager.getReadDays();

    setState(() {
      _readingDays = readDays;
    });
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // ignore: use_build_context_synchronously
      context.go(LoginScreen.routeName);
    } catch (e) {
      print('Eroare la deconectare: $e');
      // Tratează erorile aici, dacă este necesar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: logo(
          isSmall: true,
          height: 100,
          width: 100,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.account_circle, // Icon pentru utilizator
            size: 30,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            context.go(
              ProfileScreen.routeName,
              extra: {'user': FirebaseAuth.instance.currentUser},
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: Icon(
              Icons.logout,
              size: 25,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  todayBuilder: (context, date, _) {
                    final isReadingDay =
                        _readingDays.any((day) => isSameDay(day, date));

                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isReadingDay
                            ? Colors.green
                            : Colors.grey.withOpacity(0.2),
                      ),
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                            color: isReadingDay ? Colors.white : Colors.black),
                      ),
                    );
                  },
                  defaultBuilder: (context, date, _) {
                    final isReadingDay =
                        _readingDays.any((day) => isSameDay(day, date));

                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isReadingDay
                            ? Colors.green
                            : Colors.grey.withOpacity(0.2),
                      ),
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                            color: isReadingDay ? Colors.white : Colors.black),
                      ),
                    );
                  },
                  selectedBuilder: (context, date, _) {
                    final isReadingDay =
                        _readingDays.any((day) => isSameDay(day, date));
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isReadingDay
                            ? Colors.green
                            : Colors.grey.withOpacity(0.2),
                      ),
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                            color: isReadingDay ? Colors.white : Colors.black),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: () {
                context.go(DailyChapterScreen.routeName);
              },
              child: Text(
                'Go To Your Daily Chapters',
                style: GoogleFonts.robotoSerif(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
