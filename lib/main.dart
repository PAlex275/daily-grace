import 'package:all_booked/Routes/routes.dart';
import 'package:all_booked/ViewModel/bloc_daily_chapters/daily_chapter_bloc.dart';
import 'package:all_booked/ViewModel/bloc_reading_target/reading_target_bloc.dart';

import 'package:all_booked/ViewModel/cubit/google_auth_cubit.dart';
import 'package:all_booked/ViewModel/firebase_sync/firebase_sync_manager.dart';
import 'package:all_booked/ViewModel/friends/friends_bloc.dart';
import 'package:all_booked/database/bible_database.dart';
import 'package:all_booked/database/shared.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_booked/ViewModel/friends_reading/friends_reading_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPreferencesManager.init();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Creăm instanța BibleDatabase
  final bibleDatabase = BibleDatabase.instance;

  // Creăm instanța FirebaseSyncManager
  final firebaseSyncManager = FirebaseSyncManager(bibleDatabase);

  // Bloc.observer = MyBlocObserver();

  runApp(MyApp(prefs: prefs, firebaseSyncManager: firebaseSyncManager));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final FirebaseSyncManager firebaseSyncManager;

  const MyApp(
      {super.key, required this.prefs, required this.firebaseSyncManager});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GoogleAuthCubit(firebaseSyncManager)),
        BlocProvider(create: (_) => DailyChapterBloc(BibleDatabase.instance)),
        BlocProvider(create: (_) => ReadingTargetBloc()),
        BlocProvider(create: (_) => FriendBloc()),
        BlocProvider(create: (_) => FriendsReadingBloc()),
      ],
      child: MaterialApp.router(
        title: 'Daily Grace',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFFF4A261),
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark,
            seedColor: Color(0xFFFFB74D),
            surface: Colors.black,
            onSurface: Colors.white,
          ),
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}
