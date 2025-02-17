import 'package:all_booked/database/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:all_booked/ViewModel/bloc_reading_target/reading_target_bloc.dart';
import 'package:all_booked/ViewModel/bloc_reading_target/reading_target_event.dart';
import 'package:all_booked/ViewModel/bloc_reading_target/reading_target_state.dart';

import 'package:all_booked/View/screens/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ReadingTargetScreen extends StatefulWidget {
  const ReadingTargetScreen({super.key});

  static const String routeName = '/readingtarget';

  @override
  _ReadingTargetScreenState createState() => _ReadingTargetScreenState();
}

class _ReadingTargetScreenState extends State<ReadingTargetScreen> {
  int selectedFrequency = 1;
  int dailyChaptersNeeded = 4;
  late final ReadingTargetBloc _readingTargetBloc;

  @override
  void initState() {
    super.initState();
    _readingTargetBloc = ReadingTargetBloc();
    _loadSharedPreferences();
  }

  @override
  void dispose() {
    _readingTargetBloc.close();
    super.dispose();
  }

  void _updateSelectedFrequency(int frequency) {
    _readingTargetBloc.add(SetTargetReading(frequency));
    _navigateToHome(context);
  }

  void _loadSharedPreferences() async {
    _readingTargetBloc.add(InitializeReadingTarget());
    final int? targetReading =
        await SharedPreferencesManager.getReadingTarget();
    final int? chaptersNeeded =
        await SharedPreferencesManager.getDailyChaptersNeeded();
    setState(() {
      selectedFrequency = targetReading ?? 1;
      dailyChaptersNeeded = chaptersNeeded ?? 4;
    });
  }

  void _navigateToHome(BuildContext context) {
    context.go(HomeScreen.routeName);
  }

  void _calculateDailyChapters(int frequency) {
    setState(() {
      dailyChaptersNeeded = ((1189 * frequency) / 365).ceil();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _readingTargetBloc,
      child: BlocConsumer<ReadingTargetBloc, ReadingTargetState>(
        listener: (context, state) {
          if (state is ReadingTargetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              title: Text(
                'Setare citire Biblie',
                style: GoogleFonts.robotoSerif(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ),
            body: state is ReadingTargetLoading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: const Image(
                              image:
                                  AssetImage('assets/images/citirezilnica.png'),
                            ),
                          ),
                        ),
                        const Spacer(
                          flex: 2,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Text(
                            'Selectați de câte ori doriți să citiți Biblia pe an:',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: 'RobotoSerif',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Slider(
                          value: selectedFrequency.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: selectedFrequency.round().toString(),
                          onChanged: (value) {
                            setState(() {
                              selectedFrequency = value.toInt();
                              _calculateDailyChapters(selectedFrequency);
                            });
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
                                return Text(
                                  frequency.toString(),
                                  style: GoogleFonts.robotoSerif(
                                    fontSize: 14,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 50.0),
                        Text(
                          'Trebuie să citiți zilnic $dailyChaptersNeeded capitole.',
                          style: GoogleFonts.robotoSerif(
                            fontSize: 16.0,
                          ),
                        ),
                        const Spacer(flex: 3),
                      ],
                    ),
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _updateSelectedFrequency(selectedFrequency),
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(Icons.arrow_forward,
                  color: Theme.of(context).colorScheme.onPrimary),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        },
      ),
    );
  }
}
