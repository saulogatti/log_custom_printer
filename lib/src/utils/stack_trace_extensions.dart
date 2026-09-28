import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';

/// Regex for browser stack trace lines.
final _browserStackTraceRegex = RegExp(r'^(?:package:)?(dart:\S+|\S+)');

/// Regex for device stack trace lines.
final _deviceStackTraceRegex = RegExp(r'#[0-9]+\s+(.+) \((\S+)\)');

/// Regex for stack trace line prefixes.
final _stackTraceLineRegex = RegExp(r'#\d+\s+');

/// Stack trace formatting and transformation extension.
///
/// {@category Utilities}
extension StackTraceSdk on StackTrace {
  /// Formats stack trace lines with optional color and max line count.
  String formatStackTrace(LoggerAnsiColor? sdkLevel, int linesCount) {
    final lines = _getCleanedLines(linesCount);
    final formatted = <String>[];

    for (var count = 0; count < lines.length; count++) {
      final line = lines[count];
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

  /// Converts stack trace to a map (`#0`, `#1`, ...).
  Map<String, dynamic> stackInMap([int linesCount = 8]) {
    final map = <String, String>{};
    final lines = _getCleanedLines(linesCount);

    for (var count = 0; count < lines.length; count++) {
      final line = lines[count];
      map['#$count'] = line;
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
        !segment.startsWith('#')) {
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

  List<String> _getCleanedLines(int linesCount) {
    final lines = _getLines();
    var stackTraceLength = lines.length;
    if (stackTraceLength > linesCount) {
      stackTraceLength = linesCount;
    }

    final cleanedLines = <String>[];
    for (var count = 0; count < stackTraceLength; count++) {
      cleanedLines.add(lines[count].replaceFirst(_stackTraceLineRegex, ''));
    }
    return cleanedLines;
  }

  List<String> _getLines() {
    return toString().split('\n').where((line) {
      return line.isNotEmpty &&
          !_discardDeviceStacktraceLine(line) &&
          !_discardBrowserStacktraceLine(line);
    }).toList();
  }
}
