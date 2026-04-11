import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/message_repository.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_bloc.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_event.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_state.dart';
import 'package:log_custom_printer/src/domain/i_logger_cache_repository.dart';
import 'package:log_custom_printer/src/domain/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';

void main() {
  late FakeMessageRepository messageRepository;
  late FakeLoggerCacheRepository loggerCacheRepository;
  late ConsoleBloc consoleBloc;

  setUp(() {
    messageRepository = FakeMessageRepository();
    loggerCacheRepository = FakeLoggerCacheRepository();
    consoleBloc = ConsoleBloc(
      messageRepository: messageRepository,
      loggerCacheRepository: loggerCacheRepository,
    );
  });

  tearDown(() async {
    await consoleBloc.close();
  });

  test('estado inicial usa LogType.debug', () {
    expect(consoleBloc.state, isA<ConsoleInitial>());
    expect(consoleBloc.state.selectedLogType, LogType.debug);
  });

  test('ConsoleLoad carrega logs com tipo selecionado atual', () async {
    consoleBloc.add(const ConsoleLoad());

    final loadedState = await consoleBloc.stream.firstWhere(
      (state) => state is ConsoleLoaded,
    );

    expect(loadedState, isA<ConsoleLoaded>());
    expect(consoleBloc.state.selectedLogType, LogType.debug);
    expect(messageRepository.filterCalls, 1);
    expect(messageRepository.lastLogType, LogType.debug);
  });

  test('ConsoleFilterByType com mesmo tipo nao refaz consulta', () async {
    consoleBloc.add(const ConsoleLoad());
    await consoleBloc.stream.firstWhere((state) => state is ConsoleLoaded);

    final callsBefore = messageRepository.filterCalls;
    consoleBloc.add(const ConsoleFilterByType(LogType.debug));
    await Future<void>.delayed(Duration.zero);

    expect(messageRepository.filterCalls, callsBefore);
    expect(consoleBloc.state.selectedLogType, LogType.debug);
  });

  test(
    'ConsoleFilterByType com tipo novo atualiza estado e consulta',
    () async {
      consoleBloc.add(const ConsoleFilterByType(LogType.error));

      final loadedState = await consoleBloc.stream.firstWhere(
        (state) => state is ConsoleLoaded,
      );

      expect(loadedState, isA<ConsoleLoaded>());
      expect(consoleBloc.state.selectedLogType, LogType.error);
      expect(messageRepository.filterCalls, 1);
      expect(messageRepository.lastLogType, LogType.error);
    },
  );

  test(
    'ConsoleUpdateDateTimeFilter com mesmos dados nao refaz consulta',
    () async {
      consoleBloc.add(const ConsoleLoad());
      await consoleBloc.stream.firstWhere((state) => state is ConsoleLoaded);

      final callsBefore = messageRepository.filterCalls;
      final range = DateTimeRange(
        start: DateTime(2025, 1, 1),
        end: DateTime(2025, 1, 2),
      );

      consoleBloc.add(
        ConsoleUpdateDateTimeFilter(
          dateTimeRange: range,
          isDateTimeFilterEnabled: true,
        ),
      );
      await consoleBloc.stream.firstWhere((state) => state is ConsoleLoaded);

      final callsAfterChange = messageRepository.filterCalls;

      consoleBloc.add(
        ConsoleUpdateDateTimeFilter(
          dateTimeRange: range,
          isDateTimeFilterEnabled: true,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(callsAfterChange, callsBefore + 1);
      expect(messageRepository.filterCalls, callsAfterChange);
    },
  );

  group('ConsoleExportLogs', () {
    test(
      'ConsoleExportLogs com LogType.all chama getAllLogs e exportLogs',
      () async {
        consoleBloc.add(
          const ConsoleExportLogs(logType: LogType.all, format: ExportFormat.json),
        );

        // Aguarda o processamento do evento (ConsoleExportLogs não altera estado, então usamos um delay curto)
        await Future<void>.delayed(Duration.zero);

        expect(loggerCacheRepository.getAllLogsCalls, 1);
        expect(loggerCacheRepository.getLogsByTypeCalls, 0);
        expect(loggerCacheRepository.exportLogsCalls, 1);
        expect(loggerCacheRepository.lastExportFormat, ExportFormat.json);
      },
    );

    test(
      'ConsoleExportLogs com tipo específico chama getLogsByType e exportLogs',
      () async {
        consoleBloc.add(
          const ConsoleExportLogs(
            logType: LogType.error,
            format: ExportFormat.txt,
          ),
        );

        await Future<void>.delayed(Duration.zero);

        expect(loggerCacheRepository.getAllLogsCalls, 0);
        expect(loggerCacheRepository.getLogsByTypeCalls, 1);
        expect(loggerCacheRepository.lastTypeRequested, EnumLoggerType.error);
        expect(loggerCacheRepository.exportLogsCalls, 1);
        expect(loggerCacheRepository.lastExportFormat, ExportFormat.txt);
      },
    );
  });
}

class FakeMessageRepository implements MessageRepository {
  int filterCalls = 0;
  int clearCalls = 0;
  LogType? lastLogType;
  DateTimeRange? lastDateTimeRange;
  bool lastIsDateTimeFilterEnabled = false;

  @override
  void clearMessages() {
    clearCalls++;
  }

  @override
  Future<List<MessageLog>> getFilterMessages({
    LogType? logType,
    String? searchText,
    DateTimeRange? dateTimeRange,
    bool isDateTimeFilterEnabled = false,
  }) async {
    filterCalls++;
    lastLogType = logType;
    lastDateTimeRange = dateTimeRange;
    lastIsDateTimeFilterEnabled = isDateTimeFilterEnabled;

    return [
      MessageLog(
        title: 'title',
        message: 'message',
        timestamp: DateTime(2025, 1, 1),
        type: logType ?? LogType.debug,
      ),
    ];
  }

  @override
  Future<List<MessageLog>> getMessages() async => [];
}

class FakeLoggerCacheRepository implements ILoggerCacheRepository {
  int getAllLogsCalls = 0;
  int getLogsByTypeCalls = 0;
  int exportLogsCalls = 0;
  EnumLoggerType? lastTypeRequested;
  List<LoggerObjectBase>? lastExportedLogs;
  ExportFormat? lastExportFormat;

  @override
  Future<void> addLog(LoggerObjectBase log) async {}

  @override
  Future<void> clearLogs() async {}

  @override
  Future<void> clearLogsByType(EnumLoggerType type) async {}

  @override
  Future<void> exportLogs(List<LoggerObjectBase> logs, ExportFormat format) async {
    exportLogsCalls++;
    lastExportedLogs = logs;
    lastExportFormat = format;
  }

  @override
  Future<List<LoggerObjectBase>> getAllLogs() async {
    getAllLogsCalls++;
    return [];
  }

  @override
  Future<List<LoggerObjectBase>> getLogsByType(EnumLoggerType type) async {
    getLogsByTypeCalls++;
    lastTypeRequested = type;
    return [];
  }

  @override
  Future<void> importLogs(String content, ExportFormat format) async {}
}
