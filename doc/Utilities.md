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
- `queryLogs`
- `searchLogByCreated`
- `searchLogByRuntimeType`
- `searchLogByTag`

### Querying logs

`LogQuery` combines optional type and date filters with optional sorting. The start
date is inclusive and the end date is exclusive.

```dart
final recentErrors = await persistenceService.queryLogs(
  LogQuery(
    types: {EnumLoggerType.error},
    start: DateTime.now().subtract(const Duration(hours: 1)),
    sortField: LogSortField.date,
    sortDirection: SortDirection.desc,
  ),
);
```

`LoggerFilter` is a lower-level facade for applying a query to an existing list.

## LoggerCache

Low-level disk persistence manager used by `LoggerCacheRepositoryImpl`.

## FileManager and file operations

`FileManager` provides asynchronous file and directory operations. `writeFile`
accepts an optional `FileMode` (`FileMode.write` by default) and serializes
operations for the same path.

```dart
await FileManager().writeFile('logs.json', content, FileMode.append);
```

Concurrency guarantees:
- Same path operations are serialized
- Different path operations may run in parallel
