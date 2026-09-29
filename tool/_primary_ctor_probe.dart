class Base(final String message, {DateTime? createdAt, Type? typeClass, String? tag}) {
  late String className;

  final String tag = tag ?? typeClass?.toString() ?? '';

  DateTime logCreationDate = createdAt ?? DateTime.now();

  this : assert(message.isNotEmpty, 'Message cannot be empty or whitespace only') {
    className = typeClass?.toString() ?? runtimeType.toString();
  }
}

class Child(super.message, {super.createdAt, super.typeClass}) extends Base {
  factory fromJson() => Child('x');
}

class DeprecatedCtor {
  final String type;

  @Deprecated('Use other')
  new({required this.type});
}

class Err(super.message, final StackTrace stackTrace, {super.createdAt}) extends Base;

final class Persist({
  Object? cacheRepository,
  final Object _filter = const Object(),
  final Object _sort = const Object(),
}) {
  final Object _cache = cacheRepository ?? Object();

  Object get cache => _cache;
  Object get filter => _filter;
  Object get sort => _sort;
}

final class Service(final String printer, {required final bool enabled, Object? cache}) {
  final Object repo = cache ?? Object();
}
