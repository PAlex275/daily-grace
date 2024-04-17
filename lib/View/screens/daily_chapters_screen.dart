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
import 'package:table_calendar/table_calendar.dart';

class DailyChapterScreen extends StatefulWidget {
  const DailyChapterScreen({Key? key}) : super(key: key);

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

    _loadChapters();
  }

  Future<void> _loadChapters() async {
    await SharedPreferencesManager.init();
    targetReading =
        await SharedPreferencesManager.getDailyChaptersNeeded() ?? 10;
    // ignore: use_build_context_synchronously
    BlocProvider.of<DailyChapterBloc>(context)
        .add(LoadDailyChapters(targetReading));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Chapter'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
              style: const TextStyle(
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
                  title: Text(
                    ' ${verse.verse}. ${verse.text} ',
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentPage > 0
                      ? () {
                          setState(() {
                            currentPage--;
                          });
                        }
                      : null,
                  child: const Text('Înapoi'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: currentPage < chapters.length
                      ? () {
                          setState(() {
                            currentPage++;
                          });
                        }
                      : null,
                  child: const Text('Înainte'),
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
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: Text(
                'Felicitări! Ai terminat de citit pentru azi.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (!SharedPreferencesManager.getReadDays()
                    .any((day) => isSameDay(day, DateTime.now()))) {
                  await SharedPreferencesManager.addReadDay(DateTime.now());
                }

                // ignore: use_build_context_synchronously
                context.go(HomeScreen.routeName);
              },
              child: const Icon(
                Icons.done,
                color: Colors.green,
                size: 30,
              ),
            ),
          ],
        ),
      );
    }
  }
}
