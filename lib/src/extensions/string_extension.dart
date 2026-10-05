/// Characters that are not allowed in file names.
final regexFileName = RegExp(r'[<>:"/\\|?*\x00-\x1F\x7F]');

/// String helper extensions.
///
/// {@category Utilities}
extension StringExtension on String {
  /// Trims and converts text to lower case.
  String get formattedName => trim().toLowerCase();

  /// Replaces invalid file-name characters with `_`.
  String get sanitizedFileName => replaceAll(regexFileName, '_');
}
