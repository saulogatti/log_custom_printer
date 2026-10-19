// Claude Code PostToolUse hook (see `.claude/settings.json`).
//
// Reads the hook payload from stdin and runs `dart format` on the edited file
// when it is a hand-written `.dart` file. Generated files are skipped.
import 'dart:convert';
import 'dart:io';

const _generatedSuffixes = ['.g.dart', '.freezed.dart', '.mocks.dart'];

Future<void> main() async {
  final payload = jsonDecode(await stdin.transform(utf8.decoder).join());
  if (payload is! Map<String, dynamic>) return;

  final toolInput = payload['tool_input'];
  final filePath = toolInput is Map<String, dynamic> ? toolInput['file_path'] : null;
  if (filePath is! String || !filePath.endsWith('.dart')) return;
  if (_generatedSuffixes.any(filePath.endsWith)) return;
  if (!File(filePath).existsSync()) return;

  final result = await Process.run('dart', ['format', filePath], runInShell: true);
  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    exitCode = result.exitCode;
  }
}
