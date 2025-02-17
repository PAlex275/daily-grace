import 'package:all_booked/Model/chapter.dart';
import 'package:all_booked/Model/verset.dart';
import 'package:all_booked/View/screens/home_screen.dart';
import 'package:all_booked/ViewModel/bloc_daily_chapters/daily_chapter_bloc.dart';
import 'package:all_booked/ViewModel/bloc_daily_chapters/daily_chapter_event.dart';
import 'package:all_booked/ViewModel/bloc_daily_chapters/daily_chapter_state.dart';

import 'package:all_booked/database/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:all_booked/ViewModel/firebase_sync/firebase_sync_manager.dart';

class DailyChapterScreen extends StatefulWidget {
  const DailyChapterScreen({super.key});

  static const String routeName = '/daily';

  @override
  // ignore: library_private_types_in_public_api
  _DailyChapterScreenState createState() => _DailyChapterScreenState();
}

class _DailyChapterScreenState extends State<DailyChapterScreen> {
  int currentPage = 0;
  late List<Chapter> chapters;
  int targetReading = 0;

  @override
  void initState() {
    super.initState();

    loadChapters(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: isDarkMode ? Colors.black : Colors.white,
        shadowColor: isDarkMode ? Colors.black12 : Colors.black26,
        title: Text(
          'Capitolele Zilei',
          style: GoogleFonts.robotoSerif(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            context.go(HomeScreen.routeName);
          },
        ),
      ),
      body: BlocBuilder<DailyChapterBloc, DailyChapterState>(
        builder: (context, state) {
          if (state is DailyChapterLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DailyChapterLoaded) {
            chapters = state.dailyChapters;

            return _buildChapterPage();
          } else if (state is DailyChapterError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return Container();
        },
      ),
    );
  }

  Widget _buildChapterPage() {
    if (currentPage < chapters.length) {
      Chapter chapter = chapters[currentPage];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Text(
              '${chapter.bookName} ${chapter.chapterNumber}',
              style: GoogleFonts.robotoSerif(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 23,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: chapter.verses.length,
              itemBuilder: (context, index) {
                final Verset verse = chapter.verses[index];
                return ListTile(
                  contentPadding:
                      EdgeInsets.only(bottom: 1, left: 10, right: 5, top: 1),
                  title: Text(
                    ' ${verse.verse}. ${verse.text} ',
                    style: GoogleFonts.robotoSerif(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    surfaceTintColor: Theme.of(context).colorScheme.onSurface,
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onPressed: currentPage > 0
                      ? () {
                          setState(() {
                            currentPage--;
                          });
                        }
                      : null,
                  child: Text(
                    'Înapoi',
                    style: GoogleFonts.robotoSerif(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    surfaceTintColor: Theme.of(context).colorScheme.onSurface,
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onPressed: currentPage < chapters.length
                      ? () {
                          setState(() {
                            currentPage++;
                          });
                        }
                      : null,
                  child: Text(
                    'Înainte',
                    style: GoogleFonts.robotoSerif(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: Text(
                'Felicitări! Ai terminat de citit pentru azi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (!SharedPreferencesManager.getReadDays()
                    .any((day) => isSameDay(day, DateTime.now()))) {
                  await SharedPreferencesManager.addReadDay(DateTime.now());
                }

                // Salvăm capitolele în Firebase după ce utilizatorul finalizează citirea
                await FirebaseSyncManager.saveDailyChaptersToFirebase(chapters);

                // ignore: use_build_context_synchronously
                context.go(HomeScreen.routeName);
              },
              child: Icon(
                Icons.done,
                color: Theme.of(context).colorScheme.primary,
                size: 30,
              ),
            ),
          ],
        ),
      );
    }
  }
}

Future<void> loadChapters(BuildContext context) async {
  await SharedPreferencesManager.init();
  final targetReading =
      await SharedPreferencesManager.getDailyChaptersNeeded() ?? 10;
  // ignore: use_build_context_synchronously
  BlocProvider.of<DailyChapterBloc>(context)
      .add(LoadDailyChapters(targetReading));
}
