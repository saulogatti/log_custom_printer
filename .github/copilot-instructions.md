# Project Guidelines — `log_custom_printer`

## Code Style
- Siga `analysis_options.yaml` e `Effective Dart`.
- Preserve API pública estável em `lib/log_custom_printer.dart` (exports são parte do contrato).
- Não editar arquivos gerados (`*.g.dart`).

## Architecture
- Biblioteca de logging com:
  - hierarquia selada `LoggerObject` → `LoggerObjectBase` (`lib/src/domain/logs_object/`);
  - DI via `get_it` no `log_printer_locator.dart`;
  - Strategy para saída (`LogPrinterBase`, `LogSimplePrint`, `LogWithColorPrint`);
  - cache via `ILoggerCacheRepository` + `LoggerPersistenceService`.
- Regras críticas de domínio:
  - `registerLogPrinter*` deve ser chamado no startup antes de enviar logs;
  - `ErrorLog` sempre processa (`alwaysPrint`) mesmo com `ConfigLog(enableLog: false)`;
  - integração recomendada em classes de uso via `LoggerClassMixin`.

## Build and Test
- Dependências: `dart pub get` (ou `flutter pub get`).
- Testes: `dart test` (pacote Dart) e `flutter test` quando necessário.
- Análise estática: `dart analyze`.
- Geração de código (obrigatória após mudanças em `@JsonSerializable`):
  - `dart run build_runner build --delete-conflicting-outputs`
  - ou `./ci.sh -build`.
- Upgrade de dependências: `./ci.sh -upgrade`.

## Conventions
- Ao criar novo tipo de log:
  1) estender `LoggerObjectBase`,
  2) adicionar `@JsonSerializable` + `part` gerado,
  3) implementar `getColor()`, `fromJson()`, `toJson()`,
  4) registrar desserialização em `logger_json_list.dart` (`_typeConstructors`),
  5) exportar em `lib/log_custom_printer.dart`,
  6) rodar `build_runner`.
- Evite `print` solto fora das estratégias de impressão da biblioteca.
- Em testes que tocam DI/logging, registre impressora no `setUp` e faça `GetIt.instance.reset()` no `tearDown`.

## Reference Docs (link, don’t embed)
- Visão geral e setup: `README.md`, histórico: `CHANGELOG.md`
- Núcleo e DI: `docs/Core.md`
- Tipos de log: `docs/LogTypes.md`
- Estratégias de impressão: `docs/Printers.md`
- Configuração/filtros: `docs/Configuration.md`
- Utilitários e cache: `docs/Utilities.md`
- Documentação expandida: `docs/DOCUMENTATION.md`
- Migração consola Flutter (pacote à parte): `docs/ConsoleView.md`