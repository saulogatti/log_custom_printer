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
  cacheFilePath: "/",
);

class MainApp extends StatelessWidget with LoggerClassMixin {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hello World App'),
          actions: [
            IconButton(
              onPressed: () {
                logInfo('Fechando o aplicativo');
                // Aqui você pode adicionar a lógica para fechar o aplicativo, se necessário
                logDebug('Aplicativo fechado');
                logWarning('Aviso: O aplicativo foi fechado');
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        body: Center(child: MyApp()),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with LoggerClassMixin {
  @override
  Widget build(BuildContext context) {
    return Column(
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
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    logDebug('Iniciando o aplicativo');
    logInfo('Aplicativo iniciado com sucesso');
    logWarning('Aviso: Este é um exemplo de log de aviso');
    logError('Erro: Este é um exemplo de log de erro', StackTrace.current);
  }
}
