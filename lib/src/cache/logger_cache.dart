import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:log_custom_printer/src/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/log_helpers/logger_json_list.dart';
import 'package:log_custom_printer/src/utils/string_extension.dart';
import 'package:path/path.dart' as path;

/// Gerenciador de cache para persistência de arquivos de log em disco.
///
/// Fornece funcionalidades para salvar, ler e limpar logs no sistema de arquivos.
/// Os logs são armazenados em formato JSON dentro de uma subpasta `loggerApp/logs`
/// a partir do diretório base fornecido.
///
/// {@category Utilities}

class LoggerCache {
  /// O caminho para o diretório de logs.
  String _directoryPath = 'logger';

  /// Future para rastrear o estado de inicialização do diretório.
  late Future<void> _future;

  /// Callback opcional para lidar com erros durante a inicialização ou escrita.
  void Function(Object error, StackTrace stackTrace)? onError;

  /// Cria um gerenciador de cache.
  ///
  /// [directory]: o diretório base onde os logs serão armazenados.
  LoggerCache(String directory) {
    _future = _init(directory);
  }

  /// Um [Future] que completa quando a inicialização do diretório termina.
  Future<void> get futureInitialization => _future;

  /// Limpa todos os arquivos de log do diretório.
  Future<void> clearAll() async {
    try {
      await futureInitialization;
      final directory = Directory(_directoryPath);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        await directory.create(recursive: true);
      }
    } catch (e, stack) {
      dev.log('Erro ao limpar os arquivos de log: $e', stackTrace: stack);
    }
  }

  /// Limpa os logs de um tipo específico (baseado no nome do arquivo).
  Future<void> clearLogByType(String name) async {
    await futureInitialization;
    final fileName = _getPathFile(name);
    final file = File(fileName);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Lê o conteúdo de um arquivo de log específico e o retorna como um Mapa JSON.
  Future<Map<String, dynamic>?> getLogResp(String fileName) async {
    try {
      await futureInitialization;
      final path = _getPathFile(fileName);
      final File file = File(path);
      if (await file.exists()) {
        final data = await file.readAsString();
        final mapJ = jsonDecode(data);
        if (mapJ is Map) {
          return Map<String, dynamic>.from(mapJ);
        }
      }
    } catch (e, stack) {
      dev.log('Erro ao ler ou analisar o arquivo de log: $e', stackTrace: stack);
    }
    return null;
  }

  /// Lê todos os arquivos de log presentes no diretório e os organiza por tipo.
  Future<Map<EnumLoggerType, LoggerJsonList?>?> readAllLogs() async {
    try {
      await futureInitialization;
      final directory = Directory(_directoryPath);
      if (await directory.exists()) {
        final files = directory.listSync().whereType<File>();
        final Map<EnumLoggerType, LoggerJsonList?> allLogs = {};
        for (final file in files) {
          if (file.path.endsWith('.json')) {
            final data = await file.readAsString();
            final mapJ = jsonDecode(data);
            if (mapJ is Map) {
              final loggerList = LoggerJsonList.fromJson(Map.from(mapJ));
              final typeLog = loggerList.enumLoggerType;
              if (typeLog != null) {
                allLogs[typeLog] = loggerList;
              }
            }
          }
        }
        return allLogs;
      }
    } catch (e, stack) {
      dev.log('Erro ao ler os arquivos de log: $e', stackTrace: stack);
    }
    return null;
  }

  /// Escreve uma lista de logs ([loggerList]) em um arquivo identificado por [fileName].
  Future<void> writeLogToFile(String fileName, Object loggerList) async {
    try {
      await futureInitialization;
      final path = _getPathFile(fileName);
      final File file = File(path);
      const spaces = '  ';

      if (!await file.exists()) {
        await file.create(recursive: true);
      }

      final jj = JsonEncoder.withIndent(spaces).convert(loggerList);
      await file.writeAsString(jj);
    } catch (e, stack) {
      onError?.call(e.toString(), stack);
      dev.log('Erro ao escrever o arquivo de log: $e', stackTrace: stack);
    }
  }

  /// Gera o caminho completo para um arquivo de log, garantindo a extensão .json
  /// e a sanitização do nome do arquivo.
  String _getPathFile(String fileName) {
    assert(fileName.isNotEmpty, 'O nome do arquivo não pode ser vazio');
    assert(
      fileName.contains(path.separator) == false,
      'O nome do arquivo não deve conter separadores de caminho',
    );
    assert(
      fileName.endsWith('.json') == false,
      'O nome do arquivo não deve conter a extensão .json, ela será adicionada automaticamente',
    );

    final sanitizedFileName = fileName.sanitizedFileName.formattedName;
    final fileJson = path.setExtension(sanitizedFileName, '.json');
    final pathLog = path.join(_directoryPath, fileJson);

    return pathLog;
  }

  /// Inicializa a estrutura de diretórios (`loggerApp/logs`) no caminho fornecido.
  Future<void> _init(String directory) async {
    try {
      final directoryPath = Directory('$directory/loggerApp/logs');
      if (!await directoryPath.exists()) {
        await directoryPath.create(recursive: true);
      }
      _directoryPath = directoryPath.path;
    } catch (e, stack) {
      if (onError != null) {
        onError!(e, stack);
      } else {
        dev.log('Erro ao inicializar LoggerCache: $e', stackTrace: stack);
      }
    }
  }
}
