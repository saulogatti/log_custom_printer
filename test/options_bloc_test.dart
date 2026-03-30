import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/console_view/domain/models/console_options.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/i_options_repository.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/options/options_bloc.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/options/options_state.dart';
import 'package:test/test.dart';

class MockOptionsRepository implements IOptionsRepository {
  int getCurrentOptionsCalls = 0;
  ConsoleOptions currentOptions = ConsoleOptions.empty();

  @override
  Future<ConsoleOptions> getCurrentOptions() async {
    getCurrentOptionsCalls++;
    return currentOptions;
  }

  @override
  Future<void> selectDate(int? start, int? end) async {
    if (start == -1) throw Exception("Error");
  }

  @override
  Future<void> selectOption(OptionItem option) async {
    if (option.title == "Error") throw Exception("Error");
    currentOptions = currentOptions.copyWith(option: option);
  }

  @override
  Future<void> selectTimeRange(int? start, int? end) async {
    if (start == -1) throw Exception("Error");
  }
}

void main() {
  late OptionsBloc optionsBloc;
  late MockOptionsRepository mockOptionsRepository;

  setUp(() {
    mockOptionsRepository = MockOptionsRepository();
    optionsBloc = OptionsBloc(optionsRepository: mockOptionsRepository);
  });

  test('Initial state is InitialOptionsState', () {
    expect(optionsBloc.state, isA<InitialOptionsState>());
  });

  test('loadOptions emits LoadedOptionsState and calls repository', () async {
    await optionsBloc.loadOptions();
    expect(optionsBloc.state, isA<LoadedOptionsState>());
    expect(mockOptionsRepository.getCurrentOptionsCalls, 1);
  });

  test('selectOption updates state locally and does not call loadOptions', () async {
    // Initial load
    await optionsBloc.loadOptions();
    expect(mockOptionsRepository.getCurrentOptionsCalls, 1);

    final newOption = OptionItem(title: 'New Title', description: 'New Desc');
    await optionsBloc.selectOption(newOption);

    expect(optionsBloc.state, isA<LoadedOptionsState>());
    final state = optionsBloc.state as LoadedOptionsState;
    expect(state.options.option.title, 'New Title');

    // Should NOT have called getCurrentOptions again
    expect(mockOptionsRepository.getCurrentOptionsCalls, 1);
  });

  test('selectDate updates state locally and does not call loadOptions', () async {
    await optionsBloc.loadOptions();
    expect(mockOptionsRepository.getCurrentOptionsCalls, 1);

    final newDateRange = DateTimeRange(
      start: DateTime(2023, 1, 1),
      end: DateTime(2023, 1, 2),
    );
    await optionsBloc.selectDate(newDateRange);

    expect(optionsBloc.state, isA<LoadedOptionsState>());
    final state = optionsBloc.state as LoadedOptionsState;
    expect(state.options.selectedDate, newDateRange);

    expect(mockOptionsRepository.getCurrentOptionsCalls, 1);
  });

  test('selectTimeRange updates state locally and does not call loadOptions', () async {
    await optionsBloc.loadOptions();
    expect(mockOptionsRepository.getCurrentOptionsCalls, 1);

    final newTimeRange = DateTimeRange(
      start: DateTime(2023, 1, 1, 10, 0),
      end: DateTime(2023, 1, 1, 11, 0),
    );
    await optionsBloc.selectTimeRange(newTimeRange);

    expect(optionsBloc.state, isA<LoadedOptionsState>());
    final state = optionsBloc.state as LoadedOptionsState;
    expect(state.options.selectedTimeRange, newTimeRange);

    expect(mockOptionsRepository.getCurrentOptionsCalls, 1);
  });

  test('selectDate(null) clears selectedDate in state', () async {
    await optionsBloc.loadOptions();

    // Set a date first
    final someDate = DateTimeRange(start: DateTime(2023), end: DateTime(2023, 1, 2));
    await optionsBloc.selectDate(someDate);
    expect((optionsBloc.state as LoadedOptionsState).options.selectedDate, someDate);

    // Clear it
    await optionsBloc.selectDate(null);
    expect((optionsBloc.state as LoadedOptionsState).options.selectedDate, isNull);
  });

  test('selectTimeRange(null) clears selectedTimeRange in state', () async {
    await optionsBloc.loadOptions();

    // Set a time range first
    final someTime = DateTimeRange(start: DateTime(2023, 1, 1, 10), end: DateTime(2023, 1, 1, 11));
    await optionsBloc.selectTimeRange(someTime);
    expect((optionsBloc.state as LoadedOptionsState).options.selectedTimeRange, someTime);

    // Clear it
    await optionsBloc.selectTimeRange(null);
    expect((optionsBloc.state as LoadedOptionsState).options.selectedTimeRange, isNull);
  });

  test('selectOption rolls back state on error', () async {
    await optionsBloc.loadOptions();
    final initialState = optionsBloc.state as LoadedOptionsState;
    final initialOption = initialState.options.option;

    final errorOption = OptionItem(title: 'Error', description: 'Desc');
    await optionsBloc.selectOption(errorOption);

    final finalState = optionsBloc.state as LoadedOptionsState;
    expect(finalState.options.option, initialOption);
  });

  test('selectDate rolls back state on error', () async {
    await optionsBloc.loadOptions();
    final initialState = optionsBloc.state as LoadedOptionsState;
    final initialDate = initialState.options.selectedDate;

    final errorDateRange = DateTimeRange(
      start: DateTime.fromMillisecondsSinceEpoch(-1),
      end: DateTime(2023, 1, 2),
    );
    await optionsBloc.selectDate(errorDateRange);

    final finalState = optionsBloc.state as LoadedOptionsState;
    expect(finalState.options.selectedDate, initialDate);
  });
}
