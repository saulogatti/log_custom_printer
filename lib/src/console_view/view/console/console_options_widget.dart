import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/options/options_bloc.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/options/options_state.dart';
import 'package:log_custom_printer/src/console_view/view/widgets/date_time_filter_widget.dart';
import 'package:log_custom_printer/src/console_view/view/widgets/select_option_widget.dart';

class ConsoleOptionsWidget extends StatefulWidget {
  const ConsoleOptionsWidget({super.key});

  @override
  State<ConsoleOptionsWidget> createState() => _ConsoleOptionsWidgetState();
}

class _ConsoleOptionsWidgetState extends State<ConsoleOptionsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opções do Console'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: BlocBuilder<OptionsBloc, OptionsState>(
        builder: (context, state) {
          switch (state) {
            case ErrorOptionsState():
              return Center(
                child: Text('Erro ao carregar opções: ${(state).message}'),
              );
            case InitialOptionsState():
            case LoadingOptionsState():
              return const Center(child: CircularProgressIndicator());
            case LoadedOptionsState():
              final options = state.options;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: DateTimeFilterWidget(
                        selectedDateTimeRange: options.selectedDateTimeRange,
                        isEnabled: options.isDateTimeFilterEnabled,
                        onChanged: (range, enabled) async {
                          final optionsBloc = context.read<OptionsBloc>();

                          if (range != null &&
                              range != options.selectedDateTimeRange) {
                            await optionsBloc.selectDateTimeRange(range);
                          }

                          if (enabled != options.isDateTimeFilterEnabled) {
                            await optionsBloc.setDateTimeFilterEnabled(enabled);
                          }
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Text(
                        'Opções adicionais',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    sliver: SelectOptionWidget(
                      options: options.options,
                      onOptionSelected: (option) =>
                          context.read<OptionsBloc>().selectOption(option),
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<OptionsBloc>().loadOptions();
  }
}
