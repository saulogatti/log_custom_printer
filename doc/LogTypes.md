# Log Types

This module defines the concrete log types available in the library. All of them extend `LoggerObjectBase` and belong to the sealed `LoggerObject` hierarchy.

```
LoggerObject (sealed)
    └── LoggerObjectBase (abstract)
            ├── DebugLog    (yellow)
            ├── InfoLog     (white)
            ├── WarningLog  (green)
            └── ErrorLog    (red + stack trace)
```

Each type defines its own `getColor()`, supports JSON serialization via `@JsonSerializable()`, and can be instantiated directly or through `LoggerClassMixin`.

## DebugLog

Debug message log, displayed in **yellow**.

Use it for development messages: variable values, execution flow, and diagnostics that usually should not appear in production.

## InfoLog

Informational log, displayed in **white**.

Use it for relevant events in normal application flow: completed operations, execution milestones, and state changes.

## WarningLog

Warning log, displayed in **green**.

Use it for situations that need attention but do not stop application behavior: high resource usage, non-critical unexpected behavior, deprecations.

## ErrorLog

Error log, displayed in **red**, including `stackTrace`.

This is the only type with `alwaysPrint = true`, so it is always processed regardless of `ConfigLog.enableLog` or `ConfigLog.onlyClasses`.

`ErrorLog.getMessage()` also appends formatted stack trace lines to output for direct console debugging.

## JSON serialization

All log types support JSON serialization/deserialization:

```dart
final log = DebugLog('Test message');
final json = log.toJson();
final restored = DebugLog.fromJson(json);
```

In `ErrorLog`, `StackTrace` is serialized as `String` through `StackTraceConverter`.
