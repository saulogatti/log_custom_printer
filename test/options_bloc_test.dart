import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_custom_printer/src/console_view/domain/models/console_options.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/i_options_repository.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/options/options_bloc.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/options/options_state.dart';

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

  test('selectOption updates state and reloads options', () async {
    await optionsBloc.loadOptions();
    expect(mockOptionsRepository.getCurrentOptionsCalls, 1);

    final newOption = OptionItem(title: 'New Title', description: 'New Desc');
    await optionsBloc.selectOption(newOption);

    expect(optionsBloc.state, isA<LoadedOptionsState>());
    final state = optionsBloc.state as LoadedOptionsState;
    expect(state.options.option.title, 'New Title');

    expect(mockOptionsRepository.getCurrentOptionsCalls, 2);
  });

  test(
    'selectDateTimeRange updates state and enables date time filter',
    () async {
      await optionsBloc.loadOptions();
      expect(mockOptionsRepository.getCurrentOptionsCalls, 1);

      final newDateRange = DateTimeRange(
        start: DateTime(2023, 1, 1),
        end: DateTime(2023, 1, 2),
      );
      await optionsBloc.selectDateTimeRange(newDateRange);

      expect(optionsBloc.state, isA<LoadedOptionsState>());
      final state = optionsBloc.state as LoadedOptionsState;
      expect(state.options.selectedDateTimeRange, newDateRange);
      expect(state.options.isDateTimeFilterEnabled, isTrue);

      expect(mockOptionsRepository.getCurrentOptionsCalls, 2);
      expect(mockOptionsRepository.setDateTimeFilterEnabledCalls, 1);
    },
  );

  test(
    'selectDateTimeRange(null) clears selectedDateTimeRange in state',
    () async {
      await optionsBloc.loadOptions();

      final someDate = DateTimeRange(
        start: DateTime(2023),
        end: DateTime(2023, 1, 2),
      );
      await optionsBloc.selectDateTimeRange(someDate);
      expect(
        (optionsBloc.state as LoadedOptionsState).options.selectedDateTimeRange,
        someDate,
      );

      await optionsBloc.selectDateTimeRange(null);
      expect(
        (optionsBloc.state as LoadedOptionsState).options.selectedDateTimeRange,
        isNull,
      );
    },
  );

  test(
    'selectDateTimeRange with invalid range does not change state',
    () async {
      await optionsBloc.loadOptions();
      final stateBefore = optionsBloc.state as LoadedOptionsState;
      final beforeRange = stateBefore.options.selectedDateTimeRange;
      final callsBefore = mockOptionsRepository.getCurrentOptionsCalls;

      final invalidRange = DateTimeRange(
        start: DateTime(2023, 1, 1, 11),
        end: DateTime(2023, 1, 1, 11),
      );
      await optionsBloc.selectDateTimeRange(invalidRange);

      final stateAfter = optionsBloc.state as LoadedOptionsState;
      expect(stateAfter.options.selectedDateTimeRange, beforeRange);
      expect(mockOptionsRepository.getCurrentOptionsCalls, callsBefore);
    },
  );

  test('selectOption propagates error and keeps previous state', () async {
    await optionsBloc.loadOptions();
    final initialState = optionsBloc.state as LoadedOptionsState;
    final initialOption = initialState.options.option;

    final errorOption = OptionItem(title: 'Error', description: 'Desc');
    await expectLater(
      optionsBloc.selectOption(errorOption),
      throwsA(isA<Exception>()),
    );

    final finalState = optionsBloc.state as LoadedOptionsState;
    expect(finalState.options.option, initialOption);
  });

  test(
    'selectDateTimeRange propagates error and keeps previous state',
    () async {
      await optionsBloc.loadOptions();
      final initialState = optionsBloc.state as LoadedOptionsState;
      final initialDate = initialState.options.selectedDateTimeRange;

      final errorDateRange = DateTimeRange(
        start: DateTime.fromMillisecondsSinceEpoch(-1),
        end: DateTime(2023, 1, 2),
      );
      await expectLater(
        optionsBloc.selectDateTimeRange(errorDateRange),
        throwsA(isA<Exception>()),
      );

      final finalState = optionsBloc.state as LoadedOptionsState;
      expect(finalState.options.selectedDateTimeRange, initialDate);
    },
  );
}

class MockOptionsRepository implements IOptionsRepository {
  int getCurrentOptionsCalls = 0;
  int setDateTimeFilterEnabledCalls = 0;
  ConsoleOptions currentOptions = ConsoleOptions.empty();

  @override
  Future<ConsoleOptions> getCurrentOptions() async {
    getCurrentOptionsCalls++;
    return currentOptions;
  }

  @override
  Future<void> selectDateTimeRange(int start, int end) {
    if (start == -1) throw Exception('Error');
    if (start <= 0 || end <= 0) {
      currentOptions.selectedDateTimeRange = null;
      return Future.value();
    }

    currentOptions = currentOptions.copyWith(
      selectedDateTimeRange: DateTimeRange(
        start: DateTime.fromMillisecondsSinceEpoch(start),
        end: DateTime.fromMillisecondsSinceEpoch(end),
      ),
    );
    return Future.value();
  }

  @override
  Future<void> selectOption(OptionItem option) async {
    if (option.title == 'Error') throw Exception('Error');
    currentOptions = currentOptions.copyWith(option: option);
  }

  @override
  Future<void> setDateTimeFilterEnabled(bool enabled) {
    setDateTimeFilterEnabledCalls++;
    currentOptions = currentOptions.copyWith(isDateTimeFilterEnabled: enabled);
    return Future.value();
  }
}
