import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:test/test.dart';

void main() {
  group("Teste de toJson dos objetos", () {
    test("teste DebugLog", () {
      final log = DebugLog("Teste de log");
      final json = log.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json['message'], "Teste de log");
    });
    test("WarningLog", () {
      final log = WarningLog("Teste de log");
      final json = log.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json['message'], "Teste de log");
    });
    test("ErrorLog", () {
      final log = ErrorLog("Teste de log", StackTrace.current);
      final json = log.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json['message'], "Teste de log");
      expect(json['stackTrace'], isA<String>());
    });
    test("InfoLog", () {
      final log = InfoLog("Teste de log");
      final json = log.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json['message'], "Teste de log");
    });
  });
}
