# Changelog

## 3.0.0

- **Breaking change:** remoção da dependência de **Flutter** e de todo o módulo de **consola visual** (`console_view`); a biblioteca passa a ser **Dart pura** e reutilizável em CLI, servidores e (com registo no `main`) em apps Flutter. A consola em overlay passa a ser fornecida por **pacote Flutter separado** (ver `docs/ConsoleView.md`).
- A API de registo (`registerLogPrinter`, `registerLogPrinterColor`, `registerLogPrinterSimple`) mantém-se; `registerLogPrinterColor` continua a usar `LogWithColorPrint` e `registerLogPrinterSimple` usa `LogSimplePrint`; impressoras próprias via `registerLogPrinter` com `LogPrinterBase`.
- Documentação: comentários de API, `README`, guias em `docs/` e `dart doc` alinhados à v3; guias técnicos na pasta `docs/`.
- Documentação gerada: texto do construtor de `LoggerPersistenceService` corrigido para o `dart doc`; exemplos na API sem obrigar `runApp` em projetos só Dart.

## 2.2.0
- Adicionar filtros avançados para os logs, permitindo que os usuários filtrem os logs por tipo, data e outros critérios personalizados, facilitando a análise e organização dos logs.
- Refactor: atualizar a estrutura do projeto para acomodar os novos filtros avançados, garantindo que a implementação seja modular e fácil de manter.
- Refactor: atualizar a documentação para incluir informações sobre os novos filtros avançados, fornecendo orientações claras sobre como utilizá-los de forma eficaz.
- Fix: corrigir quaisquer bugs relacionados à implementação dos filtros avançados, garantindo que eles funcionem corretamente e não causem problemas de desempenho ou estabilidade.
- Atualizar o changelog para refletir as melhorias e correções implementadas na versão 2.2.0, destacando os benefícios dos novos filtros avançados para os usuários da biblioteca.


## 2.1.0

- Novo compoente de console para exibir os logs de forma mais organizada e visualmente atraente, facilitando a leitura e análise dos logs durante o desenvolvimento.  
- Refactor: atualizar a estrutura do projeto para melhorar a organização dos arquivos e facilitar a manutenção da biblioteca.
- Refactor: atualizar a documentação para refletir as mudanças na estrutura do projeto e fornecer orientações claras sobre como utilizar a biblioteca de forma eficaz.
- Fix: corrigir pequenos bugs e melhorar a estabilidade geral da biblioteca, garantindo uma experiência mais confiável para os usuários.
- Atualizar o changelog para refletir as melhorias e correções implementadas na versão 2.1.0, destacando as mudanças significativas e os benefícios para os usuários da biblioteca.

## 2.0.1
- Fix: corrigir o caminho dos logs para ambiente de teste, garantindo que os logs sejam gravados corretamente durante os testes.
- Atualizar o changelog para refletir a correção do caminho dos logs em ambiente de teste, destacando a importância dessa correção para garantir a funcionalidade adequada da biblioteca durante os testes.

## 2.0.0
- Refactor: remover dependências de arquivos específicos do projeto, como date_time_log_helper e
- logger_ansi_color, para tornar a biblioteca mais genérica e reutilizável.
- Refactor: remover a classe LogWithColorPrint e substituir por uma função de registro de impressora colorida, permitindo maior flexibilidade na implementação de diferentes estratégias de impressão.
- Refactor: atualizar a documentação para refletir as mudanças nas estratégias de impressão e remover referências a classes específicas que foram removidas.
- Fix: ajustar o caminho dos logs para ambiente de teste, garantindo que os logs sejam gravados corretamente durante os testes.
- Adicionar printers customizados (colorido) para permitir que os usuários escolham entre diferentes estilos de impressão, incluindo uma opção colorida para melhor visualização dos logs.
- Atualizar o changelog para refletir as mudanças significativas na versão 2.0.0, destacando as melhorias e correções implementadas.

## 1.1.0
- Refactor: remover .flutter-plugins-dependencies do controle de versão e do .gitignore
- Fix: ajustar caminho dos logs para ambiente de teste
- Adicionar printers customizados (colorido)

## 1.0.0

- Initial version.