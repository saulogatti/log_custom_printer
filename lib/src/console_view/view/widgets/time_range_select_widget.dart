import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/console_view/view/widgets/text_values_dropdown_widget.dart';
import 'package:log_custom_printer/src/extensions/date_time_log_helper.dart';

/// Widget reutilizável para selecionar um intervalo de horário (início/fim).
///
/// O componente retorna os valores em [DateTimeRange], considerando somente
/// hora, minuto e segundo. Caso não receba valores iniciais, inicia com o
/// horário atual.
class TimeRangeSelectWidget extends StatelessWidget {
  final String label;

  final DateTimeRange? initialDateTimeRange;
  final ValueChanged<DateTimeRange?> onTimeRangeSelected;

  const TimeRangeSelectWidget({
    required this.label,
    required this.onTimeRangeSelected,
    this.initialDateTimeRange,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Row(
        children: [
          Text(label),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              final base = initialDateTimeRange?.start ?? DateTime.now();
              final picked = await Navigator.of(context).push<DateTimeRange>(
                MaterialPageRoute(
                  builder: (_) => _TimeRangePickerFullscreen(
                    initialDateTimeRange: DateTimeRange(
                      start: base,
                      end: initialDateTimeRange?.end ?? base,
                    ),
                  ),
                ),
              );
              onTimeRangeSelected(picked);
            },
            child: Text(_buttonLabel(context)),
          ),
        ],
      ),
    );
  }

  String _buttonLabel(BuildContext context) {
    if (initialDateTimeRange == null) {
      return 'Selecionar';
    }

    final start = initialDateTimeRange?.start ?? DateTime.now();
    final end = initialDateTimeRange?.end ?? start;

    final startLabel = start.formatLocalizedTimeWithSeconds(context, start);
    final endLabel = end.formatLocalizedTimeWithSeconds(context, end);
    return '$startLabel - $endLabel';
  }
}

class _TimeAndSecondsCard extends StatelessWidget {
  final String title;
  final String value;
  final String selectedSecond;
  final List<String> secondOptions;
  final String? helpText;
  final VoidCallback onTapSelectTime;
  final ValueChanged<String> onSecondsChanged;

  const _TimeAndSecondsCard({
    required this.title,
    required this.value,
    required this.selectedSecond,
    required this.secondOptions,
    required this.onTapSelectTime,
    required this.onSecondsChanged,
    this.helpText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(value),
              trailing: const Icon(Icons.schedule),
              onTap: onTapSelectTime,
            ),
            const SizedBox(height: 8),
            TextValuesDropdownWidget(
              label: 'Segundos',
              values: secondOptions,
              selectedValue: selectedSecond,
              onChanged: onSecondsChanged,
            ),
            if (helpText != null) ...[
              const SizedBox(height: 8),
              Text(
                helpText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimeRangePickerFullscreen extends StatefulWidget {
  final DateTimeRange initialDateTimeRange;

  const _TimeRangePickerFullscreen({required this.initialDateTimeRange});

  @override
  State<_TimeRangePickerFullscreen> createState() =>
      _TimeRangePickerFullscreenState();
}

class _TimeRangePickerFullscreenState
    extends State<_TimeRangePickerFullscreen> {
  late DateTime _startDateTime;
  late DateTime _endDateTime;
  String? _endHelpText;
  late final List<String> _secondOptions;

  bool get _isValidRange => !_endDateTime.isBefore(_startDateTime);

  @override
  Widget build(BuildContext context) {
    final startLabel = _startDateTime.formatLocalizedTimeWithSeconds(
      context,
      _startDateTime,
    );
    final endLabel = _endDateTime.formatLocalizedTimeWithSeconds(
      context,
      _endDateTime,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar intervalo de horário'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TimeAndSecondsCard(
              title: 'Início',
              value: startLabel,
              selectedSecond: _secondsToText(_startDateTime.second),
              secondOptions: _secondOptions,
              onTapSelectTime: _pickStartTime,
              onSecondsChanged: _onStartSecondsChanged,
            ),
            const SizedBox(height: 12),
            _TimeAndSecondsCard(
              title: 'Fim',
              value: endLabel,
              selectedSecond: _secondsToText(_endDateTime.second),
              secondOptions: _secondOptions,
              helpText: _endHelpText,
              onTapSelectTime: _pickEndTime,
              onSecondsChanged: _onEndSecondsChanged,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (!_isValidRange) {
                  _showInvalidEndFeedback(reopenPicker: false);
                  return;
                }
                Navigator.of(
                  context,
                ).pop(DateTimeRange(start: _startDateTime, end: _endDateTime));
              },
              child: const Text('Confirmar intervalo'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _secondOptions = _buildSecondOptions();

    final start = widget.initialDateTimeRange.start;
    _startDateTime = _normalizeDateTime(start);

    final end = widget.initialDateTimeRange.end;
    _endDateTime = DateTime(
      start.year,
      start.month,
      start.day,
      end.hour,
      end.minute,
      end.second.clamp(0, 59),
    );

    if (!_isValidRange) {
      _endDateTime = _startDateTime;
    }
  }

  Future<void> _applyEndDateTime(
    DateTime candidate, {
    required bool reopenPickerOnInvalid,
  }) async {
    if (candidate.isBefore(_startDateTime)) {
      await _showInvalidEndFeedback(reopenPicker: reopenPickerOnInvalid);
      return;
    }

    if (!mounted) return;
    setState(() {
      _endDateTime = candidate;
      _endHelpText = null;
    });
  }

  List<String> _buildSecondOptions() {
    return List.generate(60, (index) => _secondsToText(index));
  }

  DateTime _normalizeDateTime(DateTime value) {
    return DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
      value.second.clamp(0, 59),
    );
  }

  void _onEndSecondsChanged(String value) {
    final seconds = int.tryParse(value);
    if (seconds == null) return;

    final candidate = _endDateTime.copyWithTime(second: seconds);
    _applyEndDateTime(candidate, reopenPickerOnInvalid: true);
  }

  void _onStartSecondsChanged(String value) {
    final seconds = int.tryParse(value);
    if (seconds == null) return;

    setState(() {
      _startDateTime = _startDateTime.copyWithTime(second: seconds);
      _endHelpText = null;
    });

    if (!_isValidRange) {
      _showInvalidEndFeedback(reopenPicker: true);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endDateTime),
    );

    if (picked == null || !mounted) {
      _endDateTime = _startDateTime;
      return;
    }

    final candidate = _endDateTime.copyWithTime(
      hour: picked.hour,
      minute: picked.minute,
    );
    await _applyEndDateTime(candidate, reopenPickerOnInvalid: true);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDateTime),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _startDateTime = _startDateTime.copyWithTime(
        hour: picked.hour,
        minute: picked.minute,
      );
      _endHelpText = null;
    });

    if (!_isValidRange) {
      await _showInvalidEndFeedback(reopenPicker: true);
    }
  }

  String _secondsToText(int seconds) {
    return seconds.toString().padLeft(2, '0');
  }

  Future<void> _showInvalidEndFeedback({required bool reopenPicker}) async {
    if (!mounted) return;

    const message =
        'Horário final inválido. Ele deve ser maior ou igual ao inicial.';

    setState(() {
      _endHelpText = message;
    });

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(message)));

    if (!reopenPicker) return;

    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _pickEndTime();
    });
  }
}
