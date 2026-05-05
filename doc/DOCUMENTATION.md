# Documentação do Projeto log_custom_printer

## Visão Geral

O `log_custom_printer` é uma biblioteca **Dart pura** para logging customizado (CLI, servidor, scripts e uso em Flutter após registo no `main`). Oferece formatação, serialização JSON e gestão de cache/persistência.

## Arquitetura do Sistema

### Padrões de Design Utilizados

#### 1. Sealed Class Pattern
- `LoggerObject` é uma classe selada que serve como base da hierarquia de tipos
- Garante type-safety em tempo de compilação
- Permite pattern matching exhaustivo

#### 2. Service Locator / Dependency Injection
- `registerLogPrinter` e `fetchLogPrinterService` usam get_it para injeção de dependência
- `LogPrinterService` centraliza regras de filtragem e envio para impressão/cache
- `LoggerPersistenceService` encapsula operações de cache/persistência

#### 3. Strategy Pattern
- `LogPrinterBase` define a interface para estratégias de impressão
- Implementações: `LogSimplePrint` e `LogWithColorPrint`
- Permite trocar estratégia de saída em runtime

#### 4. Mixin Pattern
- `LoggerClassMixin` fornece funcionalidades de logging para qualquer classe
- Facilita integração sem herança

#### 5. Builder/Factory Pattern
- Funções `registerLogPrinterColor`, `registerLogPrinterSimple` para setup rápido
- Métodos `fromJson` em todas as classes de log

## Estrutura de Componentes

### Core (Núcleo)

#### LoggerObject (sealed class)
```dart
sealed class LoggerObject {}
```
- Base da hierarquia de tipos
- Marcador para type-safety
- Não possui membros próprios

#### LoggerObjectBase (abstract class)
```dart
abstract class LoggerObjectBase extends LoggerObject
```
Responsabilidades:
- Validação de mensagens
- Gerenciamento de timestamp
- Identificação de origem (className)
- Formatação de mensagens
- Aplicação de cores ANSI
- Envio de logs

Campos principais:
- `message`: Mensagem do log
- `logCreationDate`: Timestamp de criação
- `className`: Identificador da origem

#### Log Printer Locator (DI)
```dart
LoggerPersistenceService registerLogPrinter(
  LogPrinterBase printer, {
  ILoggerCacheRepository? cacheRepository,
  required ConfigLog config,
});
LogPrinterService fetchLogPrinterService();
```
Responsabilidades:
- Registro da impressora no get_it (startup)
- Resolução da impressora para `sendLog()` e mixin
- Funções de conveniência: `registerLogPrinterColor`, `registerLogPrinterSimple`

### Log Types (Tipos de Log)

Hierarquia de tipos concretos:

```
LoggerObject (sealed)
    └── LoggerObjectBase (abstract)
            ├── DebugLog    (amarelo)
            ├── InfoLog     (branco)
            ├── WarningLog  (verde)
            └── ErrorLog    (vermelho + stack trace)
```

Cada tipo:
- Define cor específica via `getColor()`
- Implementa serialização JSON
- Herda comportamento base

### Printers (Impressoras)

#### LogPrinterBase (abstract)
Interface para estratégias de impressão:
- `printLog(LoggerObjectBase log)`: método abstrato de saída

A filtragem (`ConfigLog`) é aplicada em `LogPrinterService`, não na impressora.

#### LogSimplePrint
Estratégia simples:
- Saída sem códigos ANSI (mensagem via `getMessage(false)`)
- Formato típico: `[ClassName] …`

#### LogWithColorPrint
Estratégia com cores:
- Códigos ANSI para realçar tipo e mensagem
- Adequada para terminais com suporte ANSI

### Configuration (Configuração)

#### ConfigLog
```dart
class ConfigLog {
  final bool enableLog;
  final Set<Type> onlyClasses;
}
```

Funcionalidades:
- Controle global de habilitação
- Filtragem por tipos de log
- Padrão: `enableLog = false`
- ErrorLog sempre processado (segurança)

### Utilities (Utilitários)

#### LoggerClassMixin
Mixin para integração fácil:
- `logDebug()`: Cria e envia DebugLog
- `logInfo()`: Cria e envia InfoLog
- `logWarning()`: Cria e envia WarningLog
- `logError()`: Cria e envia ErrorLog
- Preenche automaticamente `typeClass`

#### Extensions

**DateTimeLogHelper**
```dart
extension DateTimeLogHelper on DateTime {
  String onlyTime();
  String onlyDate();
  String get logFullDateTime;
}
```
Formatação de timestamps consistente.

