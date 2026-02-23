# Configuração

Este módulo contém as classes responsáveis por controlar o comportamento do sistema de logging.

---

## ConfigLog

Classe de configuração central do sistema de logging. Define quais logs devem ser processados e quais devem ser ignorados.

```dart
class ConfigLog {
  final bool enableLog;
  final Set<Type> onlyClasses;
}
```

### Parâmetros

| Campo | Tipo | Padrão | Descrição |
|-------|------|--------|-----------|
| `enableLog` | `bool` | `false` | Habilita ou desabilita o processamento de logs globalmente |
| `onlyClasses` | `Set<Type>` | `{DebugLog, WarningLog, InfoLog}` | Conjunto de tipos de log permitidos |

### Comportamento

- Quando `enableLog` é `false`, todos os logs são ignorados **exceto** `ErrorLog`, que possui `alwaysPrint = true` e sempre é processado.
- `onlyClasses` filtra logs por tipo: apenas objetos cujo `runtimeType` esteja no conjunto serão processados.
- `ErrorLog` não precisa ser incluído em `onlyClasses` para ser processado — ele sempre passa.

### Exemplos de uso

**Configuração padrão (logs desabilitados):**

```dart
final config = ConfigLog();
// enableLog: false, onlyClasses: {DebugLog, WarningLog, InfoLog}
```

**Habilitar todos os logs em desenvolvimento:**

```dart
final config = ConfigLog(enableLog: true);
```

**Filtrar apenas erros e warnings:**

```dart
final config = ConfigLog(
  enableLog: true,
  onlyClasses: {ErrorLog, WarningLog},
);
```

**Produção — logs desabilitados, apenas erros críticos são sempre registrados:**

```dart
final config = ConfigLog(enableLog: false);
// ErrorLog ainda é processado por ter alwaysPrint = true
```

**Integração com registro da impressora:**

```dart
void main() {
  registerLogPrinterColor(
    config: ConfigLog(
      enableLog: true,
      onlyClasses: {DebugLog, ErrorLog},
    ),
  );
  runApp(MyApp());
}
```
