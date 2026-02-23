# Copilot Instructions for `log_custom_printer`

## Visão Geral
Biblioteca Dart/Flutter para logging estruturado com serialização JSON, formatação colorida ANSI e arquitetura baseada em injeção de dependência (get_it) e Strategy. O sistema usa sealed classes para hierarquia de logs tipada, garantindo type-safety em compile-time.

## Arquitetura Core

### Hierarquia de Logs (Sealed Class Pattern)
- **Base selada**: `LoggerObject` (marker class) → `LoggerObjectBase` (abstract contract)
- **Implementações**: `DebugLog` (yellow), `InfoLog` (white), `WarningLog` (green), `ErrorLog` (red)
- Cada tipo implementa: `getColor()`, `getMessage([withColor])`, `toJson()`, `fromJson()`
- **Localização**: `lib/src/logs_object/` - um arquivo por tipo + gerados `.g.dart`

### Sistema de Configuração (DI via get_it)
- **`registerLogPrinter(LogPrinterBase)`**: Registra a impressora no get_it (obrigatório no startup)
- **`registerLogPrinterColor()` / `registerLogPrinterSimple()`**: Atalhos para configuração comum
- **`ConfigLog`**: Controla `enableLog` (padrão `kDebugMode`), `onlyClasses` (filtragem de tipos) e `isSaveLogFile` (se os logs devem ser salvos em disco via `LogDisplayHandler`)
- **ErrorLog sempre processado**: Mesmo com `enableLog: false`, erros são registrados (via `alwaysPrint`)

### Printers (Strategy Pattern)
- **Interface**: `LogPrinterBase` com `printLog(LoggerObjectBase)` e `canPrintLog(LoggerObjectBase)`
- **`LogSimplePrint`**: Usa `debugPrint()` sem ANSI, formato `[ClassName] <timestamp> <message>`
- **`LogWithColorPrint`**: Usa `dart:developer.log()` com blocos separadores coloridos
- Filtragem via `ConfigLog.onlyClasses` aplicada em `canPrintLog()`

### Sistema de Cache (Feature)
- **`LoggerCache`** (singleton): Persiste logs em JSON no diretório de suporte da app (`loggerApp/logs/`)
- Operações: `addLogs()`, `getLogs()`, `clearLogs()`, `getLogResp()` (leitura de arquivo)
- Cache in-memory: `Map<String, List<String>>` por categoria
- Async init via `futureInit` - aguardar antes de operações de arquivo

## Workflows Críticos

### Code Generation (OBRIGATÓRIO)
```bash
dart run build_runner build --delete-conflicting-outputs
# Ou use task configurada no VS Code: "Dart Build Runner"
# Ou script: ./ci.sh -build
```
**Quando rodar**: Após criar/modificar qualquer classe com `@JsonSerializable()`. O `build.yaml` força `explicit_to_json: true`.

### Estrutura de Teste
- Testes em `test/`: Unit tests por componente + `data_logs/` com JSONs de exemplo
- Rodar: `dart test` (Dart puro) ou `flutter test` (com dependências Flutter)
- Padrão: `registerLogPrinter(fakePrinter)` no `setUp()` → testar comportamento → `GetIt.instance.reset()` no `tearDown()`

### Scripts de Automação (`ci.sh`)
- `./ci.sh -upgrade`: Atualiza dependências com `flutter pub upgrade --major-versions`
- `./ci.sh -build`: Executa build_runner em todos os `pubspec.yaml` (busca 2 níveis profundidade)
- Varredura automática: Encontra todos os projetos Dart/Flutter no workspace

## Convenções e Padrões Específicos

### Criação de Novo Tipo de Log
1. Crie arquivo em `lib/src/logs_object/<tipo>_log.dart`
2. Anote classe com `@JsonSerializable()`
3. Adicione `part '<tipo>_log.g.dart';`
4. Estenda `LoggerObjectBase` com construtor delegando para `super`
5. Implemente `getColor()` retornando `LoggerAnsiColor.<cor>`
6. Adicione factories: `fromJson(Map<String, dynamic>)` e override `toJson()`
7. **RODAR**: `dart run build_runner build --delete-conflicting-outputs`
8. Adicione ao export público em `lib/log_custom_printer.dart`

