import 'package:flutter/material.dart';
import 'package:log_custom_printer/log_custom_printer.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Scaffold(body: MyWidget()));
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class Teste2 with LoggerClassMixin {
  Future<void> execute() async {
    logInfo("Executando método execute");
    Future.delayed(Duration(seconds: 3), () {
      logDebug("Processo em andamento...");
    });
    logInfo("Processo iniciado");
  }
}

class TesteLog with LoggerClassMixin {
  Future<void> execute() async {
    logInfo("Executando método execute");
    Future.delayed(Duration(seconds: 1), () {
      logDebug("Processo em andamento...");
    });
    logInfo("Processo iniciado");
  }
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exemplo de Log Customizado')),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Teste2 teste2 = Teste2();
                teste2.execute();
              },
              child: Text('Testar Log'),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                TesteLog testeLog = TesteLog();
                testeLog.execute();
              },
              child: Text('Testar Log 2'),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Teste2 teste2 = Teste2();
                TesteLog testeLog = TesteLog();
                teste2.execute();
                testeLog.execute();
              },
              child: Text('Testar  Log 1 e 2'),
            ),
          ),
        ],
      ),
    );
  }
  @override
  void initState() {
    LogCustomPrinterBase.colorPrint();
     super.initState();
  }
}
