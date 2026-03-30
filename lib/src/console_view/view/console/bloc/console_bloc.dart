import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/message_repository.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_event.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_state.dart';

class ConsoleBloc extends Bloc<ConsoleEvent, ConsoleState> {
  final MessageRepository _messageRepository;
  DateTimeRange? _dateTimeRange;
  bool _isDateTimeFilterEnabled = false;

  // Por compatibilidade com o comportamento atual, iniciamos com Debug.
  // A tela pode alterar via ConsoleFilterByType.
  LogType? _selectedType;

  ConsoleBloc({required MessageRepository messageRepository})
    : _messageRepository = messageRepository,
      super(const ConsoleInitial()) {
    on<ConsoleEvent>((event, emit) async {
      emit(const ConsoleLoading());
      switch (event) {
        case ConsoleClear():
          _messageRepository.clearMessages();
          await _emitFilteredLogs(emit);
          break;
        case ConsoleLoad():
          await _emitFilteredLogs(emit);
          break;
        case ConsoleFilterByType():
          _selectedType = event.type;
          await _emitFilteredLogs(emit);
          break;
        case ConsoleUpdateDateTimeFilter():
          _dateTimeRange = event.dateTimeRange;
          _isDateTimeFilterEnabled = event.isDateTimeFilterEnabled;
          await _emitFilteredLogs(emit);
      }
    });
  }

  Future<void> _emitFilteredLogs(Emitter<ConsoleState> emit) async {
    try {
      final logs = await _messageRepository.getFilterMessages(
        logType: _selectedType,
        dateTimeRange: _dateTimeRange,
        isDateTimeFilterEnabled: _isDateTimeFilterEnabled,
      );
      emit(ConsoleLoaded(logs: logs));
    } on Exception catch (e) {
      emit(ConsoleError(message: 'Erro ao carregar logs: $e'));
    }
  }
}
