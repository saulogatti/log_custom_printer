import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_custom_printer/src/console_view/domain/models/console_options.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/i_options_repository.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/options/options_state.dart';

class OptionsBloc extends Cubit<OptionsState> {
  final IOptionsRepository _optionsRepository;
  OptionsBloc({required IOptionsRepository optionsRepository})
    : _optionsRepository = optionsRepository,
      super(InitialOptionsState());

  Future<void> loadOptions() async {
    final options = await _optionsRepository.getCurrentOptions();
    emit(LoadedOptionsState(options));
  }

  Future<void> selectDate(DateTimeRange? dateRange) async {
    final currentState = state;
    if (currentState is LoadedOptionsState) {
      final updatedOptions = currentState.options.copyWith(
        selectedDate: dateRange,
        clearSelectedDate: dateRange == null,
      );
      emit(LoadedOptionsState(updatedOptions));
    }
    await _optionsRepository.selectDate(
      dateRange?.start.millisecondsSinceEpoch ?? 0,
      dateRange?.end.millisecondsSinceEpoch ?? 0,
    );
  }

  Future<void> selectOption(OptionItem option) async {
    final currentState = state;
    if (currentState is LoadedOptionsState) {
      final updatedOptions = currentState.options.copyWith(option: option);
      emit(LoadedOptionsState(updatedOptions));
    }
    await _optionsRepository.selectOption(option);
  }

  Future<void> selectTimeRange(DateTimeRange? timeRange) async {
    final currentState = state;
    if (currentState is LoadedOptionsState) {
      final updatedOptions = currentState.options.copyWith(
        selectedTimeRange: timeRange,
        clearSelectedTimeRange: timeRange == null,
      );
      emit(LoadedOptionsState(updatedOptions));
    }
    if (timeRange != null) {
      await _optionsRepository.selectTimeRange(
        timeRange.start.millisecondsSinceEpoch,
        timeRange.end.millisecondsSinceEpoch,
      );
    }
  }
}
