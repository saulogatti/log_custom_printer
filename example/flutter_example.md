# Usage with Flutter and ConsoleView

Since version 3.0.0, the visual console UI (`ConsoleView`) was moved to a separate package so this library remains **pure Dart**.

To use a visual console in your Flutter app, integrate this package with the dedicated UI package.

## 1. Initial setup

Register a printer in `main.dart` before `runApp`:

```dart
import 'package:flutter/material.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
// import 'package:log_custom_printer_console_view/log_custom_printer_console_view.dart';

void main() {
  final persistenceService = registerLogPrinterColor(
    config: const ConfigLog(enableLog: true),
  );

  runApp(MyApp(persistenceService: persistenceService));
}
```

## 2. Visual console integration (conceptual)

The visual package will usually expose a widget or overlay manager.

```dart
class MyApp extends StatelessWidget {
  final LoggerPersistenceService persistenceService;

  const MyApp({super.key, required this.persistenceService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter Example')),
        body: const Center(child: Text('Tap the button to open console')),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Conceptual example:
            // ConsoleOverlayManager.show(context, persistenceService);
          },
          child: const Icon(Icons.terminal),
        ),
      ),
    );
  }
}
```

## 3. Capturing Flutter errors

Use `ErrorLog` for global error capture:

```dart
void main() {
  final persistenceService = registerLogPrinterColor(config: const ConfigLog(enableLog: true));

  FlutterError.onError = (details) {
    ErrorLog(
      details.exceptionAsString(),
      details.stack ?? StackTrace.current,
      typeClass: details.exception.runtimeType,
    ).sendLog();
  };

  runApp(MyApp(persistenceService: persistenceService));
}
```

## 4. Next steps

For concrete integration details, see [doc/ConsoleView.md](../doc/ConsoleView.md) and the visual console package README.
