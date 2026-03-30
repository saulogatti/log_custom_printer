import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:log_custom_printer/src/data/file_utils/file_manager_type.dart';

void main() {
  group('FileManager concurrency safety', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'file_manager_concurrency_test',
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'serializes concurrent writes on the same log file without losing entries',
      () async {
        final fileManager = FileManager(fileType: FileType.log);
        final filePath = '${tempDir.path}${Platform.pathSeparator}events.log';

        final writes = List.generate(
          200,
          (index) => fileManager.writeFile(filePath, 'entry-$index\n'),
        );

        await Future.wait(writes);

        final content = await fileManager.readFile(filePath);
        final lines = content
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .toList();

        expect(lines.length, equals(200));
        expect(lines.toSet().length, equals(200));
        for (var i = 0; i < 200; i++) {
          expect(lines.contains('entry-$i'), isTrue);
        }
      },
    );
  });
}
