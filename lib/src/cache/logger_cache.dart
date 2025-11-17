import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:log_custom_printer/src/logs_object/error_log.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class LoggerCache {
  static final LoggerCache _instance = LoggerCache._internal();
  String _directoryPath = 'logger';
  final Map<String, List<String>> _cache = {};
  late Completer<void> _future;
  factory LoggerCache() {
    return _instance;
  }

  LoggerCache._internal() {
    _future = Completer<void>();
    _init();
  }
  Future<void> get futureInit => _future.future;

  void clearLogs(String key) {
    _cache.remove(key);
  }

  Map<String, dynamic>? getLogResp(String fileName) {
    final path = getNameFile(fileName);
    final File file = File(path);
    if (file.existsSync()) {
      final data = file.readAsStringSync();
      final jj = jsonDecode(data);
      return jj as Map<String, dynamic>;
    }
    return null;
  }

  List<String>? getLogs(String key) {
    return _cache[key];
  }

  String getNameFile(String fileName) {
    final fileJson = path.setExtension(fileName, '.json');
    final pathLog = getPathLogs(fileJson);

    return pathLog;
  }

  String getPathLogs(String fileName) {
    if (_future.isCompleted) {
      return path.join(_directoryPath, fileName);
    }
    throw Exception("LoggerCache not initialized yet. Please wait for initialization.");
  }

  Future<void> _init() async {
    try {
      final directory = (await getApplicationSupportDirectory()).path;
      final Directory directoryPath = Directory('$directory/loggerApp/logs');
      if (!directoryPath.existsSync()) {
        await directoryPath.create(recursive: true);
      }
      _directoryPath = directoryPath.path;
    } on Exception catch (e, stack) {
      final error = ErrorLog(e.toString(), stack);
      error.sendLog();
    }
    _future.complete();
  }
}
