# Changelog

## 3.1.2

- Fix: Rewrote documentation in English (English documentation).

## 3.1.1

- Fix: corrected log cache initialization so persisted logs are restored correctly.
- Refactor: updated library usage examples for clarity.
- Refactor: added the `mode` parameter to `writeFile`, allowing write mode selection such as `FileMode.write` or `FileMode.append`.

## 3.1.0

- Fix: corrected log path behavior in test environments to ensure proper file writes.
- Refactor: improved project structure for better maintainability.
- Refactor: updated documentation to reflect structural changes and usage guidance.
- Fix: small bug fixes and stability improvements.

## 3.0.2

- Fix: corrected log path behavior in test environments to ensure proper file writes.

## 3.0.1

- Fix: removed `path_provider` dependency (Flutter-specific). If no path is provided, file persistence is not used.

## 3.0.0

- **Breaking change:** removed the **Flutter** dependency and all **visual console** (`console_view`) modules. The package became **pure Dart** for CLI, server, and Flutter app usage (with startup registration). The overlay console is now delivered in a separate Flutter package (see `doc/ConsoleView.md`).
- Registration API remains (`registerLogPrinter`, `registerLogPrinterColor`, `registerLogPrinterSimple`); `registerLogPrinterColor` still uses `LogWithColorPrint` and `registerLogPrinterSimple` uses `LogSimplePrint`; custom printers remain supported via `registerLogPrinter` and `LogPrinterBase`.
- Documentation updates across API comments, `README`, guides in `doc/`, and `dart doc` alignment with v3.
- Generated docs improvements for `LoggerPersistenceService` constructor text and pure Dart examples.

## 2.2.0

- Added advanced log filters (type, date, and custom criteria) to improve analysis and organization.
- Refactor: updated project structure to support advanced filters in a modular way.
- Refactor: updated documentation with advanced filtering usage guidance.
- Fix: resolved bugs related to advanced filtering behavior and stability.

## 2.1.0

- Added a new console component for improved log visualization during development.
- Refactor: improved project structure and maintainability.
- Refactor: updated documentation for the new structure.
- Fix: minor bug fixes and stability improvements.

## 2.0.1

- Fix: corrected log path behavior in test environments.

## 2.0.0

- Refactor: removed project-specific file dependencies to improve generic reuse.
- Refactor: replaced `LogWithColorPrint` class usage pattern with color printer registration for improved strategy flexibility.
- Refactor: updated documentation to reflect printer strategy changes.
- Fix: adjusted log path behavior for test environments.
- Added custom printer options (including color mode).

## 1.1.0

- Refactor: removed `.flutter-plugins-dependencies` from version control and `.gitignore`.
- Fix: adjusted log path behavior for test environments.
- Added custom color printer support.

## 1.0.0

- Initial version.
