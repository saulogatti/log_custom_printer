import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/message_repository.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_event.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_state.dart';
import 'package:log_custom_printer/src/domain/i_logger_cache_repository.dart';

/// BLoC responsável pelo estado da tela de console de logs.
///
/// Gerencia o ciclo de vida das mensagens exibidas no [ConsoleView]:
/// carregamento, filtragem por tipo, filtragem temporal, limpeza e exportação.
///
/// Mantém internamente o [LogType] selecionado e o intervalo de data/hora
/// como fontes únicas de verdade, evitando recarregamentos desnecessários.
class ConsoleBloc extends Bloc<ConsoleEvent, ConsoleState> {
  final MessageRepository _messageRepository;
  final ILoggerCacheRepository _loggerCacheRepository;
  DateTimeRange? _dateTimeRange;
  bool _isDateTimeFilterEnabled = false;

  // Mantém fonte única de verdade para o filtro de tipo.
  LogType _selectedType = LogType.debug;

  /// Cria um [ConsoleBloc] com os repositórios necessários.
  ConsoleBloc({
    required MessageRepository messageRepository,
    required ILoggerCacheRepository loggerCacheRepository,
  }) : _messageRepository = messageRepository,
       _loggerCacheRepository = loggerCacheRepository,
       super(const ConsoleInitial(selectedLogType: LogType.debug)) {
    on<ConsoleEvent>((event, emit) async {
      switch (event) {
        case ConsoleClear():
          emit(ConsoleLoading(selectedLogType: _selectedType));
          _messageRepository.clearMessages();
          await _emitFilteredLogs(emit);
          break;
        case ConsoleLoad():
          emit(ConsoleLoading(selectedLogType: _selectedType));
          await _emitFilteredLogs(emit);
          break;
        case ConsoleFilterByType():
          if (_selectedType == event.type) {
            return;
          }
          _selectedType = event.type;
          emit(ConsoleLoading(selectedLogType: _selectedType));
          await _emitFilteredLogs(emit);
          break;
        case ConsoleUpdateDateTimeFilter():
          final hasDateFilterChanged = _dateTimeRange != event.dateTimeRange;
          final hasEnabledChanged =
              _isDateTimeFilterEnabled != event.isDateTimeFilterEnabled;

          if (!hasDateFilterChanged && !hasEnabledChanged) {
            return;
          }

          _dateTimeRange = event.dateTimeRange;
          _isDateTimeFilterEnabled = event.isDateTimeFilterEnabled;
          emit(ConsoleLoading(selectedLogType: _selectedType));
          await _emitFilteredLogs(emit);
        case ConsoleExportLogs():
          final logs = event.logType == LogType.all
              ? await _loggerCacheRepository.getAllLogs()
              : await _loggerCacheRepository.getLogsByType(event.logType.toEnum());

          await _loggerCacheRepository.exportLogs(logs, event.format);
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
      emit(ConsoleLoaded(logs: logs, selectedLogType: _selectedType));
    } on Exception catch (e) {
      emit(
        ConsoleError(
          message: 'Erro ao carregar logs: $e',
          selectedLogType: _selectedType,
        ),
      );
    }
  }
}
