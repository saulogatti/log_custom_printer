#!/bin/bash

# Função para buscar o arquivo pubspec.yaml em diretórios de 1 nível
find_pubspec() {
  find . -maxdepth 2 -name "pubspec.yaml"
}

# Função para realizar upgrade das dependências
upgrade_dependencies() {
  pubspec_files=$(find_pubspec)
  echo "Arquivos pubspec.yaml encontrados:"
  echo "$pubspec_files"
  echo "Atualizando dependências para a versão major mais recente..."
  flutter pub upgrade --major-versions
}

# Função para executar build_runner nos caminhos encontrados
run_build_runner() {
  pubspec_files=$(find_pubspec)
  echo "Executando build_runner nos caminhos encontrados:"
  for file in $pubspec_files; do
    dir=$(dirname "$file")
    echo "Executando em: $dir"
    (cd "$dir" && dart run build_runner build --delete-conflicting-outputs)
  done
}

# Verifica argumentos
if [[ "$1" == "-upgrade" ]]; then
  upgrade_dependencies
  exit 0
fi

if [[ "$1" == "-build" ]]; then
  run_build_runner
  exit 0
fi

# Exemplo de uso da função
pubspec_files=$(find_pubspec)
echo "Arquivos pubspec.yaml encontrados:"
echo "$pubspec_files"