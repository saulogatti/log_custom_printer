# Documentação do Projeto log_custom_printer

## Visão Geral

O `log_custom_printer` é uma biblioteca Dart/Flutter completa para logging customizado, oferecendo recursos avançados de formatação, serialização e gerenciamento de logs.

## Arquitetura do Sistema

### Padrões de Design Utilizados

#### 1. Sealed Class Pattern
- `LoggerObject` é uma classe selada que serve como base da hierarquia de tipos
- Garante type-safety em tempo de compilação
- Permite pattern matching exhaustivo

#### 2. Singleton Pattern
- `LogCustomPrinterBase` implementa singleton para configuração global
- `LoggerCache` usa singleton para gerenciamento centralizado de cache
- `LogDisplayHandler` usa singleton para manipulação unificada de logs

#### 3. Strategy Pattern
- `LogPrinterBase` define a interface para estratégias de impressão
- Implementações: `LogSimplePrint` e `LogWithColorPrint`
- Permite trocar estratégia de saída em runtime

#### 4. Mixin Pattern
- `LoggerClassMixin` fornece funcionalidades de logging para qualquer classe
- Facilita integração sem herança

#### 5. Builder/Factory Pattern
- Construtores de fábrica em `LogCustomPrinterBase`
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

#### LogCustomPrinterBase (singleton)
```dart
class LogCustomPrinterBase
```
Responsabilidades:
- Gerenciamento de instância singleton
- Configuração global de impressora
- Factory methods para configurações comuns

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
- `configLog`: Configuração de filtragem
- `printLog()`: Método abstrato de impressão

#### LogSimplePrint
Estratégia simples:
- Usa `debugPrint()`
- Sem códigos ANSI
- Formato: `[ClassName] timestamp message`

#### LogWithColorPrint
Estratégia avançada:
- Usa `dart:developer.log()`
- Códigos ANSI para cores
- Formatação elaborada com separadores
- Nome do log colorizado

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
- Padrão: habilitado apenas em `kDebugMode`
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

**LoggerDispose**
```dart
extension LoggerDispose on State {
  void debugDispose();
}
```
Logging automático de dispose em widgets.

#### LogDisplayHandler
Gerenciador avançado:
- Coleta e armazena logs por tipo
- Integração com cache persistente
- Notificação de ouvintes
- Handler global de erros Flutter
- Formatação visual elaborada

#### LoggerCache
Cache persistente:
- Singleton para acesso global
- Armazenamento em JSON
- Diretório: `applicationSupport/loggerApp/logs/`
- Cache em memória + disco
- Inicialização assíncrona

#### LoggerJsonList
Container serializável:
- Armazena logs de um tipo específico
- Limite de 100 entradas (configurável) com descarte do log mais antigo ao atingir a capacidade
- Serialização/deserialização automática
- Logs mais recentes primeiro

#### LoggerNotifier
Notificador reativo:
- Baseado em `ChangeNotifier`
- Notifica mudanças em logs
- Integração com widgets Flutter

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
LogCustomPrinterBase.getLogPrinterBase()
  ↓
Verifica ConfigLog
  ↓
logPrinterBase.printLog(log)
  ↓
LogSimplePrint ou LogWithColorPrint
  ↓
Console/Terminal
```

### 3. Armazenamento (LogDisplayHandler)

```
printLog()
  ↓
LogDisplayHandler._toFileLog()
  ↓
LoggerJsonList.addLogger()
  ↓
LoggerCache (memória + disco)
  ↓
LoggerNotifier.notifyListeners()
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
- `getWidgetColor()`: Color do Flutter

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
final printer = LogCustomPrinterBase.colorPrint();
```
- Logs coloridos
- Apenas Debug e Info habilitados
- Saída visual no console

### Produção
```dart
final printer = LogCustomPrinterBase(
  logPrinterCustom: LogSimplePrint(
    config: ConfigLog(
      enableLog: false,
      onlyClasses: {ErrorLog}, // Apenas erros
    ),
  ),
);
```
- Logs desabilitados (exceto erros)
- Sem sobrecarga de performance
- ErrorLog sempre capturado

### Testing
```dart
final printer = LogCustomPrinterBase(
  logPrinterCustom: LogSimplePrint(
    config: ConfigLog(
      enableLog: true,
      onlyClasses: {DebugLog, ErrorLog},
    ),
  ),
);
```
- Logs simples sem cores
- Debug e Erro habilitados
- Fácil leitura em CI/CD

## Integração com Flutter

### Error Handling Global
```dart
// LogDisplayHandler configura automaticamente:
FlutterError.onError = (details) {
  ErrorLog(details.exceptionAsString(), details.stack).sendLog();
};

PlatformDispatcher.instance.onError = (error, stack) {
  ErrorLog(error.toString(), stack).sendLog();
  return true;
};
```

### Widget Integration
```dart
class MyWidget extends StatefulWidget {
  // ...
}

class _MyWidgetState extends State<MyWidget> with LoggerClassMixin {
  @override
  void initState() {
    super.initState();
    logDebug('Widget inicializado');
  }

  @override
  void dispose() {
    debugDispose(); // Extension automática
    super.dispose();
  }
}
```

## Geração de Documentação

### Configuração (dartdoc_options.yaml)

O projeto está completamente configurado para gerar documentação profissional:

#### Categorias Organizadas
- **Core**: Sistema de logging principal
- **Log Types**: Tipos de log (Debug, Info, Warning, Error)
- **Printers**: Estratégias de impressão
- **Configuration**: Sistema de configuração
- **Utilities**: Ferramentas auxiliares

#### Features
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

### Estrutura de Testes
```
test/
├── data_logs/
│   └── jsons_test.dart
├── logger_json_list_test.dart
├── logger_object_test.dart
├── log_custom_printer_test.dart
└── utils_test.dart
```

### Executar Testes
```bash
dart test        # Dart puro
flutter test     # Com Flutter
```

## Performance

### Otimizações
1. **Singleton**: Evita múltiplas instâncias
2. **Const Constructors**: Quando possível
3. **Lazy Initialization**: Cache e notifiers
4. **Filtragem Early**: ConfigLog verifica antes de processar
5. **Limite de Logs**: LoggerJsonList mantém máximo de 100 entradas

### Debug Mode Only
Por padrão, logs são desabilitados em produção via `kDebugMode`.

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
  const MyCustomPrinter({super.config});

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

## Troubleshooting

### Logs não aparecem
- Verificar `ConfigLog.enableLog`
- Verificar se tipo está em `onlyClasses`
- Confirmar que `LogCustomPrinterBase` foi inicializado

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
