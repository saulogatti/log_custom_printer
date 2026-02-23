# Core — Sistema de Logging

Este módulo define os tipos fundamentais e a infraestrutura de injeção de dependência da biblioteca.

---

## LoggerObject

Classe selada (*sealed*) que serve como marcador base da hierarquia de tipos de log.

```dart
sealed class LoggerObject {}
```

Não possui membros próprios. Sua existência garante que apenas os tipos definidos nesta biblioteca
(`DebugLog`, `InfoLog`, `WarningLog`, `ErrorLog`) possam estender a hierarquia, permitindo
*pattern matching* exhaustivo em *switch* expressions.

---

## LoggerObjectBase

Classe abstrata que define o contrato completo para objetos de log.

```dart
abstract class LoggerObjectBase extends LoggerObject {
  final String message;
  final String tag;
  DateTime logCreationDate;
  late String className;
}
```

### Campos principais

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `message` | `String` | Mensagem principal do log |
| `tag` | `String` | Tag opcional para categorização |
| `logCreationDate` | `DateTime` | Timestamp de criação (padrão: `DateTime.now()`) |
| `className` | `String` | Nome da classe/origem que emitiu o log |

### Métodos

- **`getColor()`** — Retorna a cor ANSI do tipo de log. Implementado por cada subclasse.
- **`getMessage([bool withColor])`** — Retorna a mensagem formatada com timestamp, com ou sem cor ANSI.
- **`getStartLog([bool withColor])`** — Retorna o cabeçalho do log (tipo + origem) formatado.
- **`sendLog()`** — Envia o log ao `LogPrinterService` registrado via `get_it`.
- **`toJson()`** — Serializa o objeto para JSON.
- **`alwaysPrint`** — Propriedade `bool` que, quando `true`, faz o log ser processado mesmo com `ConfigLog.enableLog = false`. Padrão: `false`. `ErrorLog` sobrescreve para `true`.

### Validações

O construtor valida em modo de desenvolvimento via `assert` que a mensagem não está vazia nem contém apenas espaços em branco.

---

## LogPrinterService

Serviço central que coordena a impressão e o armazenamento de logs.

```dart
final class LogPrinterService {
  final LogPrinterBase logPrinter;
  LoggerCacheRepository get cacheRepository;

  void executePrint(LoggerObjectBase log);
}
```

Este serviço é registrado como *singleton* no `get_it` por `registerLogPrinter`. Ele aplica as regras de `ConfigLog`
e, quando um log deve ser processado, delega para `logPrinter.printLog()` e `cacheRepository.addLog()`.

**Regras de processamento em `executePrint`:**
1. Se `enableLog` é `true` **e** o tipo do log está em `onlyClasses` (ou `onlyClasses` está vazio) → imprime e salva no cache.
2. Se `log.alwaysPrint` é `true` → imprime e salva no cache independentemente das regras acima.
3. Caso contrário → o log é descartado silenciosamente.

---

## fetchLogPrinterService

Função interna que resolve o `LogPrinterService` registrado no `get_it`.

```dart
LogPrinterService fetchLogPrinterService();
```

Lança `StateError` se `registerLogPrinter` não tiver sido chamado antes do primeiro uso.

---

## registerLogPrinter

Registra a impressora principal no `get_it`. Deve ser chamada no *startup* da aplicação,
antes de qualquer uso de logs.

```dart
LoggerCacheRepository registerLogPrinter(
  LogPrinterBase printer, {
  LoggerCacheRepository? cacheRepository,
});
```

Retorna o `LoggerCacheRepository` associado ao serviço registrado, para que o chamador
possa consultar e gerenciar os logs em cache.

**Atalhos de registro:**

```dart
// Com formatação ANSI colorida (recomendado para desenvolvimento)
LoggerCacheRepository registerLogPrinterColor({
  ConfigLog? config,
  int maxLogsInCache = 100,
  String? cacheFilePath,
});

// Sem cores, usando debugPrint (útil em CI/CD ou consoles sem ANSI)
LoggerCacheRepository registerLogPrinterSimple({
  ConfigLog? config,
  int maxLogsInCache = 100,
  String? cacheFilePath,
});
```

### Exemplo de configuração no startup

```dart
void main() {
  // Desenvolvimento — logs coloridos, cache em memória
  final cache = registerLogPrinterColor(
    config: ConfigLog(enableLog: true),
  );

  // Produção — sem cores, apenas erros, cache com persistência em arquivo
  // final cache = registerLogPrinterSimple(
  //   config: ConfigLog(enableLog: false),
  //   cacheFilePath: '/caminho/para/logs',
  // );

  runApp(MyApp());
}
```

### Exemplo em testes

```dart
setUp(() {
  registerLogPrinter(
    LogSimplePrint(config: ConfigLog(enableLog: true)),
  );
});

tearDown(() async => await GetIt.instance.reset());
```
