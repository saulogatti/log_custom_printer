sealed class LogBaseModel {
  final String message;
  final int createdAtinMillis;
  final String tag;
  const LogBaseModel({required this.message, required this.createdAtinMillis, required this.tag});

  /// Retorna a representação JSON do log.
  Map<String, dynamic> toJson();
}
