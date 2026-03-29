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
    await _optionsRepository.selectDate(
      dateRange?.start.millisecondsSinceEpoch ?? 0,
      dateRange?.end.millisecondsSinceEpoch ?? 0,
    );
    loadOptions();
  }

  Future<void> selectOption(OptionItem option) async {
    await _optionsRepository.selectOption(option);
    loadOptions();
  }

  Future<void> selectTimeRange(DateTimeRange? timeRange) async {
    await _optionsRepository.selectTimeRange(
      timeRange?.start.millisecondsSinceEpoch ?? 0,
      timeRange?.end.millisecondsSinceEpoch ?? 0,
    );
    loadOptions();
  }
}
