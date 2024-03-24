import 'package:all_booked/ViewModel/bloc_reading_target/reading_target_event.dart';
import 'package:all_booked/ViewModel/bloc_reading_target/reading_target_state.dart';
import 'package:all_booked/database/shared.dart';
import 'package:bloc/bloc.dart';

class ReadingTargetBloc extends Bloc<ReadingTargetEvent, ReadingTargetState> {
  ReadingTargetBloc() : super(ReadingTargetLoading()) {
    on<SetTargetReading>(_mapSetTargetReadingToState);
  }

  void _mapSetTargetReadingToState(
      SetTargetReading event, Emitter<ReadingTargetState> emit) async {
    emit(ReadingTargetLoading());

    try {
      const int totalChaptersInBible = 1189;
      const int daysInYear = 365;

      final int totalChaptersToRead =
          totalChaptersInBible * event.targetReading;
      final double dailyChaptersNeeded = totalChaptersToRead / daysInYear;
      final int roundedDailyChaptersNeeded = dailyChaptersNeeded.ceil();

      await SharedPreferencesManager.setReadingTarget(event.targetReading);
      await SharedPreferencesManager.setDailyChaptersNeeded(
          roundedDailyChaptersNeeded);

      emit(ReadingTargetSet(event.targetReading, roundedDailyChaptersNeeded));
    } catch (e) {
      emit(ReadingTargetError('Failed to set target reading: $e'));
    }
  }
}
