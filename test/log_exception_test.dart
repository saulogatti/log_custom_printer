import 'package:flutter_test/flutter_test.dart';
import 'package:log_custom_printer/src/domain/log_helpers/log_exception.dart';

void main() {
  group('LogException', () {
    test('should store the message correctly', () {
      const message = 'Test error message';
      final exception = LogException(message);

      expect(exception.message, equals(message));
    });

    test('toString() should return the expected format', () {
      const message = 'Something went wrong';
      final exception = LogException(message);

      expect(exception.toString(), equals('LogException: $message'));
    });

    test('should handle empty message correctly', () {
      const message = '';
      final exception = LogException(message);

      expect(exception.message, equals(''));
      expect(exception.toString(), equals('LogException: '));
    });
  });
}
