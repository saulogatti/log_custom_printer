import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:log_custom_printer/src/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/log_helpers/logger_json_list.dart';
import 'package:log_custom_printer/src/utils/string_extension.dart';
import 'package:path/path.dart' as path;

/// Um gerenciador singleton de cache para arquivos de log.
///
/// [LoggerCache] fornece um cache centralizado em memória para dados de log,
/// e gerencia o armazenamento persistente de logs no diretório de suporte da aplicação.
/// Esta classe implementa o padrão singleton para garantir que apenas uma instância
/// gerencie o cache de logs durante todo o ciclo de vida da aplicação.
///
/// O cache inicializa automaticamente a estrutura de diretórios no
/// diretório de suporte da aplicação sob `loggerApp/logs/` quando acessado pela primeira vez.
/// Todos os arquivos de log são armazenados como JSON com a extensão `.json`.
///
/// {@category Utilities}
///
/// ## Uso
///
/// ```dart
/// final cache = LoggerCache();
///
/// // Aguardar a inicialização se necessário
/// await cache.futureInit;
///
/// // Limpar categoria específica de log
/// cache.clearLogs('error');
///
/// // Recuperar logs em cache
/// final logs = cache.getLogs('debug');
///
/// // Obter conteúdo do arquivo de log como JSON
/// final logData = cache.getLogResp('error_2023_11_17');
/// ```
///
/// ## Segurança de Thread
///
/// Este singleton é seguro para acesso concorrente. O processo de inicialização
/// é protegido por um [Completer] que garante que a configuração do diretório seja concluída
/// antes que qualquer operação de arquivo seja tentada.
class LoggerCache {
  /// O caminho para o diretório de logs.
  ///
  /// Inicializado como 'logger' e atualizado para o caminho real do diretório
  /// de suporte da aplicação durante [_init].
  String _directoryPath = 'logger';

  /// Completer para rastrear o estado de inicialização.
  ///
  /// Isso garante que a criação do diretório e configuração do caminho sejam concluídas
  /// antes que qualquer operação de arquivo seja tentada.
  late Future<void> _future;

  /// Callback opcional para lidar com erros durante a inicialização.
  /// Se fornecido, este callback será chamado com o erro e a stack trace se ocorrer um erro durante a configuração do diretório.
  void Function(Object error, StackTrace stackTrace)? onError;

  /// Factory constructor que retorna a instância singleton.
  ///
  /// Esta é a forma recomendada de acessar a instância [LoggerCache].
  /// A mesma instância é retornada a cada chamada, garantindo estado
  /// de cache consistente em toda a aplicação.
  ///
  /// Exemplo:
  /// ```dart
  /// final cache1 = LoggerCache();
  /// final cache2 = LoggerCache();
  /// assert(identical(cache1, cache2)); // true
  /// ```
  LoggerCache(String directory) {
    _future = _init(directory);
  }

  /// Um [Future] que completa quando a inicialização do cache termina.
  ///
  /// Use isso para garantir que a estrutura de diretórios esteja configurada antes
  /// de realizar operações de arquivo que dependem de [getPathLogs] ou [_getPathFile].
  ///
  /// Exemplo:
  /// ```dart
  /// final cache = LoggerCache('loggerApp/logs');
  /// await cache.futureInit; // Aguardar configuração do diretório
  /// final path = cache.getPathLogs('debug.json'); // Seguro para usar
  /// ```
  Future<void> get futureInitialization => _future;

