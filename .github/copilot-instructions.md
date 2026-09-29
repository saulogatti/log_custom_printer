# Project Guidelines — `log_custom_printer`

## Code Style

- Follow `analysis_options.yaml` and Effective Dart.
- Keep the public API in `lib/log_custom_printer.dart` stable; export changes are contract changes.
- Add exports in `lib/log_custom_printer.dart` only when a type is truly public; otherwise keep it internal in `lib/src/`.
- Do not edit generated files (`*.g.dart`).

## Architecture

- Logging library with:
  - sealed hierarchy `LoggerObject` → `LoggerObjectBase` (`lib/src/domain/logs_object/`)
  - DI via `get_it` in `log_printer_locator.dart`
  - output Strategy (`LogPrinterBase`, `LogSimplePrint`, `LogWithColorPrint`)
  - cache via `ILoggerCacheRepository` + `LoggerPersistenceService`
- Critical domain rules:
  - call `registerLogPrinter*` at startup before sending logs
  - `ErrorLog` always processes (`alwaysPrint`) even with `ConfigLog(enableLog: false)`
  - recommended integration in app classes via `LoggerClassMixin`

## Build and Test

- This package is **pure Dart**; use `dart pub get`, `dart analyze`, and `dart test` by default.
- Do not use Flutter commands in this repository, except when documenting consumer integration.
- Tests:
  - full suite: `dart test`
  - single file: `dart test test/logger_json_list_test.dart`
  - single test by name: `dart test test/logger_json_list_test.dart -n "keeps the newest entries first and trims when capacity is exceeded"`
- Static analysis: `dart analyze`.
- Code generation (required after `@JsonSerializable` changes):
  - `dart run build_runner build`
  - or `./ci.sh -build`
- Dependency upgrade: `./ci.sh -upgrade`.

## Conventions

- When adding a new log type:
  1) extend `LoggerObjectBase`
  2) add `@JsonSerializable` + generated `part`
  3) implement `getColor()`, `fromJson()`, `toJson()`
  4) add an `EnumLoggerType` value, map it in `logger_enum.dart`, and register deserialization in `logger_json_list_type.dart` (`_typeConstructors` + `fromString`)
  5) export in `lib/log_custom_printer.dart`
  6) run `build_runner`
- Avoid loose `print` outside printer strategies.
- In tests involving DI/logging, register printer in `setUp` and call `GetIt.instance.reset()` in `tearDown`.
- In cache/file tests, prefer `Directory.systemTemp.createTemp(...)` or dedicated temp dirs and remove them in `tearDown`/`tearDownAll`.
- `registerLogPrinterColor` and `registerLogPrinterSimple` accept `config`, `maxLogsInCache`, and optional `cacheFilePath`; they do not accept a file-type parameter.
- `LoggerPersistenceService.queryLogs` applies `LogQuery` filters and sorting; date ranges use an inclusive start and exclusive end.
- `FileManager.writeFile` accepts an optional `FileMode` and serializes operations per path.
- Keep documentation and examples synchronized with the public exports and SDK constraint in `pubspec.yaml` (`>=3.13.0 <4.0.0`).

## Documentation language

- Write and update all project documentation in **English** (README, docs, API docs, and AI instructions).

## Reference Docs (link, don’t embed)

- Overview/setup: `README.md`, history: `CHANGELOG.md`
- Core and DI: `doc/Core.md`
- Log types: `doc/LogTypes.md`
- Printer strategies: `doc/Printers.md`
- Configuration/filters: `doc/Configuration.md`
- Utilities/cache: `doc/Utilities.md`
- Expanded docs: `doc/DOCUMENTATION.md`
- Flutter console migration (separate package): `doc/ConsoleView.md`
