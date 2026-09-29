# Utilities

This module groups support tools from the library: integration mixin, enums, formatting helpers, extensions, and cache services.

## LoggerClassMixin

Provides ready-to-use logging methods for any Dart class. It automatically fills `className` with host class `runtimeType`.

```dart
mixin LoggerClassMixin {
  Type get logClassType => runtimeType;

  void logDebug(String message);
  void logInfo(String message);
  void logWarning(String message);
  void logError(String message, StackTrace stackTrace);
}
```

## EnumLoggerType

Enum for available log severity types: `error`, `debug`, `warning`, `info`.

## LoggerJsonListType

Serializable container for logs of a single `EnumLoggerType` with configurable capacity.

- New logs are inserted at index 0 (newest first)
- When capacity is reached, the oldest log is dropped
- Supports `DebugLog`, `InfoLog`, `WarningLog`, `ErrorLog` deserialization

## ANSI helpers

- `EnumAnsiColors`: foreground/background ANSI code mapping
- `LoggerAnsiColor`: callable formatter for colored strings

## DateTimeLogHelper

Date formatting extension used by log rendering:
- `logFullDateTime` → `dd/MM/yyyy HH:mm:ss.SSS`
- `onlyDate()`
- `onlyTime()`

## StackTraceSdk

Stack trace formatting/filtering extension.

- `formatStackTrace(LoggerAnsiColor? color, int linesCount)`
- `stackInMap([int linesCount = 8])`

## ILoggerCacheRepository

Cache abstraction contract for custom storage implementations.

## LoggerCacheRepositoryImpl

Default `ILoggerCacheRepository` implementation:
- In-memory lists grouped by `EnumLoggerType`
- Optional disk persistence under `<saveLogFilePath>/loggerApp/logs/<type>.json`
- Loads persisted logs during initialization when path is provided

## LoggerPersistenceService

High-level service returned by `registerLogPrinter*` exposing:
- `addLog`
- `getAllLogs`
- `getLogsByType`
- `clearLogs`
- `clearLogsByType`

## LoggerCache

Low-level disk persistence manager used by `LoggerCacheRepositoryImpl`.

## FileManager and FileType

Internal file I/O utility with extension validation:

```dart
enum FileType { txt, json, log }
```

Concurrency guarantees:
- Same path operations are serialized
- Different path operations may run in parallel
