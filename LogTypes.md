# Tipos de Log

Este módulo define os tipos concretos de log disponíveis na biblioteca. Todos estendem
`LoggerObjectBase` e fazem parte da hierarquia selada `LoggerObject`.

```
LoggerObject (sealed)
    └── LoggerObjectBase (abstract)
            ├── DebugLog    (amarelo)
            ├── InfoLog     (branco)
            ├── WarningLog  (verde)
            └── ErrorLog    (vermelho + stack trace)
```

Cada tipo define sua própria cor via `getColor()`, suporta serialização JSON via
`@JsonSerializable()` e pode ser criado diretamente ou via `LoggerClassMixin`.

---

## DebugLog

Log de depuração, exibido em **amarelo**.

Indicado para mensagens de desenvolvimento: valores de variáveis, fluxo de execução,
diagnósticos que não devem aparecer em produção.

```dart
@JsonSerializable()
class DebugLog extends LoggerObjectBase {
  DebugLog(super.message, {super.typeClass});

  factory DebugLog.fromJson(Map<String, dynamic> json);

  @override
  LoggerAnsiColor getColor(); // EnumAnsiColors.yellow

  @override
  Map<String, dynamic> toJson();
}
```

**Exemplo de uso direto:**

```dart
DebugLog('Valor de retorno: $resultado', typeClass: runtimeType).sendLog();
```

**Via mixin:**

```dart
class MinhaClasse with LoggerClassMixin {
  void processar() {
    logDebug('Iniciando processamento');
  }
}
```

---

## InfoLog

Log informativo, exibido em **branco**.

Indicado para registrar eventos relevantes do fluxo normal da aplicação: operações concluídas,
marcos de execução, mudanças de estado.

```dart
@JsonSerializable()
class InfoLog extends LoggerObjectBase {
  InfoLog(super.message, {super.typeClass});

  factory InfoLog.fromJson(Map<String, dynamic> json);

  @override
  LoggerAnsiColor getColor(); // EnumAnsiColors.white

  @override
  Map<String, dynamic> toJson();
}
```

**Exemplo de uso direto:**

```dart
InfoLog('Usuário autenticado com sucesso', typeClass: runtimeType).sendLog();
```

**Via mixin:**

```dart
class AuthService with LoggerClassMixin {
  void login() {
    logInfo('Login realizado');
  }
}
```

---

## WarningLog

Log de aviso, exibido em **verde**.

Indicado para situações que merecem atenção mas não impedem o funcionamento da aplicação:
uso elevado de recursos, comportamento inesperado não crítico, deprecações.

```dart
@JsonSerializable()
class WarningLog extends LoggerObjectBase {
  WarningLog(super.message, {super.typeClass});

  factory WarningLog.fromJson(Map<String, dynamic> json);

  @override
  LoggerAnsiColor getColor(); // EnumAnsiColors.green

  @override
  Map<String, dynamic> toJson();
}
```

**Exemplo de uso direto:**

```dart
WarningLog('Cache próximo do limite: ${usado}/${limite}', typeClass: runtimeType).sendLog();
```

**Via mixin:**

```dart
class CacheService with LoggerClassMixin {
  void verificar(int usado, int limite) {
    if (usado > limite * 0.8) {
      logWarning('Cache acima de 80% da capacidade');
    }
  }
}
```

---

## ErrorLog

Log de erro, exibido em **vermelho**. Inclui o `stackTrace` associado ao erro.

Este é o único tipo com `alwaysPrint = true`, o que significa que ele **sempre é processado**
independentemente de `ConfigLog.enableLog` ou `ConfigLog.onlyClasses`. Isso garante que erros
críticos sejam sempre registrados em produção.

```dart
@JsonSerializable()
class ErrorLog extends LoggerObjectBase {
  @StackTraceConverter()
  final StackTrace stackTrace;

  ErrorLog(super.message, this.stackTrace, {super.typeClass});

  @override
  bool get alwaysPrint => true; // Sempre processado

  factory ErrorLog.fromJson(Map<String, dynamic> json);

  @override
  LoggerAnsiColor getColor(); // EnumAnsiColors.red

  @override
  String getMessage([bool withColor]);

  @override
  Map<String, dynamic> toJson();
}
```

O método `getMessage` do `ErrorLog` também inclui as linhas do stack trace na saída,
formatadas e coloridas, facilitando a depuração diretamente no console.

**Exemplo de uso direto:**

```dart
try {
  await processarDados();
} catch (e, st) {
  ErrorLog('Falha ao processar dados: $e', st, typeClass: runtimeType).sendLog();
}
```

**Via mixin:**

```dart
class DataService with LoggerClassMixin {
  Future<void> carregar() async {
    try {
      // operação arriscada
    } catch (e, st) {
      logError('Erro ao carregar: $e', st);
    }
  }
}
```

### Serialização JSON

Todos os tipos de log suportam serialização e desserialização JSON:

```dart
// Serializar
final log = DebugLog('Mensagem de teste');
final json = log.toJson();

// Desserializar
final logRecuperado = DebugLog.fromJson(json);
```

`StackTrace` em `ErrorLog` é serializado como `String` via `StackTraceConverter`.
