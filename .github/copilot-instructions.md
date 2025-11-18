# Copilot Instructions for `log_custom_printer`

## Visão Geral
Biblioteca Dart/Flutter de logging customizada com foco em serialização JSON, formatação colorida via ANSI e padrão singleton. O core da arquitetura é baseado em hierarquia de classes selada (`LoggerObject`), com diferentes tipos de log (debug, info, warning, error) e impressoras configuráveis.

## Arquitetura e Componentes Principais

### Hierarquia de Logs (sealed class)
- `LoggerObject` é a classe base selada em `lib/src/logs_object/logger_object.dart`
- `LoggerObjectBase` define o contrato abstrato com `getColor()`, `getMessage()`, `sendLog()` e `toJson()`
- Implementações concretas: `DebugLog`, `InfoLog`, `WarningLog`, `ErrorLog` cada uma com sua cor ANSI específica

### Padrão Singleton e Configuração
- `LogCustomPrinterBase` usa singleton para centralizar a configuração da biblioteca
- `ConfigLog` controla habilitação de logs e filtragem por tipos (`onlyClasses`)
- Use `LogCustomPrinterBase.colorPrint()` para logs com cores ou `LogCustomPrinterBase()` para logs simples

### Sistema de Impressão Strategy Pattern
- `LogPrinterBase` define o contrato para impressoras de log
- `LogSimplePrint` usa `debugPrint()` sem cores
- `LogWithColorPrint` usa `dart:developer.log()` com códigos ANSI coloridos

## Workflows Críticos

### Code Generation
```bash
dart run build_runner build --delete-conflicting-outputs
```
**SEMPRE** rode após modificar classes com `@JsonSerializable()`. O build.yaml está configurado com `explicit_to_json: true`.

### Scripts de Automação
Use `./ci.sh -build` para code generation ou `./ci.sh -upgrade` para atualização de dependências.

### Testes
```bash
dart test
# ou para Flutter
flutter test
```

## Convenções Específicas do Projeto

### Criação de Novos Tipos de Log
1. Estenda `LoggerObjectBase`
2. Adicione `@JsonSerializable()` e importe o `.g.dart`
3. Implemente `getColor()` retornando `LoggerAnsiColor` específico
4. Adicione factory `fromJson()` e override `toJson()`
5. Exemplo em `lib/src/logs_object/debug_log.dart`

### Uso do Mixin `LoggerClassMixin`
```dart
class MyClass with LoggerClassMixin {
  void someMethod() {
    logDebug('Debug message');  // Automaticamente inclui runtimeType
    logError('Error', stackTrace);
  }
}
```

### Configuração Avançada
```dart
final printer = LogCustomPrinterBase(
  logPrinterCustom: LogWithColorPrint(
    config: ConfigLog(onlyClasses: <Type>{DebugLog, InfoLog})
  )
);
```

## Integrações e Dependências

### JSON Serialization
- `json_annotation` + `json_serializable` para auto-geração de `toJson()/fromJson()`
- `build_runner` para code generation (veja build.yaml)

### Flutter Dependencies
- `flutter/material.dart` para `debugPrint` e `@mustCallSuper`
- `dart:developer` para logging colorido via `log()`

### Validação e Controle
- Usa `assert()` para validar mensagens não vazias em desenvolvimento
- `ConfigLog.enableLog` padrão é `kDebugMode` (só ativo em debug)
- `onlyClasses` filtra tipos de log permitidos

## Padrões de Desenvolvimento
- Sempre use `super.` nos construtores das classes de log
- `runtimeType` é automaticamente capturado como `className` via `typeClass`
- Logs não são enviados automaticamente no construtor - use `.sendLog()` explicitamente
- Extension `LoggerDispose` para logs automáticos de dispose em `State` widgets