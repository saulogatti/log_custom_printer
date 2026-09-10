import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// File manager implementation.
///
/// Provides create/read/write/delete operations for files and directories.
/// Operations are serialized per path to avoid race conditions.
///
/// {@category Utilities}
class FileManager implements IFileManagerType {
  /// Path-based lock chain for concurrent operations.
  final Map<String, Future<void>> _pathLocks = {};

  /// Creates a file manager.
  FileManager();

  @override
  Future<bool> createDirectory(String path) {
    return _runWithPathLock(path, () async {
      final directory = Directory(path);
      if (await directory.exists()) {
        return false;
      }
      await directory.create(recursive: true);
      return true;
    });
  }

  /// Deletes directory at [path] if it exists.
  @override
  Future<bool> deleteDirectory(String path) {
    return _runWithPathLock(path, () async {
      final directory = Directory(path);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        return true;
      }
      return false;
    });
  }

  /// Deletes file at [path] if it exists.
  @override
  Future<bool> deleteFile(String path) {
    return _runWithPathLock(path, () async {
      _extensionIncludePath(path);
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    });
  }

  /// Reads and returns file content from [path].
  @override
  Future<String> readFile(String path) {
    return _runWithPathLock(path, () async {
      _extensionIncludePath(path);
      final file = File(path);
      if (await file.exists()) {
        final res = await file.readAsString(encoding: utf8);
        return res;
      }
      throw Exception('File not found: $path');
    });
  }

  /// Writes [content] to file at [path].
  @override
  Future<bool> writeFile(String path, String content, [FileMode mode = FileMode.write]) {
    return _runWithPathLock(path, () async {
      _extensionIncludePath(path);
      final file = File(path);
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      await file.writeAsBytes(utf8.encode(content), mode: mode);
      return true;
    });
  }

  /// Validates [path].
  void _extensionIncludePath(String path) {
    if (path.isEmpty) {
      throw Exception('Invalid  path: Path cannot be empty');
    }
  }

  /// Runs [operation] serialized for [path].
  Future<T> _runWithPathLock<T>(String path, Future<T> Function() operation) async {
    final key = path.trim();
    final previous = _pathLocks[key] ?? Future<void>.value();
    final completer = Completer<void>();
    final current = previous.then((_) => completer.future);
    _pathLocks[key] = current;

    await previous;
    try {
      return await operation();
    } finally {
      if (!completer.isCompleted) {
        completer.complete();
      }
      if (identical(_pathLocks[key], current)) {
        _pathLocks.remove(key);
      }
    }
  }
}

/// Supported file types.
///
/// {@category Utilities}
enum FileType {
  /// Plain text file (`.txt`).
  txt,

  /// JSON file (`.json`).
  json,

  /// Log file (`.log`).
  log,
}

/// Contract for file read/write/delete operations.
///
/// {@category Utilities}
abstract interface class IFileManagerType {
  /// Creates directory at [path] if it does not exist.
  Future<bool> createDirectory(String path);

  /// Deletes directory at [path] if it exists.
  Future<bool> deleteDirectory(String path);

  /// Deletes file at [path].
  Future<bool> deleteFile(String path);

  /// Reads and returns file content from [path].
  Future<String> readFile(String path);

  /// Writes [content] to file at [path].
  Future<bool> writeFile(String path, String content, [FileMode mode = FileMode.write]);
}
