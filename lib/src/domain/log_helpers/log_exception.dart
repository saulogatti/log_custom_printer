/// Exceção customizada para falhas relacionadas ao sistema de logs.
///
/// Usada para representar erros de domínio da biblioteca com mensagens
/// semânticas e fáceis de rastrear.
///
/// {@category Utilities}
class LogException implements Exception {

  /// Cria uma nova exceção de log com [message].
  LogException(this.message);
  /// Mensagem descritiva da falha.
  final String message;

  @override
  /// Retorna uma representação legível da exceção.
  String toString() => 'LogException: $message';
}
