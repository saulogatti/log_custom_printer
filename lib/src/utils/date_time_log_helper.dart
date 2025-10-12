extension DateTimeLogHelper on DateTime {
  String onlyTime() {
    String threeDigits(int n) {
      if (n >= 100) return '$n';
      if (n >= 10) return '0$n';
      return '00$n';
    }

    String twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }

    final now = this;
    final h = twoDigits(now.hour);
    final min = twoDigits(now.minute);
    final sec = twoDigits(now.second);
    final ms = threeDigits(now.millisecond);
    return '$h:$min:$sec.$ms';
  }
  String onlyDate() {
    String twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }

    final now = this;
    final day = twoDigits(now.day);
    final month = twoDigits(now.month);
    final year = now.year;
    return '$day/$month/$year';
  }
  String get logFullDateTime => '${onlyDate()} ${onlyTime()}';
}