**StackTraceSdk**
```dart
extension StackTraceSdk on StackTrace {
  String formatStackTrace(LoggerAnsiColor?, int);
  Map<String, dynamic> stackInMap([int]);
}
```
Formatação e filtragem de stack traces.

#### LoggerPersistenceService
Serviço de persistência e acesso a logs:
- Encapsula um `ILoggerCacheRepository`
- Expõe leitura/limpeza (`getAllLogs`, `getLogsByType`, `clearLogs`, `clearLogsByType`)
- É retornado por `registerLogPrinter`, `registerLogPrinterColor` e `registerLogPrinterSimple`

#### LoggerCache
Cache persistente:
- Armazenamento em JSON
- Diretório: `applicationSupport/loggerApp/logs/`
- Cache em memória + disco
- Inicialização assíncrona

#### FileManager / FileType
Componente interno de I/O para persistência em disco, com validação de extensão
por tipo de arquivo (`FileType.txt`, `FileType.json`, `FileType.log`).

Garantias de concorrência:
- Operações no mesmo `path` são serializadas (path lock assíncrono)
- Operações em paths diferentes permanecem paralelas

Essas garantias reduzem risco de condição de corrida durante escrita/leitura/remoção
de arquivos em cenários com múltiplas operações assíncronas concorrentes.

#### LoggerJsonList
Container serializável:
- Armazena logs de um tipo específico
- Limite de 100 entradas (configurável) com descarte do log mais antigo ao atingir a capacidade
- Serialização/deserialização automática
- Logs mais recentes primeiro

> Nota: a UI de consola Flutter foi extraída para um pacote à parte na v3. A categoria **Console View** na documentação gerada (`dart doc`) descreve essa integração opcional, não código neste repositório. Ver [ConsoleView.md](ConsoleView.md).

## Fluxo de Dados

### 1. Criação de Log

```
Usuário
  ↓
LoggerClassMixin.logDebug()
  ↓
DebugLog(message, typeClass)
  ↓
log.sendLog()
```

### 2. Processamento de Log

```
sendLog()
  ↓
fetchLogPrinterService() (get_it)
  ↓
Verifica ConfigLog
  ↓
LogPrinterService.executePrint(log)
  ↓
LogSimplePrint ou LogWithColorPrint
  ↓
Console/Terminal
```

### 3. Armazenamento (LoggerPersistenceService)

```
executePrint()
  ↓
LoggerPersistenceService.addLog()
  ↓
LoggerJsonList.addLogger()
  ↓
LoggerCache (memória + disco)
```

## Serialização JSON

### Build Runner
O projeto usa `json_serializable` com code generation:

```yaml
# build.yaml
targets:
  $default:
    builders:
      json_serializable:
        options:
          explicit_to_json: true
```

### Arquivos Gerados
Para cada classe com `@JsonSerializable()`:
- Arquivo `.g.dart` gerado automaticamente
- Funções `_$ClassFromJson()` e `_$ClassToJson()`
- Executar: `dart run build_runner build --delete-conflicting-outputs`

## Cores ANSI

### EnumAnsiColors
```dart
enum EnumAnsiColors {
  black, red, green, yellow,
  blue, magenta, cyan, white
}
```

Funcionalidades:
- `getBgColor()`: Código ANSI para fundo
- `getFgColor()`: Código ANSI para texto
 
### LoggerAnsiColor
```dart
class LoggerAnsiColor {
  String call(String msg); // Aplica cor à mensagem
}
```

Formato ANSI: `\x1B[CODIGOm TEXTO \x1B[0m`

## Configurações Recomendadas

### Desenvolvimento
```dart
void main() {
  registerLogPrinterColor(config: ConfigLog(enableLog: true));
  // Em Flutter: runApp(const MyApp());
}
```
- Logs coloridos
- Saída visual no terminal

### Produção
```dart
void main() {
  registerLogPrinterSimple(
    config: ConfigLog(
      enableLog: false,
      onlyClasses: {ErrorLog}, // Apenas erros
    ),
  );
  // Em Flutter: runApp(const MyApp());
}
```
- Logs desabilitados (exceto erros)
- Sem sobrecarga de performance
- ErrorLog sempre capturado

### Testing
```dart
setUp(() {
  registerLogPrinter(
    const LogSimplePrint(),
    config: ConfigLog(
      enableLog: true,
      onlyClasses: {DebugLog, ErrorLog},
    ),
  );
});
tearDown(() async => GetIt.instance.reset());
```
- Logs simples sem cores
- Debug e Erro habilitados
- Fácil leitura em CI/CD

## Integração com Flutter

Não há dependência de Flutter neste pacote. Num app Flutter, chame `registerLogPrinter*` no `main` antes de `runApp` e use `ErrorLog(...).sendLog()` por exemplo em `FlutterError.onError` ou zonas, se desejar relatório centralizado.

