import 'dart:convert';
import 'dart:io';

import 'package:log_custom_printer/src/cache/logger_cache.dart';
import 'package:test/test.dart';

void main() {
  group('LoggerCache Reproduction', () {
    late Directory tempDir;
    late LoggerCache cache;

    setUp(() async {
      tempDir = Directory('logger');
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
      tempDir.createSync();

      cache = LoggerCache(tempDir.path);
      // Wait for initialization (even if it fails and defaults to 'logger')
      await cache.futureInit;
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('getLogResp returns null when JSON is a list', () {
      final file = File('${tempDir.path}/test_list.json');
      file.writeAsStringSync(jsonEncode([1, 2, 3]));

      expect(cache.getLogResp('test_list'), isNull);
    });

    test('getLogResp returns null when JSON is a primitive', () {
      final file = File('${tempDir.path}/test_primitive.json');
      file.writeAsStringSync(jsonEncode("not a map"));

      expect(cache.getLogResp('test_primitive'), isNull);
    });

    test('getLogResp returns null when JSON is malformed', () {
      final file = File('${tempDir.path}/test_malformed.json');
      file.writeAsStringSync('{invalid}');

      expect(cache.getLogResp('test_malformed'), isNull);
    });

    test('getLogResp returns null when file does not exist', () {
      expect(cache.getLogResp('non_existent'), isNull);
    });

    test('getLogResp returns map when JSON is valid map', () {
      final file = File('${tempDir.path}/test_valid.json');
      final data = {'type': 'DebugLog', 'loggerJson': <dynamic>[]};
      file.writeAsStringSync(jsonEncode(data));

      final result = cache.getLogResp('test_valid');
      expect(result, isNotNull);
      expect(result!['type'], equals('DebugLog'));
    });
  });
}
