import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/console_view/view/widgets/text_values_dropdown_widget.dart';

DateTime _copyWithTime(DateTime base, {int? hour, int? minute, int? second}) {
  return DateTime(
    base.year,
    base.month,
    base.day,
    hour ?? base.hour,
    minute ?? base.minute,
    second ?? base.second,
  );
}

String _formatLocalizedTimeWithSeconds(BuildContext context, DateTime value) {
  final localizations = MaterialLocalizations.of(context);
  final use24h = MediaQuery.alwaysUse24HourFormatOf(context);
  final formattedTime = localizations.formatTimeOfDay(
    TimeOfDay.fromDateTime(value),
    alwaysUse24HourFormat: use24h,
  );
  final seconds = value.second.toString().padLeft(2, '0');
  return '$formattedTime • ${seconds}s';
}

/// Widget reutilizável para selecionar um intervalo de horário (início/fim).
///
/// O componente retorna os valores em [DateTimeRange], considerando somente
/// hora, minuto e segundo. Caso não receba valores iniciais, inicia com o
/// horário atual.
class TimeRangeSelectWidget extends StatelessWidget {
  final String label;
  final DateTime? initialStartDateTime;
  final DateTime? initialEndDateTime;
  final ValueChanged<DateTimeRange?> onTimeRangeSelected;

  const TimeRangeSelectWidget({
    required this.label,
    required this.onTimeRangeSelected,
    this.initialStartDateTime,
    this.initialEndDateTime,
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
              final base = initialStartDateTime ?? DateTime.now();
              final picked = await Navigator.of(context).push<DateTimeRange>(
                MaterialPageRoute(
                  builder: (_) => _TimeRangePickerFullscreen(
                    initialStartDateTime: base,
                    initialEndDateTime: initialEndDateTime ?? base,
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
    if (initialStartDateTime == null && initialEndDateTime == null) {
      return 'Selecionar';
    }

    final start = initialStartDateTime ?? DateTime.now();
    final end = initialEndDateTime ?? start;

    final startLabel = _formatTimeWithSeconds(context, start);
    final endLabel = _formatTimeWithSeconds(context, end);
    return '$startLabel - $endLabel';
  }

  String _formatTimeWithSeconds(BuildContext context, DateTime value) {
    return _formatLocalizedTimeWithSeconds(context, value);
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
  final DateTime initialStartDateTime;
  final DateTime initialEndDateTime;

  const _TimeRangePickerFullscreen({
    required this.initialStartDateTime,
    required this.initialEndDateTime,
  });

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
    final startLabel = _formatTimeWithSeconds(_startDateTime);
    final endLabel = _formatTimeWithSeconds(_endDateTime);

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

    final start = widget.initialStartDateTime;
    _startDateTime = _normalizeDateTime(start);

    final end = widget.initialEndDateTime;
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

  String _formatTimeWithSeconds(DateTime value) {
    return _formatLocalizedTimeWithSeconds(context, value);
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

    final candidate = _copyWithTime(_endDateTime, second: seconds);
    _applyEndDateTime(candidate, reopenPickerOnInvalid: true);
  }

  void _onStartSecondsChanged(String value) {
    final seconds = int.tryParse(value);
    if (seconds == null) return;

    setState(() {
      _startDateTime = _copyWithTime(_startDateTime, second: seconds);
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

    final candidate = _copyWithTime(
      _endDateTime,
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
      _startDateTime = _copyWithTime(
        _startDateTime,
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

    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    await _pickEndTime();
  }
}
