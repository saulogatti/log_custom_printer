# Uso com Flutter e ConsoleView

Desde a versão 3.0.0, a interface gráfica de console (`ConsoleView`) foi movida para um pacote separado para manter esta biblioteca como **Dart pura**.

Para usar o console visual em seu aplicativo Flutter, você precisará integrar este pacote com o novo pacote de interface (quando disponível).

## 1. Configuração Inicial

No seu arquivo `main.dart`, registre a impressora antes de iniciar o aplicativo:

```dart
import 'package:flutter/material.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
// import 'package:log_custom_printer_console_view/log_custom_printer_console_view.dart'; // Exemplo de import futuro

void main() {
  // Configura o core de logging
  final persistenceService = registerLogPrinterColor(
    config: const ConfigLog(enableLog: true),
  );

  runApp(MyApp(persistenceService: persistenceService));
}
```

## 2. Integrando o ConsoleView (Conceitual)

O pacote de console visual geralmente fornecerá um widget ou um gerenciador de overlay.

```dart
class MyApp extends StatelessWidget {
  final LoggerPersistenceService persistenceService;

  const MyApp({super.key, required this.persistenceService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Exemplo Flutter')),
        body: const Center(child: Text('Toque no botão para abrir o console')),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Exemplo conceitual de abertura do console
            // ConsoleOverlayManager.show(context, persistenceService);
          },
          child: const Icon(Icons.terminal),
        ),
      ),
    );
  }
}
```

## 3. Capturando Erros do Flutter

Você pode usar o `ErrorLog` para capturar exceções globais do Flutter:

```dart
void main() {
  registerLogPrinterColor(config: const ConfigLog(enableLog: true));

  FlutterError.onError = (details) {
    ErrorLog(
      details.exceptionAsString(),
      details.stack ?? StackTrace.current,
      typeClass: details.library?.runtimeType,
    ).sendLog();
  };

  runApp(const MyApp());
}
```

## 4. Próximos Passos

Para detalhes específicos sobre a integração com a interface gráfica, consulte o guia de migração em [docs/ConsoleView.md](../doc/ConsoleView.md) e a documentação do pacote de console visual quando este for publicado.