  Future<void> clearAll() async {
    try {
      await futureInitialization; // Garantir que a inicialização esteja completa antes de limpar
      final directory = Directory(_directoryPath);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        await directory.create(recursive: true);
      }
    } catch (e, stack) {
      dev.log('Erro ao limpar os arquivos de log: $e', stackTrace: stack);
    }
  }

  Future<void> clearLogByType(String name) async {
    await futureInitialization; // Garantir que a inicialização esteja completa antes de limpar
    final fileName = _getPathFile(name);
    final file = File(fileName);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Lê e analisa um arquivo de log como dados JSON.
  ///
  /// Tenta ler o arquivo de log especificado do disco e analisá-lo como JSON.
  /// O [fileName] é processado automaticamente para garantir que tenha uma extensão `.json`
  /// e esteja localizado no diretório de logs correto.
  ///
  /// Parâmetros:
  /// * [fileName]: Nome do arquivo de log (extensão será definida como `.json`)
  ///
  /// Retorna:
  /// * [Map<String, dynamic>?]: Dados JSON analisados se o arquivo existir e for JSON válido
  /// * `null`: Se o arquivo não existir ou a análise JSON falhar
  ///
  /// Exemplo:
  /// ```dart
  /// final cache = LoggerCache();
  /// await cache.futureInit;
  ///
  /// final logData = await cache.getLogResp('error_2023_11_17');
  /// if (logData != null) {
  ///   print('Encontradas ${logData.length} entradas de log');
  /// }
  /// ```
  Future<Map<String, dynamic>?> getLogResp(String fileName) async {
    try {
      await futureInitialization; // Garantir que a inicialização esteja completa antes de acessar o arquivo
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

  Future<Map<EnumLoggerType, LoggerJsonList?>?> readAllLogs() async {
    try {
      await futureInitialization; // Garantir que a inicialização esteja completa antes de acessar os arquivos
      final directory = Directory(_directoryPath);
      if (await directory.exists()) {
        final files = directory.listSync().whereType<File>();
        final Map<EnumLoggerType, LoggerJsonList?> allLogs = {};
        for (final file in files) {
          if (file.path.endsWith('.json')) {
            final data = await file.readAsString();
            final mapJ = jsonDecode(data);
            if (mapJ is Map) {
              // LoggerJsonList é uma lista para cada tipo de log. Quando ele faz o json ele sabe qual tipo construir.
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

  /// Writes the [loggerList] to a file named by [fileName].
  ///
  /// This operation is asynchronous to avoid blocking the UI thread.
  Future<void> writeLogToFile(String fileName, Object loggerList) async {
    try {
      await futureInitialization; // Ensure initialization is complete before writing
      final path = _getPathFile(fileName);
      final File file = File(path);
      final spaces = ' ' * 2;

      // Ensure file exists
      if (!await file.exists()) {
        await file.create(recursive: true);
      }

      final jj = JsonEncoder.withIndent(spaces).convert(loggerList);
      await file.writeAsString(jj);
    } catch (e, stack) {
      // In case of error, we can't do much inside the printer itself without causing loops.
      // But we can print to console if debugging.
      // For now, silently fail or use print as fallback.
      // Ideally, error handling should be robust.
      // Replicating _printMessage logic from original handler locally if needed.
      onError?.call(e.toString(), stack);
      dev.log('Erro ao escrever o arquivo de log: $e', stackTrace: stack);
    }
  }

  /// Gera o caminho completo para um arquivo de log com extensão `.json`.
  ///
  /// Pega um [fileName] e garante que tenha a extensão `.json` correta,
  /// então retorna o caminho completo dentro do diretório de logs.
  ///
  /// Parâmetros:
  /// * [fileName]: Nome base para o arquivo de log (extensão será definida como `.json`)
  ///
  /// Retorna:
  /// * [String]: Caminho completo do arquivo com extensão `.json` no diretório de logs
  ///
  /// Lança:
  /// * [Exception]: Se chamado antes da inicialização estar completa
  ///
  /// Exemplo:
  /// ```dart
  /// final cache = LoggerCache();
  /// await cache.futureInitialization;
  ///
  /// final path = cache._getPathFile('error_log');
  /// // Retorna: '/caminho/para/app/support/loggerApp/logs/error_log.json'
  /// ```
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

  /// Inicializa a estrutura de diretórios do cache.
  ///
  /// Cria o diretório de logs no diretório de suporte da aplicação se não
  /// existir e atualiza [_directoryPath] com o caminho real.
  /// A estrutura de diretórios criada é: `applicationSupport/loggerApp/logs/`
  ///
  /// Este método é chamado automaticamente durante a construção do singleton e
  /// trata quaisquer erros durante a criação do diretório registrando-os e ainda
  /// completando a inicialização para evitar travamento.
  ///
  /// O completer [_future] é completado independentemente de sucesso ou falha
  /// para garantir que o código em espera não trave indefinidamente.
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
