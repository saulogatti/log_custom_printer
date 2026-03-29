import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/message_repository.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_event.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_state.dart';

class ConsoleBloc extends Bloc<ConsoleEvent, ConsoleState> {
  final MessageRepository _messageRepository;
  ConsoleBloc({required MessageRepository messageRepository})
    : _messageRepository = messageRepository,
      super(const ConsoleInitial()) {
    on<ConsoleEvent>((event, emit) async {
      emit(const ConsoleLoading());
      switch (event) {
        case ConsoleClear():
          _messageRepository.clearMessages();
          emit(ConsoleLoaded(logs: await _messageRepository.getMessages()));
          break;
        case ConsoleLoad():
          emit(ConsoleLoaded(logs: await _messageRepository.getMessages()));
          break;
      }
    });
  }
}
