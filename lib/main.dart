import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/console_view/application/application_injection.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/i_options_repository.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/message_repository.dart';
import 'package:log_custom_printer/src/console_view/view/console/console_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initAppInjection();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: ConsoleProvider(
        messageRepository: appGetIt<MessageRepository>(),
        optionsRepository: appGetIt<IOptionsRepository>(),
      ),
    );
  }
}
