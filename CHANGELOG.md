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