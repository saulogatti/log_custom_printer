// ignore_for_file: avoid_print

import 'package:log_custom_printer/src/utils/stack_trace_extensions.dart';
import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';

void main() {
  const stackTraceString = '''
#0   MyClass.method (package:my_app/src/file.dart:10:3)
#1   MyClass.otherMethod (package:my_app/src/file.dart:20:5)
#2   MyClass.anotherMethod (package:my_app/src/file.dart:30:7)
#3   MyClass.yetAnotherMethod (package:my_app/src/file.dart:40:9)
#4   MyClass.oneMoreMethod (package:my_app/src/file.dart:50:11)
#5   MyClass.evenMoreMethod (package:my_app/src/file.dart:60:13)
#6   MyClass.lastMethod (package:my_app/src/file.dart:70:15)
#7   main (package:my_app/main.dart:5:1)
''';
  final stackTrace = StackTrace.fromString(stackTraceString);
  final ansiColor = const LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.red);

  const iterations = 1000;

  // Warm up
  for (var i = 0; i < 50; i++) {
    stackTrace.stackInMap(8);
    stackTrace.formatStackTrace(ansiColor, 8);
  }

  final stopwatch = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    stackTrace.stackInMap(8);
  }
  stopwatch.stop();
  print('stackInMap: ${stopwatch.elapsedMicroseconds / iterations} us per iteration');

  stopwatch.reset();
  stopwatch.start();
  for (var i = 0; i < iterations; i++) {
    stackTrace.formatStackTrace(ansiColor, 8);
  }
  stopwatch.stop();
  print('formatStackTrace: ${stopwatch.elapsedMicroseconds / iterations} us per iteration');
}
