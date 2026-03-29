import 'dart:async';
import 'dart:convert';

import 'package:log_custom_printer/src/console_view/data/entry/options_entry.dart';
import 'package:log_custom_printer/src/console_view/domain/models/console_options.dart';
import 'package:log_custom_printer/src/data/file_utils/file_manager_type.dart';
import 'package:path_provider/path_provider.dart';

class OptionsConsoleDataSource {
  final String _fileName = 'console_options.json';
  final IFileManagerType _fileManagerType = FileManager(
    fileType: FileType.json,
  );
  final Completer<void> _completer = Completer<void>();

  String _pathFile = '';
  OptionsConsoleDataSource() {
    _completer.complete(_init());
  }
  Future<void> get initialized => _completer.future;
  Future<OptionsEntry> getCurrentOptions() async {
    await initialized;
    try {
      final file = await _fileManagerType.readFile(_pathFile);
      final jsonDec = jsonDecode(file);
      if (jsonDec is Map) {
        final jsonMap = Map<String, dynamic>.from(jsonDec);
        return OptionsEntry.fromJson(jsonMap);
      }
    } on Exception catch (e) {
      print("Error reading options: $e");
    }
    return OptionsEntry.fromConsoleOptions(ConsoleOptions.empty());
  }

  void saveOptions(OptionsEntry data) {
    final jsonString = jsonEncode(data.toJson());
    _fileManagerType.writeFile(_pathFile, jsonString);
  }

  Future<void> _init() async {
    final directory = await getApplicationSupportDirectory();

    await _fileManagerType.createDirectory(directory.path);

    _pathFile = '${directory.path}/$_fileName';
  }
}
