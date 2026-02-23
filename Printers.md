# Impressoras de Log

Este módulo implementa o padrão *Strategy* para a saída de logs. Cada impressora define
como os logs serão formatados e enviados para o destino final (console, terminal, etc.).

---

## LogPrinterBase

Classe abstrata que define o contrato para todas as impressoras de log.

```dart
abstract class LogPrinterBase {
  final ConfigLog configLog;

  const LogPrinterBase({ConfigLog? config});

  void printLog(LoggerObjectBase log);
}
```

Para criar uma impressora customizada, estenda `LogPrinterBase` e implemente `printLog`:

```dart
class MinhaImpressora extends LogPrinterBase {
  const MinhaImpressora({super.config});

  @override
  void printLog(LoggerObjectBase log) {
    // Enviar para um serviço remoto, banco de dados, etc.
    myRemoteService.send(log.toJson());
  }
}
```

Registre-a no startup:

```dart
void main() {
  registerLogPrinter(
    MinhaImpressora(config: ConfigLog(enableLog: true)),
  );
  runApp(MyApp());
}
```

---

## LogSimplePrint

Impressora simples sem formatação colorida. Usa `print()` para escrever a saída.

```dart
class LogSimplePrint extends LogPrinterBase {
  const LogSimplePrint({super.config});

  @override
  void printLog(LoggerObjectBase log);
}
```

**Formato de saída:**

```
[NomeDaClasse] dd/MM/yyyy HH:mm:ss.SSS Mensagem do log
```

**Quando usar:**
- Ambientes sem suporte a ANSI (terminais básicos, CI/CD, serviços de log externos)
- Testes automatizados onde a leitura precisa ser limpa
- Produção com logs em arquivo

**Exemplo:**

```dart
registerLogPrinter(
  LogSimplePrint(
    config: ConfigLog(
      enableLog: true,
      onlyClasses: {DebugLog, ErrorLog},
    ),
  ),
);
```

Atalho equivalente:

```dart
registerLogPrinterSimple(
  config: ConfigLog(enableLog: true),
);
```

---

## LogWithColorPrint

Impressora avançada com formatação colorida usando códigos ANSI. Usa `dart:developer.log()`
para enviar blocos formatados.

```dart
class LogWithColorPrint extends LogPrinterBase {
  const LogWithColorPrint({super.config});

  @override
  void printLog(LoggerObjectBase log);
}
```

**Formato de saída:**

```
 
=-=-=-=-=-=-=-=-=-=-=--==-=-=-=-=-=-=-=-=-=-=-=-=-=-   ← separador colorido
dd/MM/yyyy HH:mm:ss.SSS Mensagem do log               ← mensagem com cor
=-=-=-=-=-=-=-=-=-=-=--==-=-=-=-=-=-=-=-=-=-=-=-=-=-   ← separador colorido
```

O `name` do log enviado ao `dart:developer.log` é a `className` em maiúsculas com a cor
do tipo de log, facilitando a filtragem por origem em IDEs e visualizadores de log.

**Quando usar:**
- Desenvolvimento local (IDEs como VS Code e Android Studio preservam ANSI)
- Depuração visual com diferenciação por cores
- Ambientes que suportam `dart:developer`

**Exemplo:**

```dart
registerLogPrinter(
  LogWithColorPrint(
    config: ConfigLog(enableLog: true),
  ),
);
```

Atalho equivalente:

```dart
registerLogPrinterColor(
  config: ConfigLog(enableLog: true),
  maxLogsInCache: 200,
);
```

---

## Comparativo

| Impressora | Saída | ANSI | Uso recomendado |
|------------|-------|------|-----------------|
| `LogSimplePrint` | `print()` | ❌ | Testes, CI/CD, produção |
| `LogWithColorPrint` | `dart:developer.log()` | ✅ | Desenvolvimento local |
