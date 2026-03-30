# Console Visual de Logs

O módulo `console_view` fornece uma interface gráfica Flutter para visualização,
filtragem e exportação dos logs registrados pelo sistema `log_custom_printer`.

---

## Visão Geral

O console visual exibe os logs em tempo real como um overlay flutuante sobre a
aplicação, sem bloquear a UI principal. Suporta filtragem por tipo de log,
filtro temporal por intervalo de data/hora e limpeza da lista.

A arquitetura interna segue Clean Architecture com BLoC para estado e
Repository para acesso a dados.

---

## ConsoleOverlayManager

Classe estática que gerencia a exibição do console como overlay Flutter.
Dois modos de exibição estão disponíveis:

### Janela Arrastável

```dart
// Alternar (abrir/fechar) o console como janela arrastável
ConsoleOverlayManager.toggle(
  context,
  messageRepository,
  loggerCacheRepository,
);

// Exibir diretamente com tamanho customizado
ConsoleOverlayManager.show(
  context,
  messageRepository,
  loggerCacheRepository,
  Size(400, 300),
);

// Fechar a janela arrastável
ConsoleOverlayManager.hide();
```

### Barra Inferior Fixa

```dart
// Exibir console na parte inferior da tela (altura 250 px)
ConsoleOverlayManager.showOverlay(
  context,
  messageRepository,
  loggerCacheRepository,
);

// Fechar a barra inferior
ConsoleOverlayManager.hideConsoleOverlayManager();
```

---

## ConsoleView

Widget principal que exibe a tela de console com:

- Lista de logs filtrados ([ConsoleWidget])
- Barra de filtro por tipo de log ([SegmentedButton])
- Ações na AppBar: atualizar, limpar, exportar, configurações, abrir em overlay

```dart
// Uso direto (requer ConsoleBloc e OptionsBloc na árvore)
const ConsoleView(onClose: myCloseCallback)

// Uso com injeção automática de dependências
ConsoleProvider(
  messageRepository: myMessageRepository,
  optionsRepository: myOptionsRepository,
  loggerCacheRepository: myLoggerCacheRepository,
)
```

### Filtros disponíveis

| Filtro | Como usar |
|--------|-----------|
| Por tipo | Botões segmentados na parte inferior: All, Debug, Info, Warning, Error |
| Por texto | Via `searchText` no [MessageRepository] |
| Por data/hora | Ativado via ícone de filtro na AppBar; configurado em [ConsoleOptionsWidget] |

---

## ConsoleOptionsWidget

Tela de configurações do console, acessível pelo ícone ⚙️ da AppBar:

- **Filtro temporal**: seleção de intervalo via [DateTimeFilterWidget]
- **Opções adicionais**: lista selecionável de preferências via [SelectOptionWidget]

---

## Modelos de Domínio

### LogType

Enum que representa o tipo/severidade de um log no contexto do console visual.

```dart
enum LogType { info, warning, error, debug, all }
```

Cada valor possui:
- `.icon` — ícone associado para exibição
- `.color` — cor associada para exibição
- `.toEnum()` — conversão para [EnumLoggerType] do sistema de cache

### MessageLog

Modelo de apresentação de um log, com:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `title` | `String` | Cabeçalho (classe de origem) |
| `message` | `String` | Corpo da mensagem formatada |
| `timestamp` | `DateTime` | Data/hora de criação |
| `type` | `LogType` | Tipo/severidade do log |

---

## Arquitetura Interna

```
ConsoleOverlayManager
    └── ConsoleView (Stateful)
            ├── ConsoleBloc  ←→  MessageRepository ←→ MessageLogDataSource ←→ LoggerPersistenceService
            │       └── estados: ConsoleInitial / ConsoleLoading / ConsoleLoaded / ConsoleError
            │
            ├── OptionsBloc  ←→  IOptionsRepository ←→ OptionsConsoleDataSource (JSON local)
            │       └── estados: InitialOptionsState / LoadedOptionsState / ErrorOptionsState
            │
            └── ConsoleWidget (lista de LogCardWidget)
```

### BLoC — ConsoleBloc

Gerencia o ciclo de vida dos logs exibidos:

| Evento | Ação |
|--------|------|
| `ConsoleLoad` | Carrega/recarrega todos os logs |
| `ConsoleClear` | Limpa os logs e recarrega |
| `ConsoleFilterByType` | Filtra por [LogType] |
| `ConsoleUpdateDateTimeFilter` | Aplica/remove filtro temporal |
| `ConsoleExportLogs` | Exporta logs no formato especificado |

### BLoC — OptionsBloc (Cubit)

Gerencia as preferências persistidas do console:

| Método | Ação |
|--------|------|
| `loadOptions()` | Lê opções do arquivo local |
| `selectDateTimeRange(range)` | Salva intervalo e ativa filtro temporal |
| `setDateTimeFilterEnabled(bool)` | Liga/desliga filtro sem alterar o intervalo |
| `selectOption(option)` | Persiste a opção selecionada |

---

## Dependências e Injeção

Para usar o console visual, registre as dependências via `initAppInjection()`
antes de abrir o overlay:

```dart
import 'package:log_custom_printer/src/console_view/application/application_injection.dart';

void main() {
  initAppInjection(); // registra MessageRepository, IOptionsRepository, ILoggerCacheRepository
  runApp(MyApp());
}
```

Ou forneça os repositórios diretamente ao [ConsoleOverlayManager]:

```dart
ConsoleOverlayManager.toggle(
  context,
  appGetIt<MessageRepository>(),
  appGetIt<ILoggerCacheRepository>(),
);
```

---

## Fluxo de Dados

```
LoggerPersistenceService (cache)
    ↓
MessageLogDataSource (filtragem: tipo, texto, data)
    ↓
MessageRepositoryImpl
    ↓
ConsoleBloc
    ↓
ConsoleView → ConsoleWidget → LogCardWidget
```
