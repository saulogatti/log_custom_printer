import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:test/test.dart';

void main() {
  group('ConfigLog', () {
    test('default constructor should have expected default values', () {
      const config = ConfigLog();

      expect(config.enableLog, isFalse);
      expect(config.onlyClasses, containsAll([DebugLog, WarningLog, InfoLog]));
      expect(config.onlyClasses.length, equals(3));
    });

    test('should correctly set enableLog when provided', () {
      const config = ConfigLog(enableLog: true);

      expect(config.enableLog, isTrue);
    });

    test('should correctly set onlyClasses when provided', () {
      const config = ConfigLog(
        onlyClasses: {ErrorLog, WarningLog},
      );

      expect(config.onlyClasses, containsAll([ErrorLog, WarningLog]));
      expect(config.onlyClasses.length, equals(2));
      expect(config.onlyClasses, isNot(contains(DebugLog)));
    });

    test('should allow empty onlyClasses (though ErrorLog is usually handled separately)', () {
      const config = ConfigLog(
        enableLog: true,
        onlyClasses: {},
      );

      expect(config.onlyClasses, isEmpty);
    });
  });
}
