# Consola visual Flutter (v3) — *breaking change* e integração

A partir da **3.0.0** do `log_custom_printer`, a interface de consola (overlay, widgets, BLoC, repositórios de mensagens) **não faz parte** deste pacote. A biblioteca passou a ser **Dart pura**; a consola gráfica deverá ser consumida por um **pacote Flutter separado** (publicado no pub.dev ou via `git` / `path`).

Este documento descreve o que mudou e como integrar de forma geral, sem acoplar a nomes concretos de API do pacote extraído — atualize os imports e classes conforme o README desse pacote quando estiver disponível.

## O que deixou de existir no `log_custom_printer`

- Módulo `console_view` e ficheiros sob `lib/.../console_view/...`
- `ConsoleOverlayManager`, `ConsoleView`, `ConsoleProvider`, BLoCs e repositórios de consola
- `initAppInjection` e `application_injection` deste repositório
- Imports do tipo:
  - `package:log_custom_printer/src/console_view/...`

Se o teu app ainda referencia estes símbolos, o build falha até migrares.

## O que permanece no `log_custom_printer`

- Registo de impressão: `registerLogPrinter`, `registerLogPrinterColor`, `registerLogPrinterSimple`
- `LoggerPersistenceService` e `ILoggerCacheRepository` — a consola Flutter (no pacote novo) continua a basear-se nos **mesmos** tipos de log e, em geral, no **mesmo** serviço de cache exposto após o registo
- Modelos de domínio de **log** (`DebugLog`, `InfoLog`, etc.) inalterados na API pública

## Passos de migração (resumo)

1. **Adiciona** o pacote da consola às `dependencies` do teu app Flutter (nome e versão indicados na documentação desse pacote).
2. **Remove** imports antigos de `log_custom_printer` que apontavam para `src/console_view`.
3. **Substitui** as chamadas de API (`ConsoleOverlayManager`, `initAppInjection`, etc.) pelas expostas pelo **novo** pacote.
4. Garante que, no `main`, **`registerLogPrinter*`** do `log_custom_printer` continua a ser chamado **antes** de abrir a consola ou de emitir logs, tal como na v2.
5. Passa ao pacote da consola as instâncias que ele exige (em geral o **repositório de cache** / `ILoggerCacheRepository` retornado ou injetado após o registo) — o contrato exato fica no README do pacote extraído.

## Categoria "Console View" no `dart doc`

O ficheiro [dartdoc_options.yaml](../dartdoc_options.yaml) inclui a categoria **Console View** com referência a este guia. Essa categoria **não** documenta classes exportadas por `log_custom_printer.dart`; serve para orientar a integração opcional com a consola noutro pacote.

## Referências

- [README.md](../README.md) — visão geral da v3
- [CHANGELOG.md](../CHANGELOG.md) — notas de versão
- [DOCUMENTATION.md](DOCUMENTATION.md) — arquitetura do núcleo de logging
