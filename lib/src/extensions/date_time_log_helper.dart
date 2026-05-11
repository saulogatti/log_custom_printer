/// Extension para formatação de data/hora em logs.
///
/// Fornece métodos utilitários para formatar timestamps de forma consistente
/// nos logs gerados pela biblioteca.
///
/// {@category Utilities}
///
/// Exemplo de uso:
/// ```dart
/// final agora = DateTime.now();
/// print(agora.onlyTime());      // "14:30:25.123"
/// print(agora.onlyDate());      // "18/11/2025"
/// print(agora.logFullDateTime); // "18/11/2025 14:30:25.123"
/// ```
extension DateTimeLoggingExtensions on DateTime {
  /// Retorna a data e hora completas no formato usado nos logs.
  ///
  /// Combina [onlyDate] e [onlyTime] para produzir uma string no formato
  /// "dd/MM/yyyy HH:mm:ss.SSS", ideal para timestamps de log.
  String get logFullDateTime => '${onlyDate()} ${onlyTime()}';

  /// Cria uma cópia deste DateTime com componentes de tempo alterados.
  ///
  /// [hour], [minute] e [second] permitem sobrescrever partes específicas do
  /// horário. Mantém os mesmos valores de ano, mês e dia da instância original.
  DateTime copyWithTime({int? hour, int? minute, int? second}) {
    return DateTime(
      year,
      month,
      day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
    );
  }

  /// Formata apenas a data no formato dd/MM/yyyy.
  ///
  /// Retorna a data atual com dia, mês e ano no formato "dd/MM/yyyy".
  String onlyDate() {
    final now = this;
    final day = twoDigits(now.day);
    final month = twoDigits(now.month);
    final year = now.year;
    return '$day/$month/$year';
  }

  /// Formata apenas a hora no formato HH:mm:ss.SSS.
  ///
  /// Retorna a hora atual com horas, minutos, segundos e milissegundos
  /// no formato "HH:mm:ss.SSS".
  String onlyTime() {
    final now = this;
    final h = twoDigits(now.hour);
    final min = twoDigits(now.minute);
    final sec = twoDigits(now.second);
    final ms = threeDigits(now.millisecond);
    return '$h:$min:$sec.$ms';
  }

  /// Formata um número com 3 dígitos (preenche com zeros à esquerda).
  String threeDigits(int n) {
    return n.toString().padLeft(3, '0');
  }

  /// Formata um número com 2 dígitos (preenche com zeros à esquerda).
  String twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}
