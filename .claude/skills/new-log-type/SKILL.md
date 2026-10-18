---
name: new-log-type
description: Add a new log type (a LoggerObjectBase subclass such as TraceLog or FatalLog) to log_custom_printer, wiring every place that switches on the log type so it serializes, sorts, filters and round-trips through the cache. Use when the user asks to add, create or introduce a new log level or log class.
---

# Add a new log type

A new log type touches several files that each switch on the type. Missing one does not fail to
compile: the type silently becomes `debug`, sorts as `debug`, is filtered out by default, or fails to
deserialize from the cache. Work through every step, then prove it with the tests in step 10.

Below, `Trace` / `TraceLog` / `EnumLoggerType.trace` stand for the new type. Read
`lib/src/domain/logs_object/warning_log.dart` first and mirror it.

## Steps

1. **Class** — create `lib/src/domain/logs_object/trace_log.dart`, using a primary constructor:

   ```dart
   part 'trace_log.g.dart';

   /// Trace log message with <color> formatting.
   ///
   /// {@category Log Types}
   @JsonSerializable()
   class TraceLog(super.message, {super.createdAt, super.typeClass}) extends LoggerObjectBase {
     /// Creates an instance from JSON.
     factory TraceLog.fromJson(Map<String, dynamic> json) => _$TraceLogFromJson(json);

     @override
     LoggerAnsiColor getColor() {
       return const LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.<color>);
     }

     @override
     Map<String, dynamic> toJson() => _$TraceLogToJson(this);
   }
   ```

   Override `alwaysPrint` only if it must bypass `ConfigLog(enableLog: false)` like `ErrorLog`.
   Pick a color that no other type uses (yellow, white, green and red are taken).

2. **Enum** — add `trace` to `EnumLoggerType` (`lib/src/domain/log_helpers/enum_logger_type.dart`)
   with a `///` doc comment.

3. **Instance → enum** — add `if (this is TraceLog) return EnumLoggerType.trace;` to
   `LoggerEnum.enumLoggerType` (`lib/src/domain/log_helpers/logger_enum.dart`), before the
   `debug` fallback.

4. **Deserialization** — in `lib/src/domain/logs_object/logger_json_list_type.dart`:
   - add `EnumLoggerType.trace: TraceLog.fromJson` to `_typeConstructors`;
   - add a `'TraceLog'` branch to `EnumLoggerTypeExtension.fromString`.

5. **Sorting** — add the type to `_severityIndex` in `lib/src/domain/query/log_sort_engine.dart`
   at the right severity, renumbering the others. Without it the type sorts as `debug`.

6. **Default filter** — decide whether the type belongs in the default
   `ConfigLog.onlyClasses` (`lib/src/config_log.dart`, currently `{DebugLog, WarningLog, InfoLog}`).
   If not added, apps using the default config never print it. Ask the user if unclear.

7. **Mixin (optional)** — if apps should emit it via `LoggerClassMixin`, add a `logTrace(...)`
   method in `lib/src/domain/log_helpers/logger_class_mixin.dart` following the existing ones.

8. **Export** — add `export 'src/domain/logs_object/trace_log.dart';` to
   `lib/log_custom_printer.dart`, keeping the exports sorted.

9. **Generate** — `dart run build_runner build`, then `dart format lib` (the generator writes at
   width 80; this repo uses 100). Never edit `trace_log.g.dart` by hand.

10. **Tests** — add to the existing files instead of a new one:
    - `test/log_types_test.dart`: color, `alwaysPrint`, `enumLoggerType`;
    - `test/logger_json_list_type_test.dart`: a `LoggerJsonListType` of the new type survives
      `toJson()` → `jsonEncode` → `jsonDecode` → `fromJson` with order and fields intact;
    - `test/log_sort_engine_test.dart`: the new type sorts at its severity;
    - if step 6 or 7 changed anything, cover it in `test/log_printer_service_test.dart` /
      `test/logger_class_mixin_test.dart`.

11. **Docs** — add the type to the log type list in `README.md`, `doc/LogTypes.md`, the library
    doc comment in `lib/log_custom_printer.dart`, the "Log type hierarchy" section of `CLAUDE.md`,
    and an `## Unreleased` entry in `CHANGELOG.md`. Adding an export is a public API change.

## Verify

```powershell
dart analyze
dart test
```

Both must be clean before reporting the type as done.
