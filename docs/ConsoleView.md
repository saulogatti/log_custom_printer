# Flutter Visual Console (v3) — breaking change and integration

Starting in **3.0.0**, the console UI (overlay, widgets, BLoC, message repositories) is **not part** of `log_custom_printer` anymore.
The package is now **pure Dart**. Visual console support must come from a **separate Flutter package**.

## What was removed from `log_custom_printer`

- `console_view` module and files under `lib/.../console_view/...`
- `ConsoleOverlayManager`, `ConsoleView`, `ConsoleProvider`, related BLoCs/repositories
- `initAppInjection` and `application_injection` from this repository
- Imports such as `package:log_custom_printer/src/console_view/...`

## What remains in `log_custom_printer`

- Printer registration: `registerLogPrinter`, `registerLogPrinterColor`, `registerLogPrinterSimple`
- `LoggerPersistenceService` and `ILoggerCacheRepository`
- Public log domain models (`DebugLog`, `InfoLog`, `WarningLog`, `ErrorLog`)

## Migration steps (summary)

1. Add the visual console package to your Flutter app dependencies.
2. Remove old `log_custom_printer` imports pointing to `src/console_view`.
3. Replace old APIs (`ConsoleOverlayManager`, `initAppInjection`, etc.) with the new package APIs.
4. Keep calling `registerLogPrinter*` before opening the console or emitting logs.
5. Pass required cache/service instances to the visual package as documented by that package.

## "Console View" category in `dart doc`

[dartdoc_options.yaml](../dartdoc_options.yaml) includes a **Console View** category that points to this guide.
It does not document exported classes from `log_custom_printer.dart`; it exists only to guide optional integration.

## References

- [README.md](../README.md)
- [CHANGELOG.md](../CHANGELOG.md)
- [DOCUMENTATION.md](DOCUMENTATION.md)
