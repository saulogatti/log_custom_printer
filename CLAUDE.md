# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`log_custom_printer` is a **pure Dart** logging library (no Flutter dependency). It provides typed log objects, ANSI color formatting, JSON serialization, in-memory/file caching, and dependency injection via `get_it`. The Flutter visual console was removed in v3.0.0 and lives in a separate package.

## Commands

```bash
dart pub get                                              # Install dependencies
dart analyze                                              # Static analysis
dart test                                                 # Full test suite
dart test test/<file>_test.dart                           # Single test file
dart test test/<file>_test.dart -n "test name here"       # Single test by name
dart run build_runner build                               # Regenerate *.g.dart files
./ci.sh -build                                            # Same as build_runner (shortcut)
./ci.sh -upgrade                                          # Upgrade deps to latest major versions
dart doc                                                  # Generate API docs → doc/api/
```

**Never use `flutter` commands** in this repository. The package is pure Dart.

CI (`.github/workflows/dart.yml`) runs `dart pub get`, `dart analyze`, `dart test` on pushes/PRs to `main`.

### Language features

The SDK constraint is `>=3.13.0 <4.0.0`, and the code uses **primary constructors**
(e.g. `class const ConfigLog({final bool enableLog = false, ...});`,
`class LoggerJsonListType({required var EnumLoggerType type}) { ... }`). Follow this style when adding
classes; `tool/_primary_ctor_probe.dart` is a scratch probe of the syntax.

## Architecture

### Dependency flow

```
LoggerObjectBase.sendLog()
  → fetchLogPrinterService()          # resolves singleton from get_it
  → LogPrinterService.executePrint()  # applies ConfigLog filters
      → LoggerPersistenceService.addLog()  # async cache write (fire-and-forget)
      → LogPrinterBase.printLog()          # synchronous output
```

### Key types

| File | Role |
|------|------|
| `lib/src/domain/logs_object/logger_object.dart` | `LoggerObject` (sealed) + `LoggerObjectBase` (abstract) — base of all log types |
| `lib/src/log_custom_printer_base.dart` | `LogPrinterBase` — strategy interface for output |
| `lib/src/log_printer_service.dart` | `LogPrinterService` — central service; applies `ConfigLog` filters before printing/caching |
| `lib/src/log_printer_locator.dart` | `registerLogPrinter` / `registerLogPrinterColor` / `registerLogPrinterSimple` — startup registration via `get_it` |
| `lib/src/config_log.dart` | `ConfigLog` — `enableLog` flag + `onlyClasses` filter set |
| `lib/src/data/cache/logger_persistence_service.dart` | `LoggerPersistenceService` — query/clear API returned by `registerLogPrinter*` |
| `lib/src/data/cache/logger_cache.dart` | `LoggerCache` — file I/O; stores logs under `<dir>/loggerApp/logs/` as JSON |
| `lib/src/data/cache/logger_cache_repository_impl.dart` | `LoggerCacheRepositoryImpl` — implements `ILoggerCacheRepository`, keeps a `Map<EnumLoggerType, LoggerJsonListType?>` and syncs it with `LoggerCache` |
| `lib/src/domain/logs_object/logger_json_list_type.dart` | `LoggerJsonListType` — per-`EnumLoggerType` serializable list used by the cache; its `_typeConstructors` map and `EnumLoggerTypeExtension.fromString` drive deserialization |
| `lib/src/domain/log_helpers/` | `EnumLoggerType`, `LoggerEnum` extension (`log.enumLoggerType`), `LoggerClassMixin` (recommended integration for app classes), `LogException` |
| `lib/src/domain/query/` | `LogQuery`, `LogFilterEngine`, `LogSortEngine` — composable query pipeline |
| `lib/log_custom_printer.dart` | Public API — everything exported here is the stable public contract |

### Log type hierarchy

All log types extend `LoggerObjectBase` (which extends sealed `LoggerObject`):
- `DebugLog` — yellow ANSI
- `InfoLog` — white ANSI
- `WarningLog` — green ANSI
- `ErrorLog` — red ANSI; `alwaysPrint = true` (bypasses `ConfigLog.enableLog = false`)

### Filtering rules

- `ConfigLog(enableLog: false)` suppresses all logs **except** those with `alwaysPrint` (`ErrorLog`).
- `ConfigLog(onlyClasses: {...})` when non-empty, only those runtime types are accepted.
- Default `ConfigLog()` has `enableLog: false` and `onlyClasses: {DebugLog, WarningLog, InfoLog}`.

### File persistence concurrency

`FileManager` (in `lib/src/data/file_utils/file_manager_type.dart`) serializes writes per path using a
`Map<String, Future>` chain, avoiding race conditions when multiple logs write to the same file simultaneously.

## Conventions

### Adding a new log type

1. Extend `LoggerObjectBase` in `lib/src/domain/logs_object/`.
2. Annotate with `@JsonSerializable()` and add `part '<name>.g.dart';`.
3. Implement `getColor()`, `fromJson()`, `toJson()`.
4. Add a value to `EnumLoggerType` and map it in the `LoggerEnum.enumLoggerType` extension
   (`logger_enum.dart`) — otherwise the new type silently falls through to `EnumLoggerType.debug`.
5. Register the constructor in `LoggerJsonListType._typeConstructors` and `EnumLoggerTypeExtension.fromString`
   (`logger_json_list_type.dart`).
6. Export the new type in `lib/log_custom_printer.dart`.
7. Run `dart run build_runner build`.

`build.yaml` configures `json_serializable` with `explicit_to_json: true` and `checked: true`.

Avoid `print` outside printer strategies (`avoid_print` is enabled).

### Generated files

Never edit `*.g.dart` files manually. They are regenerated by `build_runner` from `@JsonSerializable` annotations.

### Public API contract

`lib/log_custom_printer.dart` is the stable public contract. Adding or removing exports is a breaking change. Keep internal types under `lib/src/` unexported.

### DI in tests

Register a printer in `setUp` and call `GetIt.instance.reset()` in `tearDown` for any test that exercises DI or logging.

### File tests

Use `Directory.systemTemp.createTemp(...)` for temporary directories and clean them up in `tearDown`/`tearDownAll`.

### Linter

Formatter page width is 100 characters (`formatter.page_width` in `analysis_options.yaml`). The config
enables a very large rule set on top of `package:lints/recommended.yaml`; notable ones promoted to **errors**
include `avoid_dynamic_calls`, `inference_failure_on_function_invocation`, `parameter_assignments`,
`avoid_void_async`, and `await_only_futures`. Also enforced: `always_use_package_imports`,
`prefer_single_quotes`, `require_trailing_commas`, `unawaited_futures`. `deprecated_member_use_from_same_package`
is a warning. Run `dart analyze` and keep it clean.

### Documentation language

Write all project documentation (README, `doc/`, API docs, AI instructions) in **English**.

## Reference docs

- `doc/Core.md` — DI and registration internals
- `doc/LogTypes.md` — log type details
- `doc/Printers.md` — printer strategies
- `doc/Configuration.md` — `ConfigLog` and filtering
- `doc/Utilities.md` — cache, `LoggerPersistenceService`, query pipeline
- `doc/DOCUMENTATION.md` — expanded architecture overview
- `doc/ConsoleView.md` — Flutter visual console migration guide (separate package)
