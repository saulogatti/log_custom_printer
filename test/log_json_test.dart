import 'dart:convert';

import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:test/test.dart';

void main() {
  group('Teste de serialização e desserialização dos objetos', () {
    test('teste DebugLog', () {
      final log = DebugLog('Teste de log');
      final jsonString = jsonEncode(log);
      expect(jsonString, isA<String>());
      expect(jsonString.length, greaterThan(0));
      final json = jsonDecode(jsonString);
      expect(json, isA<Map<String, dynamic>>());
      final debugLog = DebugLog.fromJson(json);
      expect(debugLog.message, 'Teste de log');
    });
    test('WarningLog', () {
      final log = WarningLog('Teste de log');
      final jsonString = jsonEncode(log);
      expect(jsonString, isA<String>());
      expect(jsonString.length, greaterThan(0));
      final json = jsonDecode(jsonString);
      expect(json, isA<Map<String, dynamic>>());
      final warningLog = WarningLog.fromJson(json);
      expect(warningLog.message, 'Teste de log');
    });
    test('ErrorLog', () {
      final log = ErrorLog('Teste de log', StackTrace.current, object: Exception('Teste de erro'));
      final map = log.toJson();
      final jsonString = jsonEncode(map);
      expect(jsonString, isA<String>());
      expect(jsonString.length, greaterThan(0));
      final json = jsonDecode(jsonString);
      expect(json, isA<Map<String, dynamic>>());
      final errorLog = ErrorLog.fromJson(json);
      expect(errorLog.message, 'Teste de log');
      expect(errorLog.stackTrace, isA<StackTrace>());
      expect(errorLog.object, isA<String>());
    });
    test('InfoLog', () {
      final log = InfoLog('Teste de log');
      final jsonString = jsonEncode(log);
      expect(jsonString, isA<String>());
      expect(jsonString.length, greaterThan(0));
      final json = jsonDecode(jsonString);
      expect(json, isA<Map<String, dynamic>>());
      final infoLog = InfoLog.fromJson(json);
      expect(infoLog.message, 'Teste de log');
    });
  });
}
