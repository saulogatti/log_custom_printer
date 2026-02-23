# Utilitários

Este módulo reúne as ferramentas auxiliares da biblioteca: mixin de integração, enums,
helpers de formatação, extensões e o sistema de cache de logs.

---

## LoggerClassMixin

Mixin que fornece métodos de log prontos para uso em qualquer classe Dart/Flutter.
Preenche automaticamente `className` com o `runtimeType` da classe hospedeira.

```dart
mixin LoggerClassMixin {
  Type get logClassType => runtimeType;

  void logDebug(String message);
  void logInfo(String message);
  void logWarning(String message);
  void logError(String message, StackTrace stackTrace);
}
```

**Exemplo de uso:**

```dart
class MinhaClasse with LoggerClassMixin {
  void processarDados() {
    logDebug('Iniciando processamento');

    try {
      // lógica de processamento
      logInfo('Processamento concluído com sucesso');
    } catch (error, stackTrace) {
      logError('Falha no processamento: $error', stackTrace);
    }
  }
}
```

Cada método cria o objeto de log correspondente e chama `sendLog()` internamente.
Não é necessário criar os objetos de log manualmente.

---

## EnumLoggerType

Enum que representa os tipos de severidade de log disponíveis.

```dart
enum EnumLoggerType {
  error,
  debug,
  warning,
  info,
}
```

Usado principalmente pelo sistema de cache para organizar logs por tipo:

```dart
// Recuperar apenas logs de erro
final erros = await cacheRepository.getLogsByType(EnumLoggerType.error);

// Limpar apenas logs de debug
await cacheRepository.clearLogsByType(EnumLoggerType.debug);
```

---

## LoggerJsonList

Container serializável que armazena uma lista de objetos de log de um único tipo,
mantendo um limite configurável de entradas.

```dart
@JsonSerializable(createFactory: false)
class LoggerJsonList {
  String type;
  int maxLogEntries; // padrão: 100
  List<LoggerObjectBase> get loggerEntries;

  void addLogger(LoggerObjectBase logger);
  factory LoggerJsonList.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

**Comportamento de inserção:**
- Novos logs são inseridos no início da lista (`índice 0`), mantendo ordem **mais recente → mais antigo**.
- Ao atingir `maxLogEntries`, o log mais antigo (último) é descartado automaticamente.

**Tipos suportados para desserialização:** `DebugLog`, `InfoLog`, `WarningLog`, `ErrorLog`.

---

## EnumAnsiColors e LoggerAnsiColor

Utilitários para aplicação de cores ANSI em mensagens de texto no terminal.

### EnumAnsiColors

```dart
enum EnumAnsiColors {
  black, red, green, yellow,
  blue, magenta, cyan, white;

  int getBgColor(); // Código ANSI de fundo
  int getFgColor(); // Código ANSI de texto
}
```

### LoggerAnsiColor

```dart
@JsonSerializable()
class LoggerAnsiColor {
  final EnumAnsiColors enumAnsiColors;

  const LoggerAnsiColor({required this.enumAnsiColors});

  // Aplica a cor à mensagem: retorna '\x1B[CODIGOm mensagem \x1B[0m'
  String call(String msg);

  factory LoggerAnsiColor.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

**Exemplo de uso:**

```dart
final cor = LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.red);
print(cor('Mensagem em vermelho'));
```

Usado internamente pelos tipos de log em `getColor()` e pelas impressoras para formatação visual.

---

## DateTimeLogHelper

Extension em `DateTime` para formatação de timestamps nos logs.

```dart
extension DateTimeLogHelper on DateTime {
  String get logFullDateTime; // "dd/MM/yyyy HH:mm:ss.SSS"
  String onlyDate();          // "dd/MM/yyyy"
  String onlyTime();          // "HH:mm:ss.SSS"
}
```

**Exemplo:**

```dart
final agora = DateTime.now();
print(agora.logFullDateTime); // "23/02/2026 11:02:32.399"
print(agora.onlyDate());      // "23/02/2026"
print(agora.onlyTime());      // "11:02:32.399"
```

Usado por `LoggerObjectBase.getMessage()` para formatar o timestamp da mensagem.

---

## StackTraceSdk

Extension em `StackTrace` para formatação e filtragem de stack traces.
Remove automaticamente linhas de framework interno (Flutter, Dart SDK) para exibir
apenas o código da aplicação.

```dart
extension StackTraceSdk on StackTrace {
  // Formata com cor opcional, limitando o número de linhas
  String formatStackTrace(LoggerAnsiColor? color, int linesCount);

  // Converte para Map<String, String> com chaves '#0', '#1', etc.
  Map<String, dynamic> stackInMap([int linesCount = 8]);
}
```

**Exemplo:**

```dart
try {
  // código que pode falhar
} catch (error, stackTrace) {
  final mapa = stackTrace.stackInMap(5);
  // {'#0': 'MinhaClasse.meuMetodo (...:42:5)', '#1': ..., ...}
}
```

Usado por `ErrorLog.getMessage()` para incluir o stack trace formatado na saída.

---

## LoggerCacheRepository

Interface que define as operações de cache de logs. Implemente esta interface para
customizar o armazenamento (ex: banco de dados local, `SharedPreferences`, servidor remoto).

```dart
abstract interface class LoggerCacheRepository {
  Future<void> addLog(LoggerObjectBase log);
  Future<void> clearLogs();
  Future<void> clearLogsByType(EnumLoggerType type);
  Future<List<LoggerObjectBase>> getAllLogs();
  Future<List<LoggerObjectBase>> getLogsByType(EnumLoggerType type);
}
```

O repositório é retornado pelas funções `registerLogPrinter*` e pode ser usado para
consultar e gerenciar os logs coletados em runtime.

**Exemplo de uso do repositório:**

```dart
final cache = registerLogPrinterColor(config: ConfigLog(enableLog: true));

// Recuperar todos os logs
final todos = await cache.getAllLogs();

// Recuperar apenas erros
final erros = await cache.getLogsByType(EnumLoggerType.error);

// Limpar todos os logs
await cache.clearLogs();
```

---

## LoggerCacheImpl

Implementação padrão de `LoggerCacheRepository`. Armazena logs em memória usando
`LoggerJsonList` e, opcionalmente, persiste em disco via `LoggerCache`.

```dart
final class LoggerCacheImpl implements LoggerCacheRepository {
  final int maxLogEntries;    // padrão: 1000
  final String? saveLogFilePath; // se fornecido, persiste em disco
}
```

- Logs em memória são organizados por `EnumLoggerType`.
- Se `saveLogFilePath` for fornecido, os logs são gravados em arquivos JSON em
  `<saveLogFilePath>/loggerApp/logs/<tipo>.json`.
- Na inicialização com caminho de arquivo, carrega os logs previamente persistidos.

---

## LoggerCache

Gerenciador de baixo nível para persistência de arquivos de log em disco.

```dart
class LoggerCache {
  LoggerCache(String directory);

  Future<void> get futureInitialization;

  Future<void> writeLogToFile(String fileName, Object loggerList);
  Future<Map<EnumLoggerType, LoggerJsonList?>?> readAllLogs();
  Future<void> clearAll();
  Future<void> clearLogByType(String name);
}
```

Os arquivos são criados em `<directory>/loggerApp/logs/<tipo>.json`.
Usado internamente por `LoggerCacheImpl`; normalmente não é necessário interagir
diretamente com esta classe.
