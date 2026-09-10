# Core — Logging System

This module defines the fundamental types and dependency-injection infrastructure of the library.

## LoggerObject

Sealed marker base class for the log type hierarchy.

```dart
sealed class LoggerObject {}
```

It has no members. It ensures only library-defined types (`DebugLog`, `InfoLog`, `WarningLog`, `ErrorLog`) can extend the hierarchy, enabling exhaustive `switch` pattern matching.

## LoggerObjectBase

Abstract class that defines the full contract for log objects.

```dart
abstract class LoggerObjectBase extends LoggerObject {
  final String message;
  final String tag;
  DateTime logCreationDate;
  late String className;
}
```

### Main fields

| Field | Type | Description |
|-------|------|-------------|
| `message` | `String` | Main log message |
| `tag` | `String` | Optional tag for categorization |
| `logCreationDate` | `DateTime` | Creation timestamp (default: `DateTime.now()`) |
| `className` | `String` | Class/source name that emitted the log |

### Methods

- **`getColor()`** — Returns ANSI color for the log type (implemented by each subtype)
- **`getMessage([bool withColor])`** — Returns formatted message with timestamp, with or without ANSI color
- **`getStartLog([bool withColor])`** — Returns formatted log header (type + source)
- **`sendLog()`** — Sends the log to `LogPrinterService` resolved via `get_it`
- **`toJson()`** — Serializes object to JSON
- **`alwaysPrint`** — When `true`, the log is processed even with `ConfigLog.enableLog = false` (default: `false`; `ErrorLog` overrides to `true`)

### Validation

In debug mode, the constructor asserts that message is not empty and not whitespace-only.

## LogPrinterService

Central service that coordinates log output and storage.

```dart
final class LogPrinterService {
  final LogPrinterBase logPrinter;
  LoggerPersistenceService get cacheRepository;

  void executePrint(LoggerObjectBase log);
}
```

Registered as a singleton in `get_it` by `registerLogPrinter`. It applies `ConfigLog` rules, then delegates to `logPrinter.printLog()` and `cacheRepository.addLog()` when the log should be processed.

Processing rules in `executePrint`:
1. If `enableLog` is `true` and log type is in `onlyClasses` (or `onlyClasses` is empty) → print and store.
2. If `log.alwaysPrint` is `true` → print and store regardless of config.
3. Otherwise → silently drop.

## fetchLogPrinterService

Internal function that resolves the registered `LogPrinterService` from `get_it`.

```dart
LogPrinterService fetchLogPrinterService();
```

Throws `StateError` when `registerLogPrinter` was not called before first log usage.

## registerLogPrinter

Registers the main printer in `get_it`. Must be called at app startup before emitting logs.

```dart
LoggerPersistenceService registerLogPrinter(
  LogPrinterBase printer, {
  ILoggerCacheRepository? cacheRepository,
  required ConfigLog config,
});
```

Returns the `LoggerPersistenceService` linked to the registered service so callers can query and manage cached/persisted logs.

Registration shortcuts:

```dart
LoggerPersistenceService registerLogPrinterColor({
  ConfigLog? config,
  int maxLogsInCache = 100,
  String? cacheFilePath,
  FileType fileType = FileType.json,
});

LoggerPersistenceService registerLogPrinterSimple({
  ConfigLog? config,
  int maxLogsInCache = 100,
  String? cacheFilePath,
  FileType fileType = FileType.json,
});
```

### Startup example

```dart
void main() {
  final cache = registerLogPrinterColor(
    config: ConfigLog(enableLog: true),
  );

  // Flutter apps: runApp(const MyApp());
}
```

### Test setup example

```dart
setUp(() {
  registerLogPrinter(
    const LogSimplePrint(),
    config: const ConfigLog(enableLog: true),
  );
});

tearDown(() async => await GetIt.instance.reset());
```
