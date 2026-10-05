# Log Printers

This module uses the *Strategy* pattern for log output. Each printer defines how logs are formatted and sent to the final destination (console, terminal, etc.).

## LogPrinterBase

Abstract contract for all log printers.

```dart
abstract class const LogPrinterBase() {

  void printLog(LoggerObjectBase log);
}
```

To create a custom printer, extend `LogPrinterBase` and implement `printLog`.

## LogSimplePrint

Simple printer without color formatting. Uses `print()`.

Typical output:

```
[ClassName] dd/MM/yyyy HH:mm:ss.SSS Log message
```

Recommended for:
- Environments without ANSI support (basic terminals, CI/CD, external log pipelines)
- Automated tests requiring clean output
- Production file-oriented logging

Shortcut:

```dart
registerLogPrinterSimple(config: ConfigLog(enableLog: true));
```

## LogWithColorPrint

ANSI color printer using `dart:developer.log()`.

Recommended for:
- Local development
- Visual debugging with log color differentiation
- Environments with ANSI and `dart:developer` support

Shortcut:

```dart
registerLogPrinterColor(
  config: ConfigLog(enableLog: true),
  maxLogsInCache: 200,
);
```

## Comparison

| Printer | Output | ANSI | Recommended use |
|--------|--------|------|-----------------|
| `LogSimplePrint` | `print()` | ❌ | Tests, CI/CD, production |
| `LogWithColorPrint` | `dart:developer.log()` | ✅ | Local development |
