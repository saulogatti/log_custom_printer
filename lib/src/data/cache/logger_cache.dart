import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:log_custom_printer/src/data/file_utils/file_manager_type.dart';
import 'package:log_custom_printer/src/domain/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_json_list.dart';
import 'package:log_custom_printer/src/utils/string_extension.dart';
import 'package:path/path.dart' as path;

/// Gerenciador de cache para persistência de arquivos de log em disco.
///
/// Fornece funcionalidades para salvar, ler e limpar logs no sistema de arquivos.
/// Os logs são armazenados em formato JSON dentro de uma subpasta `loggerApp/logs`
/// a partir do diretório base fornecido.
///
/// {@category Utilities}
final class LoggerCache {
  /// O caminho para o diretório de logs.
  String _directoryPath = 'logger';
  final IFileManagerType _fileManagerType;

  /// Future para rastrear o estado de inicialização do diretório.
  late Completer<void> _future;

  /// Callback opcional para lidar com erros durante a inicialização ou escrita.
  void Function(Object error, StackTrace stackTrace)? onError;

  /// Cria um gerenciador de cache.
  ///
  /// [directory]: o diretório base onde os logs serão armazenados.
  LoggerCache(String directory, {IFileManagerType? fileManagerType})
    : _fileManagerType =
          fileManagerType ?? FileManager(fileType: FileType.json) {
    _future = Completer<void>();
    _init(directory);
  }

  /// Um [Future] que completa quando a inicialização do diretório termina.
  Completer<void> get futureInitialization => _future;

  /// Limpa todos os arquivos de log do diretório.
  ///
  /// A operação aguarda a inicialização do diretório e ignora falhas,
  /// registrando o erro via `dart:developer.log`.
  Future<void> clearAll() async {
    try {
      await futureInitialization.future;
      await _fileManagerType.deleteDirectory(_directoryPath);
    } on Exception catch (e, stack) {
      dev.log('Erro ao limpar os arquivos de log: $e', stackTrace: stack);
    }
  }

  /// Limpa os logs de um tipo específico (baseado no nome do arquivo).
  ///
  /// [name] corresponde ao identificador usado no nome do arquivo de log.
  Future<void> clearLogByType(String name) async {
    await futureInitialization.future;
    final fileName = _getPathFile(name);
    await _fileManagerType.deleteFile(fileName);
  }

  /// Lê todos os arquivos de log presentes no diretório e os organiza por tipo.
  ///
  /// Retorna `null` quando o diretório não existe, está vazio ou ocorre erro
  /// de leitura/parsing.
  Future<Map<EnumLoggerType, LoggerJsonList?>?> readAllLogs() async {
    try {
      await futureInitialization.future;
      final directory = Directory(_directoryPath);
      if (await directory.exists()) {
        final files = await directory
            .list()
            .where((entity) => entity is File)
            .cast<File>()
            .toList();
        final Map<EnumLoggerType, LoggerJsonList?> allLogs = {};
        for (final file in files) {
          if (file.path.endsWith('.json')) {
            final data = await _fileManagerType.readFile(file.path);
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
    } on Exception catch (e, stack) {
      dev.log('Erro ao ler os arquivos de log: $e', stackTrace: stack);
    }
    return null;
  }

  /// Escreve uma lista de logs ([loggerList]) em um arquivo identificado por [fileName].
  ///
  /// O conteúdo é serializado como JSON formatado antes da escrita.
  /// Erros de I/O acionam [onError] quando definido.
  Future<void> writeLogToFile(String fileName, Object loggerList) async {
    try {
      await futureInitialization.future;
      final path = _getPathFile(fileName);
      assert(
        loggerList is Map && loggerList.isNotEmpty,
        'A lista de logs não pode ser nula.',
      );
      assert(
        loggerList is String && loggerList.isNotEmpty,
        'A lista de logs não pode ser nula.',
      );
      final objEncode = JsonEncoder.withIndent('  ').convert(loggerList);

      await _fileManagerType.writeFile(path, objEncode);
    } on Exception catch (e, stack) {
      onError?.call(e, stack);
      dev.log('Erro ao escrever o arquivo de log: $e', stackTrace: stack);
    }
  }

  /// Gera o caminho completo para um arquivo de log, garantindo a extensão .json
  /// e a sanitização do nome do arquivo.
  String _getPathFile(String fileName) {
    assert(fileName.isNotEmpty, 'O nome do arquivo não pode ser vazio');
    assert(
      !fileName.contains(path.separator),
      'O nome do arquivo não deve conter separadores de caminho',
    );

    final sanitizedFileName = fileName.sanitizedFileName.formattedName;
    final fileJson = path.setExtension(sanitizedFileName, '.json');
    final pathLog = path.join(_directoryPath, fileJson);

    return pathLog;
  }

  /// Inicializa a estrutura de diretórios (`loggerApp/logs`) no caminho fornecido.
  ///
  /// Completa [futureInitialization] após criar (ou validar) o diretório.
  Future<void> _init(String directory) async {
    try {
      final directoryPath = Directory('$directory/loggerApp/logs');
      if (!await directoryPath.exists()) {
        await directoryPath.create(recursive: true);
      }
      _directoryPath = directoryPath.path;
      _future.complete();
    } on Exception catch (e, stack) {
      if (onError != null) {
        onError!(e, stack);
      } else {
        dev.log('Erro ao inicializar LoggerCache: $e', stackTrace: stack);
      }
    }
  }
}
