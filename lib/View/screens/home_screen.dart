import 'package:all_booked/View/screens/profile_screen.dart';
import 'package:all_booked/ViewModel/bloc_daily_chapters/daily_chapter_bloc.dart';
import 'package:all_booked/ViewModel/bloc_daily_chapters/daily_chapter_event.dart';
import 'package:all_booked/ViewModel/bloc_daily_chapters/daily_chapter_state.dart';
import 'package:all_booked/database/shared.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:all_booked/View/screens/daily_chapters_screen.dart';
import 'package:all_booked/View/widgets/authentication/logo.dart';
import 'package:all_booked/ViewModel/friends_reading/friends_reading_bloc.dart';
import 'package:all_booked/ViewModel/friends_reading/friends_reading_state.dart';
import 'package:all_booked/ViewModel/friends_reading/friends_reading_event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
    context.read<FriendsReadingBloc>().add(LoadFriendsReadingStatus());
    loadChapters(context);
    context.read<DailyChapterBloc>().add(LoadStoredChapters());
  }

  Future<void> _loadReadingDays() async {
    await SharedPreferencesManager.init();

    List<DateTime>? readDays = SharedPreferencesManager.getReadDays();

    setState(() {
      _readingDays = readDays;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.grey[800];
    final iconColor =
        isDarkMode ? Colors.white : Theme.of(context).primaryColor;
    final containerColor = isDarkMode ? Color(0xFF2C2C2C) : Colors.grey[50];
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final calendarTextColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: isDarkMode ? Colors.black : Colors.white,
        shadowColor: isDarkMode ? Colors.white24 : Colors.black26,
        title: Padding(
          padding: const EdgeInsets.only(top: 45),
          child: logo(
            isSmall: true,
            height: 180,
            width: 180,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.account_circle,
              size: 30,
              color: iconColor,
            ),
            onPressed: () {
              context.go(
                ProfileScreen.routeName,
                extra: {'user': FirebaseAuth.instance.currentUser},
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
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
                headerStyle: HeaderStyle(
                  formatButtonTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  todayBuilder: (context, date, _) {
                    final isReadingDay =
                        _readingDays.any((day) => isSameDay(day, date));
                    final isToday = isSameDay(date, DateTime.now());

                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isReadingDay
                            ? Colors.green.withOpacity(isDarkMode ? 0.3 : 0.6)
                            : Colors.grey.withOpacity(0.2),
                        border: isToday
                            ? Border.all(
                                color: isDarkMode
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.primary,
                                width: 1,
                              )
                            : null,
                      ),
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color: calendarTextColor,
                        ),
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
                            ? Colors.green.withOpacity(isDarkMode ? 0.3 : 0.6)
                            : Colors.grey.withOpacity(0.2),
                      ),
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color: calendarTextColor,
                        ),
                      ),
                    );
                  },
                  selectedBuilder: (context, date, _) {
                    final isReadingDay =
                        _readingDays.any((day) => isSameDay(day, date));
                    final isToday = isSameDay(date, DateTime.now());

                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isReadingDay
                            ? Colors.green.withOpacity(isDarkMode ? 0.3 : 0.5)
                            : Colors.grey.withOpacity(0.2),
                      ),
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isReadingDay || isToday && isReadingDay
                              ? Colors.white
                              : calendarTextColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black26
                        : Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.black
                          : Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      border: Border.all(
                        color: borderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          color: iconColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Lectura de Astăzi',
                          style: GoogleFonts.robotoSerif(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  BlocBuilder<DailyChapterBloc, DailyChapterState>(
                    builder: (context, state) {
                      if (state is DailyChapterLoading) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (state is DailyChapterError ||
                          (state is DailyChapterLoaded &&
                              state.dailyChapters.isEmpty)) {
                        return Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.book_outlined,
                                size: 48,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nu ai capitole de citit pentru astăzi',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.robotoSerif(
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  context
                                      .read<DailyChapterBloc>()
                                      .add(LoadDailyChapters(3));
                                },
                                child: Text(
                                  'Generează capitole noi',
                                  style: GoogleFonts.robotoSerif(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is DailyChapterLoaded) {
                        Map<String, List<int>> groupedChapters = {};
                        for (var chapter in state.dailyChapters) {
                          if (!groupedChapters.containsKey(chapter.bookName)) {
                            groupedChapters[chapter.bookName] = [];
                          }
                          groupedChapters[chapter.bookName]!
                              .add(chapter.chapterNumber);
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: containerColor,
                            border: Border(
                              top: BorderSide.none,
                              left: BorderSide(color: borderColor),
                              right: BorderSide(color: borderColor),
                              bottom: BorderSide(color: borderColor),
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              ...groupedChapters.entries.map((entry) {
                                final chapters = entry.value..sort();
                                final chapterText = chapters.length == 1
                                    ? '${entry.key} ${chapters[0]}'
                                    : '${entry.key} ${chapters.first}-${chapters.last}';

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: containerColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: borderColor,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.bookmark,
                                            color: iconColor,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          chapterText,
                                          style: GoogleFonts.robotoSerif(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.go(DailyChapterScreen.routeName);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDarkMode
                                        ? Colors.black
                                        : Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.play_arrow_rounded),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Începe să citești',
                                        style: GoogleFonts.robotoSerif(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildFriendsReadingStatus(),
            const SizedBox(height: 40),
            // Secțiunea de provocări active
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsReadingStatus() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.grey[800];
    final iconColor =
        isDarkMode ? Colors.white : Theme.of(context).primaryColor;
    final containerColor = isDarkMode ? Colors.black : Colors.grey[50];
    final borderColor =
        isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[300]!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 8.0),
            child: Row(
              children: [
                Icon(
                  Icons.people,
                  color: iconColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Activitatea Prietenilor',
                  style: GoogleFonts.robotoSerif(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: BlocBuilder<FriendsReadingBloc, FriendsReadingState>(
              builder: (context, state) {
                if (state is FriendsReadingLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is FriendsReadingLoaded) {
                  if (state.friendsStatus.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          Icon(Icons.people_outline,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'Nu ai prieteni încă',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isDarkMode ? borderColor : Colors.white70),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.friendsStatus.length,
                      itemBuilder: (context, index) {
                        final friend = state.friendsStatus[index];

                        // Grupăm capitolele după carte
                        Map<String, List<int>> groupedChapters = {};
                        for (String chapter in friend.chaptersRead) {
                          final parts = chapter.split(' ');
                          if (parts.length == 2) {
                            final bookName = parts[0];
                            final chapterNum = int.tryParse(parts[1]);
                            if (chapterNum != null) {
                              if (!groupedChapters.containsKey(bookName)) {
                                groupedChapters[bookName] = [];
                              }
                              groupedChapters[bookName]!.add(chapterNum);
                            }
                          }
                        }

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  friend.avatarUrl.isNotEmpty
                                      ? CircleAvatar(
                                          radius: 20,
                                          backgroundImage:
                                              NetworkImage(friend.avatarUrl),
                                        )
                                      : CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.grey.shade200,
                                          child: const Icon(Icons.person),
                                        ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          friend.name,
                                          style: GoogleFonts.robotoSerif(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: textColor,
                                          ),
                                        ),
                                        if (friend.hasReadToday) ...[
                                          const SizedBox(height: 4),
                                          ...groupedChapters.entries
                                              .map((entry) {
                                            final chapters = entry.value
                                              ..sort();
                                            final chapterText = chapters
                                                        .length ==
                                                    1
                                                ? '${entry.key} ${chapters[0]}'
                                                : '${entry.key} ${chapters.first}-${chapters.last}';

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: containerColor,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: borderColor,
                                                  ),
                                                ),
                                                child: Text(
                                                  chapterText,
                                                  style:
                                                      GoogleFonts.robotoSerif(
                                                    fontSize: 12,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                        ] else
                                          Text(
                                            'Nu a citit încă astăzi',
                                            style: GoogleFonts.robotoSerif(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    friend.hasReadToday
                                        ? Icons.check_circle
                                        : Icons.timer,
                                    color: friend.hasReadToday
                                        ? Colors.green.withOpacity(0.6)
                                        : (isDarkMode
                                            ? Colors.white70
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary),
                                  ),
                                ],
                              ),
                            ),
                            if (index < state.friendsStatus.length - 1)
                              Divider(height: 1, color: Colors.grey.shade300),
                          ],
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
