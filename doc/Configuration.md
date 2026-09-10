# Configuration

This module contains classes that control logging behavior.

## ConfigLog

Central logging configuration class. It defines which logs should be processed and which should be ignored.

```dart
class ConfigLog {
  final bool enableLog;
  final Set<Type> onlyClasses;
}
```

### Parameters

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `enableLog` | `bool` | `false` | Enables/disables log processing globally |
| `onlyClasses` | `Set<Type>` | `{DebugLog, WarningLog, InfoLog}` | Set of allowed log types |

### Behavior

- When `enableLog` is `false`, all logs are ignored **except** `ErrorLog` (`alwaysPrint = true`).
- `onlyClasses` filters by runtime type.
- `ErrorLog` does not need to be listed in `onlyClasses` to be processed.

### Usage examples

Default config (logs disabled):

```dart
final config = ConfigLog();
// enableLog: false, onlyClasses: {DebugLog, WarningLog, InfoLog}
```

Enable logs in development:

```dart
final config = ConfigLog(enableLog: true);
```

Only errors and warnings:

```dart
final config = ConfigLog(
  enableLog: true,
  onlyClasses: {ErrorLog, WarningLog},
);
```

Production-style config (only critical errors always pass):

```dart
final config = ConfigLog(enableLog: false);
```

Integration with printer registration:

```dart
void main() {
  registerLogPrinterColor(
    config: ConfigLog(
      enableLog: true,
      onlyClasses: {DebugLog, ErrorLog},
    ),
  );
}
```
