# log_custom_printer

A Dart logging library with typed log objects, ANSI color formatting, JSON serialization, and dependency injection (`get_it`).
It is suitable for CLI apps, servers, and scripts, and can also be used in Flutter apps after registering the printer at startup.

> **v3.0.0** — The package is now **pure Dart** (no Flutter dependency). Registration APIs (`registerLogPrinter`, `registerLogPrinterColor`, `registerLogPrinterSimple`) still return `LoggerPersistenceService` with integrated cache support. The Flutter visual console was moved to a separate package. See [doc/ConsoleView.md](doc/ConsoleView.md).

## Features

- **Typed log hierarchy**: `DebugLog`, `InfoLog`, `WarningLog`, `ErrorLog`
- **ANSI color formatting** for terminal output
- **JSON serialization** with `json_serializable`
- **Flexible configuration** via type filtering and enable/disable flags
- **Cache support** with in-memory and optional JSON file persistence
- **Concurrency-safe I/O** using path-based serialization in `FileManager`
- **Dependency injection** with `registerLogPrinter*`
- **Mixin support** via `LoggerClassMixin`
- **Traceability** with origin metadata (`className` / `runtimeType`)

## Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  log_custom_printer:
    git:
      url: https://github.com/saulogatti/log_custom_printer.git
    # or local path:
    # path: ../log_custom_printer
```

```bash
dart pub get
```

**Requirement:** Dart SDK ^3.11.0

## Basic usage

### Startup configuration (required before emitting logs)

```dart
import 'package:log_custom_printer/log_custom_printer.dart';

void main() {
  final persistenceService = registerLogPrinterColor(
    config: ConfigLog(enableLog: true),
    maxLogsInCache: 100,
    cacheFilePath: '/path/to/save/logs', // optional
  );

  // Flutter apps: runApp(const MyApp());
}
```

### Cache system

`registerLogPrinterColor` and `registerLogPrinterSimple` return `LoggerPersistenceService` for querying and cleanup. With `cacheFilePath`, `FileManager` serializes writes per path to avoid race conditions.

```dart
final allLogs = await persistenceService.getAllLogs();
final errorLogs = await persistenceService.getLogsByType(EnumLoggerType.error);
await persistenceService.clearLogs();
await persistenceService.clearLogsByType(EnumLoggerType.debug);
```

For custom storage, implement `ILoggerCacheRepository` and pass it to `registerLogPrinter(printer, cacheRepository: ..., config: ...)`.

### Mixin (recommended)

```dart
class MyClass with LoggerClassMixin {
  void myFunction() {
    logDebug('Starting function');
    logInfo('Processing data...');
    try {
      logInfo('Success');
    } catch (error, stackTrace) {
      logError('Error: $error', stackTrace);
    }
  }
}
```

### Log objects and JSON

```dart
final debugLog = DebugLog('Debug message', typeClass: runtimeType);
debugLog.sendLog();

final errorLog = ErrorLog('Failure', StackTrace.current, typeClass: runtimeType);
errorLog.sendLog();

final json = debugLog.toJson();
final restored = DebugLog.fromJson(json);
```

### Advanced configuration

```dart
void main() {
  registerLogPrinterColor(
    config: ConfigLog(
      enableLog: true,
      onlyClasses: {DebugLog, ErrorLog},
    ),
  );
  // Flutter apps: runApp(const MyApp());
}
```

### Delivery rules

- `ConfigLog.enableLog == false`: most logs are dropped; `ErrorLog` still runs via `alwaysPrint`.
- `ConfigLog.onlyClasses`: when not empty, only listed types are accepted.
- `LoggerClassMixin`: sets `className` using the emitter class `runtimeType`.
- Cache repository: keeps up to `maxLogEntries` per log type (based on repository implementation).

## Architecture (summary)

- **`LoggerObject` / `LoggerObjectBase`** — log hierarchy and dispatch
- **`LogPrinterService`** — output and cache coordination (via `get_it`)
- **`registerLogPrinter` / `registerLogPrinterColor` / `registerLogPrinterSimple`**
- **`ConfigLog`** — filters and `enableLog`
- **`LoggerPersistenceService`** — cache access after registration
- **`ILoggerCacheRepository`** — customizable persistence contract

### Log types

| Type | ANSI color | Usage |
|------|------------|-------|
| `DebugLog` | Yellow | Debugging |
| `InfoLog` | White | General information |
| `WarningLog` | Green | Warnings |
| `ErrorLog` | Red | Errors (`alwaysPrint`) |

### Printers

- **`LogSimplePrint`** — simple output (no ANSI color formatting in default strategy)
- **`LogWithColorPrint`** — ANSI color output

Shortcuts: `registerLogPrinterColor` / `registerLogPrinterSimple`; custom printer: `registerLogPrinter(LogPrinterBase(), config: ...)`.

### Visual console (Flutter)

The real-time Flutter console UI is **not part of this repository** in v3. To migrate from v2 or integrate the separate package, see [doc/ConsoleView.md](doc/ConsoleView.md).

## Development

```bash
dart pub get
dart run build_runner build
# or: ./ci.sh -build
```

```bash
dart analyze
dart test
dart doc
```

Generated API docs are output to `doc/api` by default. Do not use a `docs/` output folder for `dart doc`; this repository keeps project guides under `doc/`.

### New log types

1. Extend `LoggerObjectBase`
2. Add `@JsonSerializable()` and generated `part`
3. Implement `getColor()`, `fromJson`, `toJson`
4. Register in `logger_json_list.dart` when applicable
5. Export in the public API and run `build_runner`

## Documentation

| File | Content |
|------|---------|
| [README.md](README.md) | Overview (this page) |
| [CHANGELOG.md](CHANGELOG.md) | Version history |
| [doc/Core.md](doc/Core.md) | Core and dependency injection |
| [doc/LogTypes.md](doc/LogTypes.md) | Log types |
| [doc/Printers.md](doc/Printers.md) | Printing strategies |
| [doc/Configuration.md](doc/Configuration.md) | Configuration and filters |
| [doc/Utilities.md](doc/Utilities.md) | Utilities and cache |
| [doc/ConsoleView.md](doc/ConsoleView.md) | Flutter console migration |
| [doc/DOCUMENTATION.md](doc/DOCUMENTATION.md) | Extended architecture |

## Contributing

1. Keep the public API stable
2. Record relevant changes in `CHANGELOG.md`
3. Run tests before opening PRs
4. Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)

## License

See `LICENSE` in the repository.
