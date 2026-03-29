# Instruções de IA — Dart/Flutter (focadas no projeto)

Este projeto é uma biblioteca Dart/Flutter e está em refatoração incremental
para Clean Architecture. As regras abaixo priorizam manutenibilidade,
testabilidade e consistência com o domínio atual.

> Importante: siga também `.github/copilot-instructions.md`.

## Regras obrigatórias (sempre aplicar)

1. **Nunca duplicar código.**
   - Se o mesmo trecho aparecer em mais de um lugar, extraia para método,
     função, classe utilitária ou componente reutilizável.
2. **Evitar widgets grandes.**
   - Quando um widget crescer demais, divida em widgets menores.
3. **Widgets reutilizáveis em arquivo separado.**
   - Se puder ser reaproveitado por outra tela/fluxo, crie em arquivo próprio.
4. **Arquitetura limpa por evolução gradual.**
   - Sempre que tocar em uma área, prefira mover o design na direção de Clean
     Architecture (sem big-bang).
5. **BLoC/Cubit para estado e lógica complexa em telas.**
   - Telas não devem conter regra de negócio ou lógica complexa.
   - A UI apenas renderiza estado e dispara eventos/intenções.

## Diretrizes de arquitetura do projeto

- Organizar por camadas, quando aplicável:
  - **Presentation** (widgets/telas + bloc/cubit)
  - **Domain** (regras de negócio, entidades, casos de uso)
  - **Data** (repositórios, fontes de dados, DTOs)
  - **Core** (utilitários compartilhados)
- Aplicar separação de responsabilidades e baixo acoplamento.
- Preferir composição sobre herança.
- Dependências devem apontar para dentro (UI -> Domain; Data -> Domain).

## Regras de Dart

- Seguir Effective Dart e `analysis_options.yaml`.
- Nomeação clara e sem abreviações desnecessárias.
- Código simples, legível e com responsabilidade única.
- Tratar erros explicitamente; não falhar em silêncio.
- Manter null safety sólido; evitar `!` sem garantia.
- Documentar APIs públicas com `///` quando fizer sentido.

## Regras de Flutter/UI

- Widgets devem ser pequenos, coesos e focados em renderização.
- Extrair widgets privados para reduzir complexidade de `build()`.
- Em listas longas, usar construtores com lazy loading (`ListView.builder`,
  `SliverList`).
- Evitar trabalho pesado dentro de `build()`.
- Preferir `const` quando possível.

## Estado e fluxo de dados

- Para telas com carregamento de dados, múltiplos estados, paginação,
  filtros, tratamento de erro ou lógica não trivial: **usar BLoC/Cubit**.
- Estado deve ser explícito (ex.: initial/loading/success/error).
- UI reage ao estado; não executa regra de negócio.
- Casos simples e locais podem usar soluções leves, mas sem violar separação
  de responsabilidades.

## Testes

- Escrever testes pensando em Arrange-Act-Assert.
- Priorizar testes de domínio e de bloc/cubit para regras críticas.
- Em testes de UI, validar renderização por estado.
- Preferir fakes/stubs a mocks quando viável.

## Logging e observabilidade

- Não usar `print` solto.
- Usar a estratégia de logging do próprio projeto.
- Em Flutter puro, quando necessário, preferir logging estruturado.

## Codegen e arquivos gerados

- Não editar `*.g.dart` manualmente.
- Ao alterar modelos com `json_serializable`, regenerar código com
  `build_runner`.

## Dependências

- Só adicionar pacote externo quando houver ganho claro.
- Justificar benefício técnico ao sugerir nova dependência.
- Preferir soluções já adotadas no projeto antes de introduzir novas.

## Checklist de revisão antes de concluir uma tarefa

- Houve duplicação de código? Se sim, extrair.
- Algum widget ficou grande demais? Se sim, quebrar.
- Componente reutilizável foi para arquivo próprio?
- Regra de negócio ficou fora da UI?
- Fluxo complexo de tela está em BLoC/Cubit?
- Mantive compatibilidade com as instruções de domínio do projeto?
