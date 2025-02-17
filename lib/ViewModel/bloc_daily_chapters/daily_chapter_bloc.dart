import 'package:all_booked/Model/chapter.dart';
import 'package:all_booked/ViewModel/bloc_daily_chapters/daily_chapter_event.dart';
import 'package:all_booked/ViewModel/bloc_daily_chapters/daily_chapter_state.dart';
import 'package:all_booked/database/bible_database.dart';
import 'package:all_booked/database/shared.dart';
import 'package:bloc/bloc.dart';

class DailyChapterBloc extends Bloc<DailyChapterEvent, DailyChapterState> {
  final BibleDatabase _bibleDatabase;

  DailyChapterBloc(this._bibleDatabase) : super(DailyChapterLoading()) {
    on<LoadDailyChapters>(_onLoadDailyChapters);
    on<LoadStoredChapters>(_onLoadStoredChapters);
  }

  Future<bool> _isChapterGeneratedForToday() async {
    final DateTime now = DateTime.now();
    final DateTime? lastGeneratedDate =
        SharedPreferencesManager.getLastGeneratedDate();

    if (lastGeneratedDate != null) {
      return lastGeneratedDate.year == now.year &&
          lastGeneratedDate.month == now.month &&
          lastGeneratedDate.day == now.day;
    }

    return false;
  }

  void _onLoadDailyChapters(
      LoadDailyChapters event, Emitter<DailyChapterState> emit) async {
    emit(DailyChapterLoading());
    try {
      List<Chapter> dailyChapters;
      final storedChapters = await SharedPreferencesManager.getStoredChapters();
      final isChapterGeneratedForToday = await _isChapterGeneratedForToday();

      if (isChapterGeneratedForToday && storedChapters != null) {
        dailyChapters = storedChapters;
      } else {
        dailyChapters =
            await _bibleDatabase.getDailyChapters(event.numberOfChapters);
        await SharedPreferencesManager.setStoredChapters(dailyChapters);
        await SharedPreferencesManager.setLastGeneratedDate(DateTime.now());
      }

      // Incrementăm numărul total de capitole citite
      final int currentTotalRead =
          SharedPreferencesManager.getTotalChaptersRead();
      await SharedPreferencesManager.setTotalChaptersRead(
          currentTotalRead + dailyChapters.length);

      // Salvăm în Firebase folosind noua funcție
      // await FirebaseSyncManager.saveDailyChaptersToFirebase(dailyChapters); // Comentat pentru a preveni salvarea automată

      emit(DailyChapterLoaded(dailyChapters));
    } catch (e) {
      emit(DailyChapterError('Failed to load daily chapters: $e'));
    }
  }

  void _onLoadStoredChapters(
      LoadStoredChapters event, Emitter<DailyChapterState> emit) async {
    emit(DailyChapterLoading());
    try {
      final storedChapters = await SharedPreferencesManager.getStoredChapters();
      if (storedChapters != null && storedChapters.isNotEmpty) {
        emit(DailyChapterLoaded(storedChapters));
      } else {
        emit(const DailyChapterError('No stored chapters found'));
      }
    } catch (e) {
      emit(DailyChapterError('Failed to load stored chapters: $e'));
    }
  }
}
