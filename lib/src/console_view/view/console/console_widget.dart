import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_bloc.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_state.dart';
import 'package:log_custom_printer/src/console_view/view/widgets/log_card_widget.dart';

class ConsoleWidget extends StatelessWidget {
  const ConsoleWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(200),
      padding: const EdgeInsets.all(8.0),
      child: BlocBuilder<ConsoleBloc, ConsoleState>(
        builder: (context, state) {
          switch (state) {
            case ConsoleInitial():
            case ConsoleLoading():
              return const Center(child: CircularProgressIndicator());
            case ConsoleError():
              return Center(child: Text(state.message));
            case ConsoleLoaded():
              final snapshot = state.logs;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Text('Total de logs: ${snapshot.length}'),
                  ),
                  SliverList.separated(
                    itemBuilder: ((context, index) {
                      final logObject = snapshot[index];

                      return LogCardWidget(messageLog: logObject);
                    }),
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: snapshot.length,
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}
