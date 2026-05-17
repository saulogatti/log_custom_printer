# log_custom_printer

Biblioteca Dart para logging customizado com serialização JSON, formatação colorida ANSI e injeção de dependência (`get_it`). Adequada para CLI, servidores e scripts; também utilizável em apps Flutter após registar a impressora no arranque.

> **v3.0.0** — Biblioteca **Dart pura** (sem dependência de Flutter). A API de registro (`registerLogPrinter`, `registerLogPrinterColor`, `registerLogPrinterSimple`) continua a devolver `LoggerPersistenceService` com cache integrado. O **console visual Flutter** deixou de fazer parte deste pacote; ver [docs/ConsoleView.md](docs/ConsoleView.md).

## Funcionalidades

- **Hierarquia de logs tipada**: `DebugLog`, `InfoLog`, `WarningLog`, `ErrorLog`
- **Formatação colorida**: códigos ANSI no terminal
- **Serialização JSON**: com `json_serializable`
- **Configuração flexível**: filtragem por tipos e habilitação
- **Cache**: memória e persistência opcional em ficheiro JSON
- **I/O seguro em concorrência**: serialização por caminho no `FileManager`
- **Injeção de dependência**: `registerLogPrinter`, `registerLogPrinterColor`, `registerLogPrinterSimple`
- **Mixin**: `LoggerClassMixin` para integração em classes
- **Rastreabilidade**: origem via `className` / `runtimeType`

## Instalação

Adicione no `pubspec.yaml`:

```yaml
dependencies:
  log_custom_printer:
    git:
      url: https://github.com/saulogatti/log_custom_printer.git
    # ou path local:
    # path: ../log_custom_printer
```

```bash
dart pub get
```

**Requisitos:** Dart SDK ^3.11.0

## Uso básico

### Configuração inicial (obrigatório antes de emitir logs)

```dart
import 'package:log_custom_printer/log_custom_printer.dart';

void main() {
  final persistenceService = registerLogPrinterColor(
    config: ConfigLog(enableLog: true),
    maxLogsInCache: 100,
    cacheFilePath: '/caminho/para/salvar/logs', // opcional
  );

  // Em Flutter: runApp(const MyApp());
}
```

### Sistema de cache

`registerLogPrinterColor` e `registerLogPrinterSimple` devolvem um `LoggerPersistenceService` para leitura, consulta e limpeza. Com `cacheFilePath`, o `FileManager` serializa escrita por caminho para evitar condições de corrida.

```dart
final allLogs = await persistenceService.getAllLogs();
final errorLogs = await persistenceService.getLogsByType(EnumLoggerType.error);
await persistenceService.clearLogs();
await persistenceService.clearLogsByType(EnumLoggerType.debug);
```

Para armazenamento personalizado, implemente `ILoggerCacheRepository` e passe em `registerLogPrinter(printer, cacheRepository: ..., config: ...)`.

### Mixin (recomendado)

```dart
class MinhaClasse with LoggerClassMixin {
  void minhaFuncao() {
    logDebug('Iniciando função');
    logInfo('Processando dados...');
    try {
      logInfo('Sucesso');
    } catch (error, stackTrace) {
      logError('Erro: $error', stackTrace);
    }
  }
}
```

### Objetos de log e JSON

```dart
final debugLog = DebugLog('Mensagem de debug', typeClass: runtimeType);
debugLog.sendLog();

final errorLog = ErrorLog('Falha', StackTrace.current, typeClass: runtimeType);
errorLog.sendLog();

final json = debugLog.toJson();
final restaurado = DebugLog.fromJson(json);
```

### Configuração avançada

```dart
void main() {
  registerLogPrinterColor(
    config: ConfigLog(
      enableLog: true,
      onlyClasses: {DebugLog, ErrorLog},
    ),
  );
  // Em Flutter: runApp(const MyApp());
}
```

### Regras de entrega

- `ConfigLog.enableLog == false`: descarta a maioria dos logs; `ErrorLog` continua via `alwaysPrint`.
- `ConfigLog.onlyClasses`: se não vazio, só tipos listados são aceites.
- `LoggerClassMixin`: preenche `className` com o `runtimeType` da classe emissora.
- Repositório de cache: mantém até `maxLogEntries` por tipo (comportamento conforme implementação do repositório).

## Arquitetura (resumo)

- **`LoggerObject`** / **`LoggerObjectBase`** — hierarquia e envio de logs
- **`LogPrinterService`** — impressão e cache (via `get_it`)
- **`registerLogPrinter`** / **`registerLogPrinterColor`** / **`registerLogPrinterSimple`**
- **`ConfigLog`** — filtros e `enableLog`
- **`LoggerPersistenceService`** — consulta ao cache após registo
- **`ILoggerCacheRepository`** — persistência customizável

### Tipos de log

| Tipo | Cor ANSI | Uso |
|------|----------|-----|
| `DebugLog` | Amarelo | Depuração |
| `InfoLog` | Branco | Informação |
| `WarningLog` | Verde | Avisos |
| `ErrorLog` | Vermelho | Erros (`alwaysPrint`) |

### Impressoras

- **`LogSimplePrint`** — saída simples (sem cores ANSI na estratégia padrão)
- **`LogWithColorPrint`** — saída com cores ANSI

Atalhos: `registerLogPrinterColor` / `registerLogPrinterSimple`; impressora própria: `registerLogPrinter(LogPrinterBase(), config: ...)`.

### Console visual (Flutter)

A UI de consola em tempo real **não está neste repositório** na v3. Para migrar a partir da v2 ou integrar um pacote à parte, consulte [docs/ConsoleView.md](docs/ConsoleView.md).

## Desenvolvimento

```bash
dart pub get
dart run build_runner build --delete-conflicting-outputs
# ou: ./ci.sh -build
```

```bash
dart analyze
dart test
dart doc
```

A documentação API gerada por omissão fica em `doc/api`. Não utilize o diretório `docs/` como saída do `dart doc` — essa pasta contém guias em Markdown do projeto.

### Novos tipos de log

1. Estender `LoggerObjectBase`
2. `@JsonSerializable()` e `part` gerado
3. `getColor()`, `fromJson`, `toJson`
4. Registar em `logger_json_list.dart` se aplicável ao projeto
5. Exportar na API pública e correr `build_runner`

## Documentação

| Ficheiro | Conteúdo |
|----------|----------|
| [README.md](README.md) | Visão geral (esta página) |
| [CHANGELOG.md](CHANGELOG.md) | Histórico de versões |
| [docs/Core.md](docs/Core.md) | Núcleo e injeção de dependência |
| [docs/LogTypes.md](docs/LogTypes.md) | Tipos de log |
| [docs/Printers.md](docs/Printers.md) | Estratégias de impressão |
| [docs/Configuration.md](docs/Configuration.md) | Configuração e filtros |
| [docs/Utilities.md](docs/Utilities.md) | Utilitários e cache |
| [docs/ConsoleView.md](docs/ConsoleView.md) | Migração / consola Flutter à parte |
| [docs/DOCUMENTATION.md](docs/DOCUMENTATION.md) | Arquitetura expandida |

## Contribuições

1. Manter a API pública estável
2. Registar alterações relevantes no `CHANGELOG.md`
3. Correr testes antes de PRs
4. Seguir [Effective Dart](https://dart.dev/guides/language/effective-dart)

## Licença

Termos no ficheiro `LICENSE` do repositório.
