# Project Guidelines — `log_custom_printer`

## Code Style
- Siga `analysis_options.yaml` e `Effective Dart`.
- Preserve API pública estável em `lib/log_custom_printer.dart`; qualquer mudança nos `export`s é mudança de contrato.
- Só adicione um novo `export` em `lib/log_custom_printer.dart` quando o tipo realmente fizer parte da API pública; caso contrário, mantenha-o interno em `lib/src/`.
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
- Este pacote é **Dart puro**; use `dart pub get`, `dart analyze` e `dart test` por padrão.
- Não use comandos Flutter neste repositório, exceto ao documentar integração em apps consumidores.
- Testes:
  - suíte completa: `dart test`
  - ficheiro único: `dart test test/logger_json_list_test.dart`\n  - teste único por nome: `dart test test/logger_json_list_test.dart -n "keeps the newest entries first and trims when capacity is exceeded"`
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
- Em testes que tocam cache/ficheiros, prefira `Directory.systemTemp.createTemp(...)` ou diretórios temporários dedicados e remova-os no `tearDown`/`tearDownAll`.

## Reference Docs (link, don’t embed)
- Visão geral e setup: `README.md`, histórico: `CHANGELOG.md`
- Núcleo e DI: `doc/Core.md`
- Tipos de log: `doc/LogTypes.md`
- Estratégias de impressão: `doc/Printers.md`
- Configuração/filtros: `doc/Configuration.md`
- Utilitários e cache: `doc/Utilities.md`
- Documentação expandida: `doc/DOCUMENTATION.md`
- Migração consola Flutter (pacote à parte): `doc/ConsoleView.md`
