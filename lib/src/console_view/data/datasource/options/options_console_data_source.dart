import 'dart:async';
import 'dart:convert';

import 'package:flutter/rendering.dart' show debugPrint;
import 'package:log_custom_printer/src/console_view/data/entry/options_entry.dart';
import 'package:log_custom_printer/src/console_view/domain/models/console_options.dart';
import 'package:log_custom_printer/src/data/file_utils/file_manager_type.dart';
import 'package:path_provider/path_provider.dart';

/// Fonte de dados para persistência local das opções de configuração do console.
///
/// Armazena e recupera as preferências do [ConsoleView] (opção selecionada
/// e filtro temporal) em um arquivo JSON no diretório de suporte da aplicação
/// (`getApplicationSupportDirectory()`).
///
/// A inicialização é assíncrona: aguarde [initialized] antes de usar
/// [getCurrentOptions] ou [saveOptions].
class OptionsConsoleDataSource {
  final String _fileName = 'console_options.json';
  final IFileManagerType _fileManagerType = FileManager(
    fileType: FileType.json,
  );
  final Completer<void> _completer = Completer<void>();

  String _pathFile = '';

  /// Cria a fonte de dados e inicia a inicialização assíncrona do caminho.
  OptionsConsoleDataSource() {
    _completer.complete(_init());
  }

  /// Future que se completa quando o caminho do arquivo está pronto.
  Future<void> get initialized => _completer.future;

  /// Lê e retorna as opções salvas.
  ///
  /// Aguarda [initialized] antes de acessar o arquivo.
  /// Em caso de erro de leitura/parse, retorna [ConsoleOptions.empty()].
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
      debugPrint("Error reading options: $e");
    }
    return OptionsEntry.fromConsoleOptions(ConsoleOptions.empty());
  }

  /// Persiste as [data] como JSON no arquivo de opções.
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
