import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

  /// Cache em memória armazenando entradas de log por chave de categoria.
  ///
  /// Cada chave representa uma categoria de log (ex: 'debug', 'error'),
  /// e os valores são listas de mensagens de log para essa categoria.
  final Map<String, List<String>> _cache = {};

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
  /// de realizar operações de arquivo que dependem de [getPathLogs] ou [getNameFile].
  ///
  /// Exemplo:
  /// ```dart
  /// final cache = LoggerCache('loggerApp/logs');
  /// await cache.futureInit; // Aguardar configuração do diretório
  /// final path = cache.getPathLogs('debug.json'); // Seguro para usar
  /// ```
  Future<void> get futureInit => _future;

  /// Remove todas as entradas de log em cache para a [key] especificada.
  ///
  /// Isso afeta apenas o cache em memória e não exclui
  /// nenhum arquivo de log persistido do disco.
  ///
  /// Parâmetros:
  /// * [key]: A categoria de log para limpar (ex: 'debug', 'error', 'info')
  ///
  /// Exemplo:
  /// ```dart
  /// final cache = LoggerCache();
  /// cache.clearLogs('error'); // Remove todos os logs de erro do cache
  /// ```
  void clearLogs(String key) {
    _cache.remove(key);
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
  /// final logData = cache.getLogResp('error_2023_11_17');
  /// if (logData != null) {
  ///   print('Encontradas ${logData.length} entradas de log');
  /// }
  /// ```
  Map<String, dynamic>? getLogResp(String fileName) {
    final path = getNameFile(fileName);
    final File file = File(path);
    if (file.existsSync()) {
      final data = file.readAsStringSync();
      final mapJ = jsonDecode(data);
      if (mapJ is Map) {
        return Map<String, dynamic>.from(mapJ);
      }
    }
    return null;
  }

  /// Recupera entradas de log em cache para a [key] especificada.
  ///
  /// Retorna as mensagens de log em cache na memória para a categoria fornecida.
  /// Este método acessa apenas o cache em memória e não lê do disco.
  ///
  /// Parâmetros:
  /// * [key]: A categoria de log para recuperar (ex: 'debug', 'error', 'info')
  ///
  /// Retorna:
  /// * [List<String>?]: Lista de mensagens de log para a categoria
  /// * `null`: Se nenhum log estiver em cache para a chave especificada
  ///
  /// Exemplo:
  /// ```dart
  /// final cache = LoggerCache();
  /// final debugLogs = cache.getLogs('debug');
  /// if (debugLogs != null) {
  ///   print('Encontradas ${debugLogs.length} mensagens de debug');
  /// }
  /// ```
  List<String>? getLogs(String key) {
    return _cache[key];
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
  /// await cache.futureInit;
  ///
  /// final path = cache.getNameFile('error_log');
  /// // Retorna: '/caminho/para/app/support/loggerApp/logs/error_log.json'
  /// ```
  String getNameFile(String fileName) {
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

  /// Writes the [loggerList] to a file named by [fileName].
  ///
  /// This operation is asynchronous to avoid blocking the UI thread.
  Future<void> writeLogToFile(String fileName, Object loggerList) async {
    try {
      final path = getNameFile(fileName);
      final File file = File(path);
      final spaces = ' ' * 2;

      // Ensure file exists
      if (!file.existsSync()) {
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
    }
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
    } catch (e) {
      if (onError != null) {
        onError!(e, StackTrace.current);
      } else {
        print('Erro ao inicializar LoggerCache: $e');
      }
    }
  }
}
