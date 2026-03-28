import 'dart:async';

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

class TesteLog with LoggerClassMixin {
  bool isTest = true;
  void logTest() {
    isTest = !isTest;
    Timer.periodic(Duration(seconds: 4), (timer) {
      if (!isTest) {
        timer.cancel();
        return;
      }
      logDebug('Teste de log debug');
      logInfo('Teste de log info');
    });
    logWarning('Teste de log warning');
    logError('Teste de log error', StackTrace.current);
  }
}

class _MyAppState extends State<MyApp> with LoggerClassMixin {
  TesteLog testeLog = TesteLog();
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
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () {
              ConsoleOverlayManager.showOverlay(context, true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.close_fullscreen_outlined),
            onPressed: () {
              ConsoleOverlayManager.hide();
            },
          ),
          IconButton(
            icon: const Icon(Icons.co2_rounded),
            onPressed: () {
              ConsoleOverlayManager.show(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              testeLog.logTest();
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
          ElevatedButton(
            onPressed: () {
              testeLog.logTest();
            },
            child: const Text("Inicia Teste de Logs"),
          ),
          Flexible(
            child: ConsoleView(
              onClose: () {
                logInfo('Fechando a visualização de logs');
              },
            ),
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
