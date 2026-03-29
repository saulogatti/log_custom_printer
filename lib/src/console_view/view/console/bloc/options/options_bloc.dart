import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_custom_printer/src/console_view/domain/models/console_options.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/i_options_repository.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/options/options_state.dart';
// TODO finalizar implementação do bloc de opções, integrando com o repositório e a UI
class OptionsBloc extends Cubit<OptionsState> {
  final IOptionsRepository _optionsRepository;
  OptionsBloc({required IOptionsRepository optionsRepository})
    : _optionsRepository = optionsRepository,
      super(InitialOptionsState());

  void clearLogs() {
    _optionsRepository.clearLogs();
  }

  void exportLogs() {
    _optionsRepository.exportLogs();
  }

  void loadOptions(ConsoleOptions options) {
    emit(UpdatedOptionsState(options));
  }

  void selectDate(DateTimeRange? dateRange) {
    if (state is UpdatedOptionsState) {
      final options = (state as UpdatedOptionsState).options;
      options.selectedDate = dateRange;
      emit(UpdatedOptionsState(options));
    }
  }

  void selectOption(OptionItem option) {
    _optionsRepository.selectOption(option);
  }

  void selectTimeRange(DateTimeRange? timeRange) {
    _optionsRepository.selectTimeRange(
      timeRange?.start.millisecondsSinceEpoch ?? 0,
      timeRange?.end.millisecondsSinceEpoch ?? 0,
    );
  }
}
