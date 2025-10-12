// import 'package:stack_trace/stack_trace.dart';

import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';

final _browserStackTraceRegex = RegExp(r'^(?:package:)?(dart:\S+|\S+)');
final _deviceStackTraceRegex = RegExp(r'#[0-9]+\s+(.+) \((\S+)\)');

extension StackTraceSdk on StackTrace {
  String formatStackTrace(LoggerAnsiColor? sdkLevel, int linesCount) {
    final List<String> lines = toString()
        .split('\n')
        .where(
          (line) =>
              !_discardDeviceStacktraceLine(line) &&
              line.isNotEmpty &&
              !_discardBrowserStacktraceLine(line),
        )
        .toList();
    final List<String> formatted = [];

    int stackTraceLength = lines.length;
    if (stackTraceLength > linesCount) {
      stackTraceLength = linesCount;
    }

    for (int count = 0; count < stackTraceLength; count++) {
      final line = lines[count].replaceFirst(RegExp(r'#\d+\s+'), '');
      if (sdkLevel != null) {
        formatted.add(sdkLevel.call('#$count $line'));
      } else {
        formatted.add('#$count $line');
      }
    }

    if (formatted.isEmpty) {
      return toString();
    } else {
      return formatted.join(' \n ');
    }
  }

  Map<String, dynamic> stackInMap([int linesCount = 8]) {
    final Map<String, String> map = {};
    final List<String> lines = _getLines();
    final List<String> formatted = [];

    int stackTraceLength = lines.length;
    if (stackTraceLength > linesCount) {
      stackTraceLength = linesCount;
    }

    for (int count = 0; count < stackTraceLength; count++) {
      final line = lines[count].replaceFirst(RegExp(r'#\d+\s+'), '');
      map['#$count'] = line;
      formatted.add('#$count $line');
    }
    return map;
  }

  bool _discardBrowserStacktraceLine(String line) {
    final match = _browserStackTraceRegex.matchAsPrefix(line);
    if (match == null) {
      return false;
    }
    final segment = match.group(1)!;
    if (segment.startsWith('package:logger') ||
        segment.startsWith('dart:') ||
        !segment.startsWith("#")) {
      return true;
    }
    return false;
  }

  bool _discardDeviceStacktraceLine(String line) {
    final match = _deviceStackTraceRegex.matchAsPrefix(line);
    if (match == null) {
      return false;
    }
    final segment = match.group(2)!;
    if (segment.startsWith('package:logger') ||
        segment.startsWith('package:flutter') ||
        segment.startsWith('dart:')) {
      return true;
    }

    return false;
  }

  List<String> _getLines() {
    return toString().split('\n').where((line) {
      return line.isNotEmpty &&
          !_discardDeviceStacktraceLine(line) &&
          !_discardBrowserStacktraceLine(line);
    }).toList();
  }
}
