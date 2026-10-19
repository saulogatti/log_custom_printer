// ignore_for_file: document_ignores, avoid_print

import 'dart:io';

import 'package:log_custom_printer/log_custom_printer.dart';

/// Example of how to use the log_custom_printer package.
void main(List<String> arguments) {
  print('Hello world: ${plogger.logStream}!');

  /// Listen to the log stream and print the logs to the console.
  plogger.logStream.listen((log) {
    print(log.message);
  });

  /// Create a new person and say hello.
  final person = Person(name: 'John', age: 20);
  person.sayHello();

  /// Create a new person2 and say hello.
  final person2 = Person2(name: 'Jane', age: 21);
  person2.sayHello();

  /// Create a new person3 and say hello.
  final person3 = Person3(name: 'Jim', age: 22);
  person3.sayHello();
}

final LoggerPersistenceService plogger = registerLogPrinterColor(
  config: const ConfigLog(enableLog: true),
  cacheFilePath: '${Directory.current.path}/logs.json',
);

/// Example of how to use the LoggerClassMixin to log messages.
class Person with LoggerClassMixin {
  /// The name of the person.
  final String name;
  final int age;

  /// The age of the person.
  Person({required this.name, required this.age});

  /// Say hello to the person.
  void sayHello() {
    logInfo('Hello, my name is $name and I am $age years old');
  }
}

/// Example of how to use the LoggerClassMixin to log messages.
class Person2 extends Person {
  Person2({required super.name, required super.age});

  /// Say hello to the person.
  @override
  @override
  void sayHello() {
    logWarning('Hello, my name is $name and I am $age years old');
  }
}

class Person3 extends Person {
  Person3({required super.name, required super.age});
  @override
  void sayHello() {
    logDebug('Hello, my name is $name and I am $age years old');

    /// Try to throw an error and log it.
    try {
      throw Exception('Error');
    } catch (e, stackTrace) {
      logError('Error', stackTrace, object: this);
    }
  }
}
