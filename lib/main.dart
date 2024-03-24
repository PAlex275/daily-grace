import 'package:all_booked/Routes/routes.dart';
import 'package:all_booked/ViewModel/bloc/daily_chapter_bloc.dart';
import 'package:all_booked/ViewModel/bloc_reading_target/reading_target_bloc.dart';
import 'package:all_booked/ViewModel/cubit/google_auth_cubit.dart';
import 'package:all_booked/database/bible_database.dart';
import 'package:all_booked/database/shared.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  await SharedPreferencesManager.init();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GoogleAuthCubit()),
        BlocProvider(create: (_) => DailyChapterBloc(BibleDatabase.instance)),
        BlocProvider(create: (_) => ReadingTargetBloc()),
      ],
      child: MaterialApp.router(
        title: 'All Booked',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}