## Geração de Documentação

### Configuração (dartdoc_options.yaml)

O projeto está completamente configurado para gerar documentação profissional:

#### Categorias organizadas
- **Core**, **Log Types**, **Printers**, **Configuration**, **Utilities**
- **Console View**: texto de categoria aponta para [ConsoleView.md](ConsoleView.md) (integração opcional com pacote Flutter externo, não classes exportadas por `log_custom_printer`)

#### Funcionalidades do dartdoc
- Links para código fonte no GitHub
- Exclusão de arquivos gerados (*.g.dart)
- Saída em `doc/api`
- Detecção de erros e avisos

### Gerar Documentação
```bash
dart doc
```

Resultado em: `doc/api/index.html`

## Padrões de Código

### Effective Dart
O projeto segue as diretrizes do Effective Dart:
- Nomenclatura consistente
- Doc comments com `///`
- Uso de `const` quando possível
- Prefer final para variáveis imutáveis

### Code Style
Configurado em `analysis_options.yaml`:
- Strict casts, inference e raw types
- Erros: unused variables, dead code
- Warnings: prefer const, prefer final

## Testing

### Estrutura de testes (exemplo)
```
test/
├── data_logs/
│   └── jsons_mocks.dart
├── file_manager_type_concurrency_test.dart
├── log_custom_printer_test.dart
├── log_exception_test.dart
├── log_json_test.dart
├── log_query_test.dart
├── log_simple_printer_test.dart
├── logger_cache_test.dart
├── logger_cache_functional_test.dart
├── logger_json_list_test.dart
├── logger_object_test.dart
└── utils_test.dart
```

### Executar testes
```bash
dart test
```

## Performance

### Otimizações
1. **Service Locator (get_it)**: centraliza resolução de `LogPrinterService`
2. **Const Constructors**: Quando possível
3. **Inicialização assíncrona**: cache/persistência com carregamento sob demanda
4. **Filtragem Early**: ConfigLog verifica antes de processar
5. **Limite de Logs**: LoggerJsonList mantém máximo de 100 entradas
6. **I/O serializado por caminho**: evita disputas entre operações concorrentes no mesmo arquivo

### Debug Mode Only
Por padrão, logs ficam desabilitados quando `ConfigLog(enableLog: false)`.

## Manutenção

### Adicionar Novo Tipo de Log
1. Criar classe estendendo `LoggerObjectBase`
2. Adicionar `@JsonSerializable()`
3. Implementar `getColor()`
4. Adicionar factory `fromJson()` e `toJson()`
5. Executar `dart run build_runner build`
6. Adicionar em `ConfigLog.onlyClasses` se necessário
7. Adicionar em `LoggerJsonList._typeConstructors`

### Atualizar Dependências
```bash
./ci.sh -upgrade
```

### Code Generation
```bash
./ci.sh -build
# ou
dart run build_runner build --delete-conflicting-outputs
```

## Recursos Avançados

### Custom Printer
```dart
class MyCustomPrinter extends LogPrinterBase {
  const MyCustomPrinter();

  @override
  void printLog(LoggerObjectBase log) {
    // Implementação customizada
    // Ex: enviar para servidor remoto
  }
}
```

### Custom Colors
```dart
class MyLog extends LoggerObjectBase {
  MyLog(super.message, {super.typeClass});

  @override
  LoggerAnsiColor getColor() {
    return LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.magenta);
  }
}
```

## Console visual (Flutter)

Na versão 3.x o overlay de consola **não faz parte** deste pacote. Para migração a partir da v2 e integração com o pacote Flutter à parte, consulte [ConsoleView.md](ConsoleView.md).

## Troubleshooting

### Logs não aparecem
- Verificar `ConfigLog.enableLog`
- Verificar se tipo está em `onlyClasses`
- Confirmar que `registerLogPrinter()` foi chamado no startup

### Erro de build
```bash
# Limpar e reconstruir
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Performance em produção
- Desabilitar logs: `ConfigLog(enableLog: false)`
- Manter apenas ErrorLog habilitado

## Referências

- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [dartdoc Documentation](https://dart.dev/tools/dartdoc)
- [json_serializable](https://pub.dev/packages/json_serializable)
- [ANSI Escape Codes](https://en.wikipedia.org/wiki/ANSI_escape_code)

## Contribuindo

Ao adicionar funcionalidades:
1. Seguir padrões existentes
2. Adicionar doc comments completos
3. Incluir exemplos de uso
4. Adicionar testes
5. Atualizar CHANGELOG.md
6. Gerar documentação: `dart doc`

## Licença

Consulte o arquivo LICENSE no repositório.
