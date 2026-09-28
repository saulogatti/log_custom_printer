// ignore_for_file: avoid_print

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
  // 1. Configuração inicial
  // Registramos uma impressora colorida para o console.
  // O LoggerPersistenceService retornado permite gerenciar o cache de logs.
  print('1. Configuração inicial:');
  persistenceService = registerLogPrinterSimple(
    config: const ConfigLog(
      enableLog: true, // Habilita o processamento de logs
      onlyClasses: {DebugLog, InfoLog, WarningLog, ErrorLog},
    ),
    cacheFilePath: 'cache_logs',
    maxLogsInCache: 5, // Limite de logs no cache por tipo
  );
  // await persistenceService.getAllLogs();
  print('Configuração inicial concluída');

  // 2. Uso com Mixin (Recomendado para classes da aplicação)
  print('2. Usando LoggerClassMixin:');
  final app = MinhaApp();
  app.processarDados();
  print('Uso com Mixin concluído');

  // 4. Consulta ao cache de logs
  print('3. Consultando o cache de logs:');
  final allLogs = await persistenceService.getAllLogs();
  print('Total de logs capturados: ${allLogs.length}');

  print('Exemplo concluído');
}

late LoggerPersistenceService persistenceService;

/// Exemplo de classe utilizando o mixin de logging
class MinhaApp with LoggerClassMixin {
  void processarDados() {
    logDebug('Iniciando processamento de dados...');

    // Simulação de lógica
    logInfo('Dados validados com sucesso.');

    logWarning('O processamento demorou mais que o esperado.');
    List.generate(100, (index) => logDebug('Esta é uma mensagem de debug $index'));

    // 2. Emissão de logs manual
    print('2. Emitindo logs manualmente:');
    logDebug('Esta é uma mensagem de debug');
    logInfo('Informação importante do sistema');
    logWarning('Atenção: recurso atingindo limite');

    try {
      throw Exception('Falha crítica na operação');
    } catch (e, stack) {
      logError('Erro detectado: $e', stack);
    } finally {
      logDebug('Fim do processamento de dados');
    }
  }
}
