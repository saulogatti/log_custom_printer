import 'dart:io';

import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late FileManager fileManager;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('file_manager_test');
    fileManager = FileManager();
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('FileManager directories', () {
    test('createDirectory creates nested directories and reports creation', () async {
      final dirPath = path.join(tempDir.path, 'a', 'b', 'c');

      expect(await fileManager.createDirectory(dirPath), isTrue);
      expect(await Directory(dirPath).exists(), isTrue);
    });

    test('createDirectory returns false when it already exists', () async {
      expect(await fileManager.createDirectory(tempDir.path), isFalse);
    });

    test('deleteDirectory removes a directory with content', () async {
      final dirPath = path.join(tempDir.path, 'logs');
      await File(path.join(dirPath, 'file.json')).create(recursive: true);

      expect(await fileManager.deleteDirectory(dirPath), isTrue);
      expect(await Directory(dirPath).exists(), isFalse);
    });

    test('deleteDirectory returns false when it does not exist', () async {
      expect(await fileManager.deleteDirectory(path.join(tempDir.path, 'missing')), isFalse);
    });
  });

  group('FileManager files', () {
    test('writeFile creates parent directories', () async {
      final filePath = path.join(tempDir.path, 'nested', 'dir', 'log.json');

      expect(await fileManager.writeFile(filePath, '{}'), isTrue);
      expect(await File(filePath).readAsString(), equals('{}'));
    });

    test('writeFile overwrites by default', () async {
      final filePath = path.join(tempDir.path, 'log.json');

      await fileManager.writeFile(filePath, 'first content');
      await fileManager.writeFile(filePath, 'second');

      expect(await fileManager.readFile(filePath), equals('second'));
    });

    test('writeFile appends with FileMode.append', () async {
      final filePath = path.join(tempDir.path, 'log.txt');

      await fileManager.writeFile(filePath, 'a');
      await fileManager.writeFile(filePath, 'b', FileMode.append);

      expect(await fileManager.readFile(filePath), equals('ab'));
    });

    test('readFile throws for a missing file', () {
      expect(
        () => fileManager.readFile(path.join(tempDir.path, 'missing.json')),
        throwsA(isA<Exception>()),
      );
    });

    test('deleteFile removes an existing file', () async {
      final filePath = path.join(tempDir.path, 'log.json');
      await fileManager.writeFile(filePath, '{}');

      expect(await fileManager.deleteFile(filePath), isTrue);
      expect(await File(filePath).exists(), isFalse);
    });

    test('deleteFile returns false for a missing file', () async {
      expect(await fileManager.deleteFile(path.join(tempDir.path, 'missing.json')), isFalse);
    });

    test('rejects empty paths', () {
      expect(() => fileManager.readFile(''), throwsA(isA<Exception>()));
      expect(() => fileManager.writeFile('', 'x'), throwsA(isA<Exception>()));
      expect(() => fileManager.deleteFile(''), throwsA(isA<Exception>()));
    });

    test('keeps working on a path after a failed operation', () async {
      final filePath = path.join(tempDir.path, 'later.json');

      await expectLater(fileManager.readFile(filePath), throwsA(isA<Exception>()));
      await fileManager.writeFile(filePath, 'recovered');

      expect(await fileManager.readFile(filePath), equals('recovered'));
    });

    test('orders a write followed by a read on the same path', () async {
      final filePath = path.join(tempDir.path, 'ordered.json');

      final write = fileManager.writeFile(filePath, 'value');
      final read = fileManager.readFile(filePath);

      expect(await write, isTrue);
      expect(await read, equals('value'));
    });
  });
}
