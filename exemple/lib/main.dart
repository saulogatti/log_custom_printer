import 'package:flutter/material.dart';
import 'package:log_custom_printer/log_custom_printer.dart';

void main() {
  runApp(const MainApp());
}

final logConfig = registerLogPrinterColor(
  config: ConfigLog(
    enableLog: true,
    onlyClasses: {DebugLog, InfoLog, WarningLog, ErrorLog},
  ),
  cacheFilePath: "/logs",
);

class MainApp extends StatelessWidget with LoggerClassMixin {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class Teste implements ILoggerCacheRepository {
  @override
  Future<void> addLog(LoggerObjectBase log) {
    // TODO: implement addLog
    throw UnimplementedError();
  }

  @override
  Future<void> clearLogs() {
    // TODO: implement clearLogs
    throw UnimplementedError();
  }

  @override
  Future<void> clearLogsByType(EnumLoggerType type) {
    // TODO: implement clearLogsByType
    throw UnimplementedError();
  }

  @override
  Future<List<LoggerObjectBase>> getAllLogs() {
    // TODO: implement getAllLogs
    throw UnimplementedError();
  }

  @override
  Future<List<LoggerObjectBase>> getLogsByType(EnumLoggerType type) {
    // TODO: implement getLogsByType
    throw UnimplementedError();
  }
}

class _MyAppState extends State<MyApp> with LoggerClassMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Custom Printer Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () {
              ConsoleOverlayManager.showOverlay(context, true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ConsoleOverlayManager.hideConsoleOverlayManager();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConsoleView(
                    onClose: () {
                      logInfo('Fechando a visualização de logs');
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
            child: const Text('Get All Logs'),
          ),
          ElevatedButton(
            onPressed: () {
              logConfig.clearLogs();
            },
            child: const Text('Clear Logs'),
          ),
          ElevatedButton(
            onPressed: () {
              logDebug('Iniciando o aplicativo');
              logInfo('Aplicativo iniciado com sucesso');
              logWarning('Aviso: Este é um exemplo de log de aviso');
              logError(
                'Erro: Este é um exemplo de log de erro',
                StackTrace.current,
              );
            },
            child: const Text("Adiciona logs"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    logConfig
        .getAllLogs()
        .then((logs) {
          debugPrint('Logs carregados: ${logs.length} registros encontrados');
        })
        .catchError((error) {
          debugPrint('Erro ao carregar logs: $error');
        });
    logDebug('Iniciando o aplicativo');
    logInfo('Aplicativo iniciado com sucesso');
    logWarning('Aviso: Este é um exemplo de log de aviso');
    logError('Erro: Este é um exemplo de log de erro', StackTrace.current);
  }
}
