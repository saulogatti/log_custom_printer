---
applyTo: '**/*.dart'
---

# Padrões de Codificação

Siga as diretrizes do **Effective Dart** para garantir **Documentação e
Codificação consistentes**.

------------------------------------------------------------------------

## Glossário

-   **Membro de biblioteca**: campo, getter, setter ou função de nível
    superior.\
-   **Membro de classe**: construtor, campo, getter, setter, função ou
    operador dentro de uma classe (instância ou estático).\
-   **Membro**: qualquer membro de biblioteca ou de classe.\
-   **Variável**: variáveis de nível superior, parâmetros e variáveis
    locais (não inclui campos).\
-   **Tipo**: classe, typedef ou enum nomeado.\
-   **Propriedade**: variável, getter, setter ou campo (instância ou
    estático).

------------------------------------------------------------------------

## Resumo das Regras

### Estilo

-   **USE** nomes de tipos e extensões com `UpperCamelCase`.\
-   **USE** nomes de pacotes, diretórios e arquivos com
    `lowercase_with_underscores`.\
-   **USE** outros identificadores com `lowerCamelCase`.\
-   **PREFIRA** `lowerCamelCase` para constantes.\
-   **USE** acrônimos com mais de duas letras como palavras.\
-   **PREFIRA** usar `_` para parâmetros não utilizados.\
-   **NÃO** use `_` inicial em identificadores não privados.\
-   **NÃO** use prefixos de letras.\
-   **NÃO** nomeie bibliotecas explicitamente.

------------------------------------------------------------------------

### Ordem

-   **USE** imports `dart:` antes dos outros.\
-   **USE** imports `package:` antes de relativos.\
-   **USE** exports após todos os imports.\
-   **USE** ordenação alfabética.

------------------------------------------------------------------------

### Formatação

-   **USE** `dart format`.\
-   **PREFIRA** linhas até 80 caracteres.\
-   **USE** chaves em todas as declarações de controle de fluxo.

------------------------------------------------------------------------

### Documentação

#### Comentários

-   **USE** frases completas.\
-   **NÃO** use comentários em bloco para documentação.

#### Doc Comments

-   **USE** `///` para documentar membros e tipos.\
-   **PREFIRA** doc comments em APIs públicas.\
-   **CONSIDERE** doc comments em APIs privadas.\
-   **INICIE** com uma frase resumo.\
-   **SEPARE** a primeira frase em seu parágrafo.\
-   **EVITE** redundâncias.\
-   **PREFIRA** verbos na 3ª pessoa para funções.\
-   **PREFIRA** frases nominais para variáveis.\
-   **USE** "Se" para booleanos.\
-   **NÃO** duplique doc em getter/setter.\
-   **CONSIDERE** exemplos de código.\
-   **USE** colchetes `[]` para identificadores.\
-   **COLOQUE** comentários antes de anotações.

------------------------------------------------------------------------

### Markdown

-   **EVITE** excesso de markdown.\
-   **EVITE** HTML.\
-   **PREFIRA** cercas de código com crases.

------------------------------------------------------------------------

### Escrita

-   **PREFIRA** ser breve.\
-   **EVITE** siglas obscuras.\
-   **PREFIRA** "esta" para se referir à instância.

------------------------------------------------------------------------

### Uso

#### Bibliotecas

-   **USE** `part of`.\
-   **NÃO** importe dentro de `src`.\
-   **PREFIRA** caminhos relativos.

#### Null Safety

-   **NÃO** inicialize com `null`.\
-   **EVITE** `late` desnecessário.\
-   **CONSIDERE** checagens de null inteligentes.

#### Strings

-   **USE** literais adjacentes.\
-   **PREFIRA** interpolação.\
-   **EVITE** chaves desnecessárias.

#### Coleções

-   **USE** literais (`[]`, `{}`) sempre que possível.\
-   **NÃO** use `.length` para verificar vazio.\
-   **EVITE** `Iterable.forEach()`.\
-   **USE** `whereType()`.\
-   **EVITE** `cast()` desnecessário.

------------------------------------------------------------------------

### Funções e Variáveis

-   **USE** declaração de função nomeada.\
-   **NÃO** crie lambda quando um tear-off resolve.\
-   **SIGA** padrão consistente para `var` e `final`.\
-   **EVITE** armazenar valores calculáveis.

------------------------------------------------------------------------

### Membros e Construtores

-   **NÃO** envolva campo com getter/setter sem necessidade.\
-   **PREFIRA** `final` para somente leitura.\
-   **USE** `=>` para expressões simples.\
-   **INICIALIZE** campos na declaração.\
-   **NÃO** use `new` ou `const` redundante.

------------------------------------------------------------------------

### Tratamento de Erros

-   **EVITE** `catch` sem `on`.\
-   **NÃO** descarte exceções.\
-   **USE** `rethrow` para relançar.

------------------------------------------------------------------------

### Assincronismo

-   **PREFIRA** `async/await`.\
-   **NÃO** use `async` à toa.\
-   **EVITE** `Completer` diretamente.

------------------------------------------------------------------------

### Design

#### Nomes

-   **USE** termos consistentes.\
-   **EVITE** abreviações.\
-   **PREFIRA** nomes positivos e claros.\
-   **EVITE** prefixo `get`.\
-   **PREFIRA** `to___()` e `as___()`.\
-   **SIGA** convenções mnemônicas.

#### Bibliotecas e Classes

-   **PREFIRA** classes privadas.\
-   **EVITE** classes só com membros estáticos.\
-   **USE** modificadores (`base`, `sealed`, etc.).\
-   **PREFIRA** mixin puro.

#### Construtores

-   **CONSIDERE** `const` se aplicável.

------------------------------------------------------------------------

### Tipos e Parâmetros

-   **ANOTE** tipos quando necessário.\
-   **NÃO** duplique tipo inferido.\
-   **USE** `Future<void>` quando sem retorno.\
-   **EVITE** `FutureOr<T>`.\
-   **NÃO** use typedef antiga.

------------------------------------------------------------------------

### Igualdade

-   **REESCREVA** `hashCode` se reescrever `==`.\
-   **FAÇA** `==` obedecer igualdade matemática.\
-   **EVITE** igualdade customizada em classes mutáveis.\
-   **NÃO** torne `==` anulável.
