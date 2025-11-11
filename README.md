# log_custom_printer

Biblioteca de utilitários para registro de log com formatos personalizados,
serialização JSON e suporte a impressão com e sem cor (ANSI). Feita para
ser usada em apps Flutter/Dart que precisam de logs legíveis e fáceis de
filtrar por origem.

## Funcionalidades

- Suporte a diferentes níveis de log: debug, info, warning, error.
- Objetos de log serializáveis com `json_annotation`.
- Impressão simples (`LogSimplePrint`) e com cor/estilo ANSI
	(`LogWithColorPrint`).
- Permite identificar a origem do log (`className`) automaticamente via
	`runtimeType`.

## Instalação

Adicione no `pubspec.yaml` do seu projeto (substitua pela versão desejada):

```yaml
dependencies:
	log_custom_printer:
		path: ../ # ou use a versão publicada no pub.dev
```

Depois rode:

```bash
dart pub get
```

ou, para projetos Flutter:

```bash
flutter pub get
```

## Uso rápido

Exemplo mínimo de uso (em uma classe qualquer):

```dart
final printer = LogCustomPrinterBase(logPrinterCustom: LogWithColorPrint());

// Exemplo usando o mixin LogClassMixin em uma classe
// this.logDebug('Mensagem de teste');
```

Para uso direto com os objetos de log:

```dart
final log = DebugLog('Mensagem de debug', typeClass: runtimeType);
log.sendLog();
```

## Arquitetura / API principal

- `LoggerObjectBase` — classe base abstrata para objetos de log. Define
	campos como `message`, `logCreationDate` e `className` e fornece
	`getMessage()` e `sendLog()`.
- `LogCustomPrinterBase` — ponto de configuração para escolher a
	implementação de impressão de logs.
- `LogSimplePrint` — imprime logs sem códigos ANSI (usa `debugPrint`).
- `LogWithColorPrint` — imprime blocos de texto coloridos usando
	`LoggerObjectBase.getColor()` e envia via `dart:developer.log`.

## Exemplos e pasta `example`

Abra a pasta `example/` e execute:

```bash
cd example
flutter run
```

Isso executará o aplicativo de exemplo que demonstra o uso do pacote.

## Desenvolvimento

- Rodar análise estática:

```bash
dart analyze
```

- Rodar testes (se houver):

```bash
dart test
# ou para projetos Flutter com testes:
flutter test
```

## Contribuições

Pull requests são bem-vindos. Por favor, mantenha a API pública estável
ou documente mudanças importantes no CHANGELOG.

## Licença

Licença conforme definida no repositório (ver arquivo `LICENSE` se
presente).


