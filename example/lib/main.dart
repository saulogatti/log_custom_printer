import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

/// Counter widget with logger mixin. He print type class and message.
class CounterWidget with LoggerClassMixin {
  int _counter;

  CounterWidget({required this._counter});

  int get counter => _counter;
  set counter(int value) {
    logDebug('LogDebug: counter set to $value');
    logWarning('LogWarning: counter set to $value');
    logInfo('LogInfo: counter set to $value');
    logError('LogError: counter set to $value', StackTrace.current);
    _counter = value;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CounterWidget counterWidget;

  /// Logger service for printing logs.
  late LoggerPersistenceService logPrinterService;

  /// Builds the widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '${counterWidget.counter}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Listens to the log stream and prints the logs.
  @override
  void initState() {
    counterWidget = CounterWidget(counter: 0);
    super.initState();
    _initLogger();
  }

  void _incrementCounter() {
    setState(() {
      counterWidget.counter++;
    });
  }

  Future<void> _initLogger() async {
    Directory directory = await getApplicationSupportDirectory();
    logPrinterService = registerLogPrinterColor(
      config: const ConfigLog(enableLog: true),
      cacheFilePath: directory.path,
    );

    logPrinterService.logStream.listen((log) {
      if (kDebugMode) {
        print("Received log: ${log.getMessage()}");
      }
    });
  }
}
