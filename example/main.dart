import 'package:log_custom_printer/log_custom_printer.dart';

/// Exemplo de uso da biblioteca log_custom_printer em um ambiente Dart puro.
///
/// Este exemplo demonstra:
/// 1. Configuração inicial (registro da impressora)
/// 2. Emissão de logs de diferentes níveis (Debug, Info, Warning, Error)
/// 3. Uso do LoggerClassMixin para integração em classes
/// 4. Consulta e gerenciamento de logs via LoggerPersistenceService
/// 5. Serialização JSON
void main() async {
  print('--- Iniciando Exemplo log_custom_printer ---\n');
  final log = DebugLog('Esta é uma mensagem de debug ${StackTrace.current.toString()}');
  log.sendLog();

  // 1. Configuração inicial
  // Registramos uma impressora colorida para o console.
  // O LoggerPersistenceService retornado permite gerenciar o cache de logs.
  final persistenceService = registerLogPrinterColor(
    config: const ConfigLog(
      enableLog: true, // Habilita o processamento de logs
    ),
    maxLogsInCache: 50, // Limite de logs no cache por tipo
  );

  // 2. Emissão de logs manual
  print('2. Emitindo logs manualmente:');
  DebugLog('Esta é uma mensagem de debug').sendLog();
  InfoLog('Informação importante do sistema').sendLog();
  WarningLog('Atenção: recurso atingindo limite').sendLog();

  try {
    throw Exception('Falha crítica na operação');
  } catch (e, stack) {
    ErrorLog('Erro detectado: $e', stack).sendLog();
  }
  print('');

  // 3. Uso com Mixin (Recomendado para classes da aplicação)
  print('3. Usando LoggerClassMixin:');
  final app = MinhaApp();
  app.processarDados();
  print('');

  // 4. Consulta ao cache de logs
  print('4. Consultando o cache de logs:');
  final allLogs = await persistenceService.getAllLogs();
  print('Total de logs capturados: ${allLogs.length}');

  final errors = await persistenceService.getLogsByType(EnumLoggerType.error);
  print('Total de erros: ${errors.length}');

  if (errors.isNotEmpty) {
    print('Último erro capturado: ${errors.first.message}');
  }
  print('');

  // 5. Serialização JSON
  print('5. Demonstração de JSON:');
  final logParaJson = InfoLog('Log para exportação');
  final json = logParaJson.toJson();
  print('Log em JSON: $json');

  final logRestaurado = InfoLog.fromJson(json);
  print('Log restaurado da mensagem: ${logRestaurado.message}');
  print('');

  // 6. Limpeza de logs
  print('6. Limpando logs:');
  await persistenceService.clearLogsByType(EnumLoggerType.debug);
  final logsRestantes = await persistenceService.getAllLogs();
  print('Logs após limpar debug: ${logsRestantes.length}');

  print('\n--- Exemplo concluído ---');
}

/// Exemplo de classe utilizando o mixin de logging
class MinhaApp with LoggerClassMixin {
  void processarDados() {
    logDebug('Iniciando processamento de dados...');

    // Simulação de lógica
    logInfo('Dados validados com sucesso.');

    logWarning('O processamento demorou mais que o esperado.');
  }
}
