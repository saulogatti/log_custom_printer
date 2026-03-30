import 'dart:async';
import 'dart:io';

/// Implementação de gerenciamento de arquivos tipado por [FileType].
///
/// A extensão do [path] é validada em todas as operações para garantir que
/// o tipo de arquivo manipulado seja compatível com [fileType].
///
/// {@category Utilities}
class FileManager implements IFileManagerType {
  /// Tipo de arquivo permitido para esta instância.
  final FileType fileType;

  /// Cadeia de execução por caminho para serializar operações concorrentes.
  final Map<String, Future<void>> _pathLocks = {};

  /// Cria um gerenciador de arquivos para o [fileType] informado.
  FileManager({required this.fileType});

  @override
  Future<bool> createDirectory(String path) {
    return _runWithPathLock(path, () async {
      final directory = Directory(path);
      if (await directory.exists()) {
        return false;
      }
      await directory.create(recursive: true);
      return true;
    });
  }

  /// Remove o diretório em [path] quando ele existir.
  ///
  /// Retorna `true` quando a remoção acontece e `false` quando o diretório não
  /// existe.
  @override
  Future<bool> deleteDirectory(String path) {
    return _runWithPathLock(path, () async {
      final directory = Directory(path);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        return true;
      }
      return false;
    });
  }

  /// Remove o arquivo em [path] quando ele existir.
  ///
  /// Retorna `true` quando a remoção acontece e `false` quando o arquivo não
  /// existe.
  @override
  Future<bool> deleteFile(String path) {
    return _runWithPathLock(path, () async {
      _extensionIncludePath(path);
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    });
  }

  /// Lê e retorna o conteúdo do arquivo em [path].
  ///
  /// Para [FileType.log], o arquivo é lido como bytes e convertido para
  /// `String`. Para os demais tipos, a leitura é feita como texto.
  ///
  /// Lança [Exception] quando o arquivo não é encontrado.
  @override
  Future<String> readFile(String path) {
    return _runWithPathLock(path, () async {
      _extensionIncludePath(path);
      final file = File(path);
      if (await file.exists()) {
        if (fileType == FileType.log) {
          final bytes = await file.readAsBytes();
          return String.fromCharCodes(bytes);
        }
        final res = await file.readAsString();
        return res;
      }
      throw Exception('File not found: $path');
    });
  }

  /// Escreve [content] no arquivo em [path].
  ///
  /// Para [FileType.log], o conteúdo é anexado ao arquivo usando
  /// [FileMode.append]. Para os demais tipos, o conteúdo sobrescreve o arquivo.
  ///
  /// Retorna `true` após concluir a escrita.
  @override
  Future<bool> writeFile(String path, String content) {
    return _runWithPathLock(path, () async {
      _extensionIncludePath(path);
      final file = File(path);
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      if (fileType == FileType.log) {
        await file.writeAsBytes(content.codeUnits, mode: FileMode.append);
      } else {
        await file.writeAsString(content);
      }
      return true;
    });
  }

  /// Valida se o [path] termina com a extensão suportada por [fileType].
  ///
  /// Lança [Exception] quando a extensão não corresponde.
  void _extensionIncludePath(String path) {
    assert(path.isNotEmpty, 'O caminho do arquivo não pode ser vazio.');

    final extension = path.split('.').last;
    if (extension != fileType.name) {
      throw Exception('Invalid file extension: $extension');
    }
  }

  /// Executa [operation] de forma serializada por [path].
  ///
  /// Operações em caminhos diferentes podem ocorrer em paralelo, mas no mesmo
  /// caminho são executadas em sequência para evitar condições de corrida.
  Future<T> _runWithPathLock<T>(
    String path,
    Future<T> Function() operation,
  ) async {
    final key = path.trim();
    final previous = _pathLocks[key] ?? Future<void>.value();
    final completer = Completer<void>();
    final current = previous.then((_) => completer.future);
    _pathLocks[key] = current;

    await previous;
    try {
      return await operation();
    } finally {
      if (!completer.isCompleted) {
        completer.complete();
      }
      if (identical(_pathLocks[key], current)) {
        _pathLocks.remove(key);
      }
    }
  }
}

/// Tipos de arquivo suportados pelo [FileManager].
///
/// Cada valor representa a extensão esperada no caminho do arquivo.
///
/// {@category Utilities}
enum FileType {
  /// Arquivo de texto simples (`.txt`).
  txt,

  /// Arquivo JSON (`.json`).
  json,

  /// Arquivo de log (`.log`).
  log,
}

/// Contrato para operações de leitura, escrita e remoção de arquivos.
///
/// {@category Utilities}
abstract interface class IFileManagerType {
  /// Cria um diretório em [path] se ele não existir.
  ///
  /// Retorna `true` quando o diretório foi criado e `false`
  /// quando o diretório já existia.

  Future<bool> createDirectory(String path);

  /// Remove o diretório em [path], se existir.
  ///
  /// Retorna `true` quando o diretório foi removido e `false`
  /// quando o diretório não existe.
  Future<bool> deleteDirectory(String path);

  /// Remove o arquivo em [path].
  ///
  /// Retorna `true` quando o arquivo é removido.
  Future<bool> deleteFile(String path);

  /// Lê e retorna o conteúdo do arquivo em [path].
  ///
  /// Lança [Exception] quando o arquivo não é encontrado.
  Future<String> readFile(String path);

  /// Escreve [content] no arquivo em [path].
  ///
  /// Retorna `true` quando a operação é concluída com sucesso.
  Future<bool> writeFile(String path, String content);
}
