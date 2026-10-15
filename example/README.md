# log_custom_printer example

Flutter app that uses [`log_custom_printer`](../README.md) from a path dependency. Each tap on the increment button emits a debug, warning, info, and error log from a class that mixes in `LoggerClassMixin`.

The library itself is pure Dart. This app exists only to show registration, colored console output, file cache, and `logStream` inside a Flutter startup.

## What it shows

- `registerLogPrinterColor` with `ConfigLog(enableLog: true)`
- JSON cache files under the application support directory
- `LoggerClassMixin` (`logDebug`, `logWarning`, `logInfo`, `logError`)
- `LoggerPersistenceService.logStream` for logs that were accepted and stored

`ErrorLog` still prints when `enableLog` is `false`. This sample turns logging on so all four types appear.

## Run

From this directory:

```sh
flutter pub get
flutter run
```

The package is linked with `path: ../` in `pubspec.yaml`, so the parent package does not need to be published.

## Flow

`MyHomePage` registers the printer in `initState`:

```dart
final directory = await getApplicationSupportDirectory();
logPrinterService = registerLogPrinterColor(
  config: const ConfigLog(enableLog: true),
  cacheFilePath: directory.path,
);
```

Call a `registerLogPrinter*` function before emitting logs. `cacheFilePath` is the application support directory from `path_provider`. The cache writes JSON under `<that directory>/loggerApp/logs/`.

`CounterWidget` uses the mixin. Setting `counter` sends one log of each type and stamps `className` with `CounterWidget`:

```dart
class CounterWidget with LoggerClassMixin {
  set counter(int value) {
    logDebug('LogDebug: counter set to $value');
    logWarning('LogWarning: counter set to $value');
    logInfo('LogInfo: counter set to $value');
    logError('LogError: counter set to $value', StackTrace.current);
    _counter = value;
  }
}
```

The floating action button increments `counter`. `LogWithColorPrint` writes ANSI-colored lines to the console. The same entries are appended to the cache and pushed on `logStream`. In debug mode the sample prints each accepted message:

```dart
logPrinterService.logStream.listen((log) {
  if (kDebugMode) {
    print('Received log: ${log.getMessage()}');
  }
});
```

Registration is asynchronous. A tap that happens before `_initLogger` finishes is handled by the library fallback printer, which does not use this cache path. Wait until the app is on screen, then tap.

## Further reading

Library overview, filters, and cache queries: [../README.md](../README.md).
