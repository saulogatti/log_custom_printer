# log_custom_printer

Biblioteca Dart/Flutter para logging customizado com serialização JSON, formatação colorida ANSI e padrão singleton. Ideal para aplicações que necessitam de logs estruturados, rastreáveis e visualmente organizados.

## ✨ Funcionalidades

- 🎯 **Hierarquia de logs tipada**: `DebugLog`, `InfoLog`, `WarningLog`, `ErrorLog`
- 🎨 **Formatação colorida**: Códigos ANSI para logs visuais no terminal
- 📦 **Serialização JSON**: Auto-geração com `json_serializable`
- 🔧 **Configuração flexível**: Filtragem por tipos e controle de habilitação
- 🏗️ **Padrão Singleton**: Configuração centralizada via `LogCustomPrinterBase`
- 🎭 **Mixin utilities**: `LoggerClassMixin` para integração fácil em classes
- 🔍 **Rastreabilidade**: Identificação automática da classe de origem

## 🚀 Instalação

Adicione no `pubspec.yaml`:

```yaml
dependencies:
  log_custom_printer:
    git:
      url: https://github.com/saulogatti/log_custom_printer.git
    # ou use path local para desenvolvimento:
    # path: ../log_custom_printer
```

Execute:

```bash
flutter pub get  # Para projetos Flutter
# ou
dart pub get     # Para projetos Dart puro
```

## 📖 Uso Básico

### Configuração Inicial

```dart
import 'package:log_custom_printer/log_custom_printer.dart';

// Configuração com cores (recomendado para desenvolvimento)
final printer = LogCustomPrinterBase.colorPrint();

// Ou configuração simples sem cores
final simplePrinter = LogCustomPrinterBase();
```

### Usando o Mixin (Recomendado)

```dart
class MinhaClasse with LoggerClassMixin {
  void minhaFuncao() {
    logDebug('Iniciando função');
    logInfo('Processando dados...');

    try {
      // código da função
      logInfo('Função executada com sucesso');
    } catch (error, stackTrace) {
      logError('Erro na função: $error', stackTrace);
    }
  }
}
```

### Uso Direto dos Objetos de Log

```dart
// Criando logs específicos
final debugLog = DebugLog('Mensagem de debug', typeClass: runtimeType);
debugLog.sendLog();

final errorLog = ErrorLog('Algo deu errado', StackTrace.current, typeClass: runtimeType);
errorLog.sendLog();

// Serialização JSON
final json = debugLog.toJson();
final logRecriado = DebugLog.fromJson(json);
```

### Configuração Avançada

```dart
// Configuração customizada - apenas logs de erro e debug
final printer = LogCustomPrinterBase(
  logPrinterCustom: LogWithColorPrint(
    config: ConfigLog(
      enableLog: true,
      onlyClasses: {DebugLog, ErrorLog}, // Filtra apenas estes tipos
    ),
  ),
);

// Configuração para produção - logs desabilitados
final prodPrinter = LogCustomPrinterBase(
  logPrinterCustom: LogSimplePrint(
    config: ConfigLog(enableLog: false),
  ),
);
```

## 🏗️ Arquitetura

### Componentes Principais

- **`LoggerObject`** (sealed class) — Hierarquia base para tipos de log
- **`LoggerObjectBase`** — Classe abstrata com funcionalidades comuns
- **`LogCustomPrinterBase`** — Singleton para configuração global
- **`ConfigLog`** — Configuração de habilitação e filtragem
- **`LoggerClassMixin`** — Mixin para integração fácil em classes

### Tipos de Log Disponíveis

| Tipo | Cor ANSI | Uso |
|------|----------|-----|
| `DebugLog` | 🟡 Amarelo | Informações de debug/desenvolvimento |
| `InfoLog` | 🔵 Azul | Informações gerais |
| `WarningLog` | 🟠 Laranja | Avisos e alertas |
| `ErrorLog` | 🔴 Vermelho | Erros e exceções |

### Impressoras de Log

- **`LogSimplePrint`** — Saída simples via `debugPrint()` (sem cores)
- **`LogWithColorPrint`** — Saída colorida via `dart:developer.log()`

## 🛠️ Desenvolvimento

### Dependências de Desenvolvimento

```bash
# Instalar dependências
flutter pub get

# Code generation (OBRIGATÓRIO após mudanças em classes @JsonSerializable)
dart run build_runner build --delete-conflicting-outputs

# Ou use o script de automação
./ci.sh -build
```

### Comandos Úteis

```bash
# Análise estática
dart analyze

# Testes
dart test              # Dart puro
flutter test          # Flutter

# Documentação
dart doc

# Atualização de dependências
./ci.sh -upgrade
```

### Adicionando Novos Tipos de Log

1. Estenda `LoggerObjectBase`
2. Adicione `@JsonSerializable()` e importe `.g.dart`
3. Implemente `getColor()` com cor específica
4. Adicione factory `fromJson()` e override `toJson()`
5. Execute `dart run build_runner build`

Exemplo:
```dart
import 'package:json_annotation/json_annotation.dart';
part 'custom_log.g.dart';

@JsonSerializable()
class CustomLog extends LoggerObjectBase {
  CustomLog(super.message, {super.typeClass});

  factory CustomLog.fromJson(Map<String, dynamic> json) =>
      _$CustomLogFromJson(json);

  @override
  LoggerAnsiColor getColor() => LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.purple);

  @override
  Map<String, dynamic> toJson() => _$CustomLogToJson(this);
}
```

## 🤝 Contribuições

Contribuições são bem-vindas! Por favor:

1. Mantenha a API pública estável
2. Documente mudanças importantes no `CHANGELOG.md`
3. Execute testes antes de enviar PRs
4. Siga as convenções do [Effective Dart](https://dart.dev/guides/language/effective-dart)

## 📄 Licença

Este projeto está licenciado sob os termos definidos no arquivo LICENSE do repositório.
