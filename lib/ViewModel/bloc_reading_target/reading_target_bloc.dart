import 'package:all_booked/ViewModel/bloc_reading_target/reading_target_event.dart';
import 'package:all_booked/ViewModel/bloc_reading_target/reading_target_state.dart';
import 'package:all_booked/ViewModel/firebase_sync/firebase_sync_manager.dart';
import 'package:all_booked/database/shared.dart';
import 'package:bloc/bloc.dart';

class ReadingTargetBloc extends Bloc<ReadingTargetEvent, ReadingTargetState> {
  ReadingTargetBloc() : super(ReadingTargetInitial()) {
    on<SetTargetReading>(_mapSetTargetReadingToState);
    on<InitializeReadingTarget>(_mapInitializeReadingTargetToState);
  }

  void _mapSetTargetReadingToState(
      SetTargetReading event, Emitter<ReadingTargetState> emit) async {
    emit(ReadingTargetLoading());

    try {
      const int totalChaptersInBible = 1189;
      const int daysInYear = 365;

      // Obține zilele citite și capitolele citite
      final List<DateTime> readDays = SharedPreferencesManager.getReadDays();
      final int daysRead = readDays.length;
      final int chaptersRead = SharedPreferencesManager.getTotalChaptersRead();

      // Calculează zilele și capitolele rămase
      final int daysLeftInYear = daysInYear - daysRead;
      final int chaptersLeft = totalChaptersInBible - chaptersRead;

      // Calculează numărul total de capitole de citit în funcție de target
      final int totalChaptersToRead = chaptersLeft * event.targetReading;

      // Calculează capitolele zilnice necesare
      final double dailyChaptersNeeded = daysLeftInYear > 0
          ? totalChaptersToRead / daysLeftInYear
          : totalChaptersToRead.toDouble(); // Evită împărțirea la zero
      final int roundedDailyChaptersNeeded = dailyChaptersNeeded.ceil();

      await SharedPreferencesManager.setReadingTarget(event.targetReading);
      await SharedPreferencesManager.setDailyChaptersNeeded(
          roundedDailyChaptersNeeded);

      await FirebaseSyncManager.updateReadingTargetInFirebase(
          event.targetReading, roundedDailyChaptersNeeded);

      emit(ReadingTargetSet(event.targetReading, roundedDailyChaptersNeeded));
    } catch (e) {
      emit(ReadingTargetError('Failed to set target reading: $e'));
    }
  }

  void _mapInitializeReadingTargetToState(
      InitializeReadingTarget event, Emitter<ReadingTargetState> emit) async {
    try {
      final int? targetReading =
          await SharedPreferencesManager.getReadingTarget();
      final int? chaptersNeeded =
          await SharedPreferencesManager.getDailyChaptersNeeded();
      emit(ReadingTargetSet(targetReading ?? 1, chaptersNeeded ?? 4));
    } catch (e) {
      emit(ReadingTargetError('Failed to initialize: $e'));
    }
  }
}
