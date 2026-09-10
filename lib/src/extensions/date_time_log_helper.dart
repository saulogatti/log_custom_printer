/// Date/time formatting extension for log timestamps.
///
/// {@category Utilities}
extension DateTimeLoggingExtensions on DateTime {
  /// Full timestamp in log format: `dd/MM/yyyy HH:mm:ss.SSS`.
  String get logFullDateTime => '${onlyDate()} ${onlyTime()}';

  /// Returns a copy with optional time-component overrides.
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

  /// Formats date as `dd/MM/yyyy`.
  String onlyDate() {
    final now = this;
    final day = twoDigits(now.day);
    final month = twoDigits(now.month);
    final year = now.year;
    return '$day/$month/$year';
  }

  /// Formats time as `HH:mm:ss.SSS`.
  String onlyTime() {
    final now = this;
    final h = twoDigits(now.hour);
    final min = twoDigits(now.minute);
    final sec = twoDigits(now.second);
    final ms = threeDigits(now.millisecond);
    return '$h:$min:$sec.$ms';
  }

  /// Formats a number to 3 digits with left zero padding.
  String threeDigits(int n) {
    return n.toString().padLeft(3, '0');
  }

  /// Formats a number to 2 digits with left zero padding.
  String twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}
