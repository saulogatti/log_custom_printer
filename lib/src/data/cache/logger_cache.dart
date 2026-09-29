import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:log_custom_printer/src/data/file_utils/file_manager_type.dart';
import 'package:log_custom_printer/src/domain/i_logger_cache_repository.dart';
import 'package:log_custom_printer/src/domain/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_json_list_type.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/extensions/string_extension.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

/// Cache manager for log file persistence on disk.
///
/// {@category Utilities}
final class LoggerCache {
  /// Path to logs directory.
  String _directoryPath = 'logger';
  final IFileManagerType _fileManagerType;

  /// Tracks initialization completion.
  late Completer<void> _future;

  /// Optional callback for initialization/write errors.
  void Function(Object error, StackTrace stackTrace)? onError;

  final String _extension = '.json';

  /// Creates a cache manager.
  LoggerCache(String directory, {IFileManagerType? fileManagerType})
    : _fileManagerType = fileManagerType ?? FileManager() {
    _future = Completer<void>();
    _init(directory);
  }

  /// Completes when cache directory initialization finishes.
  Completer<void> get futureInitialization => _future;

  /// Removes all log files.
  Future<void> clearAll() async {
    try {
      await futureInitialization.future;
      await _fileManagerType.deleteDirectory(_directoryPath);
    } on Exception catch (e, stack) {
      dev.log('Failed to clear log files: $e', stackTrace: stack);
    }
  }

  /// Removes log file by [name] type.
  Future<void> clearLogByType(String name) async {
    await futureInitialization.future;
    final fileName = _getPathFile(name);
    await _fileManagerType.deleteFile(fileName);
  }

  /// Exports [logs] to a file and returns bytes + file path.
  Future<(List<int>?, String?)> exportLogs(List<LoggerObjectBase> logs, ExportFormat format) async {
    await writeLogToFile('share.json', logs);
    final pathFile = _getPathFile('share.json');
    final objEncode = jsonEncode(logs);

    return (utf8.encode(objEncode), pathFile);
  }

  /// Full file path helper for tests.
  @visibleForTesting
  String getPathFileForTest(String fileName) {
    return _getPathFile(fileName);
  }

  /// Reads all log files and groups them by type.
  Future<Map<EnumLoggerType, LoggerJsonListType?>?> readAllLogs() async {
    try {
      await futureInitialization.future;
      final directory = Directory(_directoryPath);
      if (await directory.exists()) {
        final files = await directory
            .list()
            .where((entity) => entity is File)
            .cast<File>()
            .toList();
        final allLogs = <EnumLoggerType, LoggerJsonListType?>{};
        for (final file in files) {
          if (file.path.endsWith(_extension)) {
            try {
              final data = await _fileManagerType.readFile(file.path);
              final mapJ = jsonDecode(data);
              if (mapJ is Map) {
                final loggerList = LoggerJsonListType.fromJson(Map.from(mapJ));
                final typeLog = loggerList.type;
                final haveList = allLogs[typeLog] != null;
                if (haveList) {
                  allLogs[typeLog]!.addLoggerList(loggerList.loggerEntries);
                } else {
                  allLogs[typeLog] = loggerList;
                }
              }
            } catch (e, stack) {
              dev.log('Failed to read log file: $e', stackTrace: stack);
              await file.delete(recursive: true);
            }
          }
        }
        return allLogs;
      }
    } on Exception catch (e, stack) {
      dev.log('Failed to read log files: $e', stackTrace: stack);
    }
    return null;
  }

  /// Writes [loggerList] to [fileName] as formatted JSON.
  Future<void> writeLogToFile(String fileName, Object loggerList) async {
    try {
      await futureInitialization.future;
      final path = _getPathFile(fileName);

      final objEncode = const JsonEncoder.withIndent('  ').convert(loggerList);

      await _fileManagerType.writeFile(path, objEncode);
    } on Exception catch (e, stack) {
      onError?.call(e, stack);
      dev.log('Failed to write log file: $e', stackTrace: stack);
    }
  }

  /// Builds full path for a log file, forcing `.json` extension.
  String _getPathFile(String fileName) {
    if (fileName.isEmpty) {
      throw ArgumentError('File name cannot be empty');
    }

    final baseName = path.basename(fileName);

    if (baseName == '.' || baseName == '..') {
      throw ArgumentError('Invalid file name: $baseName');
    }

    final sanitizedFileName = baseName.sanitizedFileName.formattedName;

    if (sanitizedFileName.isEmpty) {
      throw ArgumentError('File name became empty after sanitization');
    }

    final fileJson = path.setExtension(sanitizedFileName, _extension);
    final pathLog = path.join(_directoryPath, fileJson);

    return pathLog;
  }

  /// Initializes `loggerApp/logs` directory in the provided base path.
  Future<void> _init(String directory) async {
    assert(directory.isNotEmpty, 'Base directory for logs cannot be empty');
    if (directory.endsWith('/')) {
      throw AssertionError('Base directory for logs must not end with /');
    }
    try {
      final directoryPath = Directory('$directory/loggerApp/logs');
      if (!await directoryPath.exists()) {
        await directoryPath.create(recursive: true);
      }
      _directoryPath = directoryPath.path;
    } on Exception catch (e, stack) {
      if (onError != null) {
        onError!(e, stack);
      } else {
        dev.log('Failed to initialize LoggerCache: $e', stackTrace: stack);
      }
    } finally {
      _future.complete();
    }
  }
}
