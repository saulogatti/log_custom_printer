# log_custom_printer

Biblioteca Dart/Flutter para logging customizado com serialização JSON, formatação colorida ANSI e injeção de dependência (get_it). Ideal para aplicações que necessitam de logs estruturados, rastreáveis e visualmente organizados.

> **v2.0.0** — Refatoração da API de registro: `registerLogPrinterColor` e `registerLogPrinterSimple` retornam `LoggerCacheRepository` e incluem cache integrado por padrão. Impressoras customizadas via `registerLogPrinter(LogPrinterBase, cacheRepository: ...)`.

## ✨ Funcionalidades

- 🎯 **Hierarquia de logs tipada**: `DebugLog`, `InfoLog`, `WarningLog`, `ErrorLog`
- 🎨 **Formatação colorida**: Códigos ANSI para logs visuais no terminal
- 📦 **Serialização JSON**: Auto-geração com `json_serializable`
- 🔧 **Configuração flexível**: Filtragem por tipos e controle de habilitação
- 💾 **Sistema de Cache**: Armazenamento de logs em memória e persistência em arquivo JSON
- 🏗️ **Injeção de Dependência**: Configuração via `registerLogPrinter`, `registerLogPrinterColor` ou `registerLogPrinterSimple` (get_it)
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
dart pub get     # Projetos Dart puro
flutter pub get  # Projetos Flutter
```

**Requisitos:** Dart SDK ^3.11.0

## 📖 Uso Básico

### Configuração Inicial (obrigatório no startup)

```dart
import 'package:log_custom_printer/log_custom_printer.dart';

void main() {
  // Configuração com cores (recomendado para desenvolvimento)
  // Retorna LoggerCacheRepository para acesso ao cache de logs
  final cacheRepository = registerLogPrinterColor(
    config: ConfigLog(enableLog: true),
    maxLogsInCache: 100, // Opcional: limite de logs em memória por tipo (padrão: 100)
    cacheFilePath: '/caminho/para/salvar/logs', // Opcional: persistência em arquivo JSON
  );

  // Ou configuração simples sem cores
  // final cacheRepository = registerLogPrinterSimple(config: ConfigLog(enableLog: true));

  runApp(MyApp());
}
```

### Sistema de Cache

`registerLogPrinterColor` e `registerLogPrinterSimple` retornam um `LoggerCacheRepository` que armazena logs em memória e, opcionalmente, em arquivo via `cacheFilePath`.

```dart
// Recuperar todos os logs
final allLogs = await cacheRepository.getAllLogs();

// Recuperar logs por tipo
final errorLogs = await cacheRepository.getLogsByType(EnumLoggerType.error);

// Limpar logs
await cacheRepository.clearLogs();
await cacheRepository.clearLogsByType(EnumLoggerType.debug);
```

Para implementar storage customizado (banco local, SharedPreferences etc.), implemente `LoggerCacheRepository` e passe via `registerLogPrinter(printer, cacheRepository: seuRepository)`.

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
void main() {
  // Configuração customizada - apenas logs de erro e debug
  registerLogPrinterColor(
    config: ConfigLog(
      enableLog: true,
      onlyClasses: {DebugLog, ErrorLog}, // Filtra apenas estes tipos
    ),
  );

  // Ou para produção - logs desabilitados
  // registerLogPrinterSimple(config: ConfigLog(enableLog: false));

  runApp(MyApp());
}
```

### Regras de Entrega de Logs

- `ConfigLog.enableLog`: quando `false`, todos os logs são ignorados **exceto** aqueles com `alwaysPrint` (ex: `ErrorLog`).
- `ConfigLog.onlyClasses`: filtra quais tipos são aceitos; se não estiver vazio e o tipo não estiver no conjunto, o log é descartado.
- `LoggerClassMixin`: preenche automaticamente `className` com o `runtimeType` da classe que está emitindo o log.
- `LoggerJsonList`: mantém no máximo `maxLogEntries` (padrão 100) por tipo, inserindo o mais novo no topo e descartando o mais antigo.

## 🏗️ Arquitetura

### Componentes Principais

- **`LoggerObject`** (sealed class) — Hierarquia base para tipos de log
- **`LoggerObjectBase`** — Classe abstrata com funcionalidades comuns
- **`LogPrinterService`** — Serviço central que coordena impressão e cache (resolvido via get_it)
- **`registerLogPrinter`** / **`registerLogPrinterColor`** / **`registerLogPrinterSimple`** — Injeção de dependência via get_it
- **`ConfigLog`** — Configuração de habilitação e filtragem (padrão: `enableLog: false`, `onlyClasses: {DebugLog, WarningLog, InfoLog}`)
- **`LoggerCacheRepository`** — Interface para repositório de cache de logs (retornado pelos `register*`)
- **`LoggerClassMixin`** — Mixin para integração fácil em classes

### Tipos de Log Disponíveis

| Tipo | Cor ANSI | Uso |
|------|----------|-----|
| `DebugLog` | 🟡 Amarelo | Informações de debug/desenvolvimento |
| `InfoLog` | ⚪ Branco | Informações gerais |
| `WarningLog` | 🟢 Verde | Avisos e alertas |
| `ErrorLog` | 🔴 Vermelho | Erros e exceções (sempre processado via `alwaysPrint`) |

### Impressoras de Log

- **`LogSimplePrint`** — Saída simples via `print()` (sem cores)
- **`LogWithColorPrint`** — Saída colorida via `dart:developer.log()` com separadores ANSI

Use `registerLogPrinterColor()` ou `registerLogPrinterSimple()` para configuração rápida; ou `registerLogPrinter(LogPrinterBase)` para impressoras customizadas.

## 🛠️ Desenvolvimento

### Dependências de Desenvolvimento

```bash
# Instalar dependências
dart pub get
# ou: flutter pub get

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
dart doc               # Gera documentação em doc/api

# Atualização de dependências
./ci.sh -upgrade
```

Cobertura atual de testes automatizados:
- Serialização e truncamento de `LoggerJsonList` mantendo ordem mais recente → mais antiga
- Filtragem de logs via `ConfigLog.onlyClasses` e priorização de `ErrorLog` (via `alwaysPrint`) mesmo com `enableLog = false`
- `LoggerClassMixin` preenchendo `className` com o `runtimeType` da classe hospedeira
- Utilitários: formatação de data/hora, aplicação de códigos ANSI e limpeza de stack trace

### Geração de Documentação

O projeto está configurado para gerar documentação usando `dartdoc`. A configuração está definida em `dartdoc_options.yaml` com:

- Categorização automática por funcionalidade (Core, Log Types, Printers, Configuration, Utilities)
- Links para o código fonte no GitHub
- Exclusão automática de arquivos gerados (*.g.dart, *.freezed.dart)
- Saída em `doc/api`

Para gerar a documentação:

```bash
dart doc
```

A documentação gerada incluirá:
- Documentação completa de todas as classes públicas
- Exemplos de uso para cada componente
- Referências cruzadas entre tipos relacionados
- Categorias organizadas para fácil navegação

### Adicionando Novos Tipos de Log

1. Estenda `LoggerObjectBase`
2. Adicione `@JsonSerializable()` e importe `.g.dart`
3. Implemente `getColor()` com cor específica
4. Adicione factory `fromJson()` e override `toJson()`
5. Execute `dart run build_runner build` ou `./ci.sh -build`

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
  LoggerAnsiColor getColor() => LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.magenta);

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