Exemplo:
```dart
@JsonSerializable()
class CustomLog extends LoggerObjectBase {
  const CustomLog(super.message, {super.typeClass, super.createdAt});
  
  @override
  LoggerAnsiColor getColor() => LoggerAnsiColor.blue;
  
  factory CustomLog.fromJson(Map<String, dynamic> json) => _$CustomLogFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$CustomLogToJson(this);
}
```

### Uso do Mixin `LoggerClassMixin`
```dart
class MinhaFeature with LoggerClassMixin {
  void processar() {
    logDebug('Iniciando');  // Injeta runtimeType automaticamente
    try {
      // lógica
      logInfo('Sucesso');
    } catch (e, st) {
      logError('Erro: $e', st);  // Stack trace opcional
    }
  }
}
```
**Métodos disponíveis**: `logDebug()`, `logInfo()`, `logWarning()`, `logError()` - todos capturam `runtimeType` via `logClassType`.

### Configuração de Filtragem (no startup, ex: main.dart)
```dart
void main() {
  // Apenas debug e info com cores
  registerLogPrinterColor(
    config: ConfigLog(onlyClasses: {DebugLog, InfoLog})
  );

  // Ou produção: apenas errors, sem cores
  registerLogPrinterSimple(
    config: ConfigLog(
      enableLog: false,  // ErrorLog ainda será processado
      onlyClasses: {ErrorLog}
    )
  );

  runApp(MyApp());
}
```

### Envio Manual de Logs
```dart
// Logs NÃO são enviados no construtor
final log = DebugLog('Minha mensagem', typeClass: runtimeType);
log.sendLog();  // Envio explícito necessário (usa get_it internamente)

// Ou via GetIt
GetIt.instance<LogPrinterBase>().printLog(DebugLog('Mensagem direta'));
```

## Integrações e Dependências

### JSON Serialization Pipeline
- `json_annotation` ^4.11.0 + `json_serializable` ^6.13.0 (dev)
- `build_runner` ^2.11.1 gerencia code generation
- Configuração: `build.yaml` força `explicit_to_json: true` para nested objects

### Flutter Framework
- `flutter/material.dart`: `debugPrint()`, `@mustCallSuper`, `kDebugMode`
- `dart:developer`: `log()` para output com ANSI preservado
- `path_provider` ^2.1.5: Diretório de suporte para cache de logs

### Utils Internos
- `LoggerAnsiColor`: Enum com transformadores de cor ANSI (via `call()` operator)
- `DateTimeLogHelper`: Extension em `DateTime` para `logFullDateTime` formatado
- `StackTraceExtensions`: Parsing e formatação de stack traces

## Validações e Restrições
- `assert()` valida mensagens não vazias/whitespace em desenvolvimento
- `ConfigLog.enableLog` desabilita logs **exceto ErrorLog** (sempre processado)
- Construtores são `const` quando possível (imutabilidade)
- `typeClass` opcional: fallback para `runtimeType` se omitido
- `registerLogPrinter()` deve ser chamado antes de qualquer uso de logs

## Estrutura de Arquivos Chave
```
lib/
  log_custom_printer.dart           # Export público da biblioteca
  src/
    config_log.dart                  # Configuração
    log_printer_locator.dart        # DI: registerLogPrinter, resolveLogPrinter
    log_custom_printer_base.dart    # LogPrinterBase (classe abstrata)
    logs_object/                     # Hierarquia sealed + gerados
      logger_object.dart             # Base abstrata
      debug_log.dart, *.g.dart       # Implementações
    log_printers/                    # Strategy pattern
      log_simple_print.dart          # Com/sem cores
    log_helpers/
      logger_class_mixin.dart        # Mixin utilitário
    cache/
      logger_cache.dart              # Persistência JSON
    utils/                           # Extensions e helpers
```

## Notas de Manutenção
- **Nunca edite arquivos `.g.dart`**: São gerados automaticamente
- **Tasks VS Code**: Use "Dart Build Runner" ao invés de comandos manuais
- **Testes de JSON**: `test/data_logs/` tem exemplos para validação de serialização
- **Padrão de Export**: Sempre re-exporte novos tipos no arquivo público principal