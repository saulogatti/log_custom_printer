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

  /// Atualiza o intervalo unificado de data/hora.
  ///
  /// Quando [dateTimeRange] é válido, o filtro temporal é habilitado
  /// automaticamente.
  Future<void> selectDateTimeRange(DateTimeRange? dateTimeRange) async {
    if (dateTimeRange != null && !_isValidDateTimeRange(dateTimeRange)) {
      return;
    }

    await _optionsRepository.selectDateTimeRange(
      dateTimeRange?.start.millisecondsSinceEpoch ?? 0,
      dateTimeRange?.end.millisecondsSinceEpoch ?? 0,
    );

    if (dateTimeRange != null) {
      await _optionsRepository.setDateTimeFilterEnabled(true);
    }

    await loadOptions();
  }

  Future<void> setDateTimeFilterEnabled(bool enabled) async {
    await _optionsRepository.setDateTimeFilterEnabled(enabled);
    await loadOptions();
  }

  Future<void> selectOption(OptionItem option) async {
    await _optionsRepository.selectOption(option);
    await loadOptions();
  }

  bool _isValidDateTimeRange(DateTimeRange range) {
    return range.end.difference(range.start).inMilliseconds > 0;
  }
}
