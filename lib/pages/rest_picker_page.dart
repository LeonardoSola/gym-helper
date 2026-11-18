import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gym_helper/pages/session_page.dart';
import 'package:gym_helper/widgets/watch_scaffold.dart';

/// Lets the user pick a custom rest time between 10 and 99 seconds, using
/// one wheel for the tens and one for the units.
class RestPickerPage extends StatefulWidget {
  const RestPickerPage({super.key, this.initialSeconds = 60});

  final int initialSeconds;

  static const int minSeconds = 10;
  static const int maxSeconds = 99;

  @override
  State<RestPickerPage> createState() => _RestPickerPageState();
}

class _RestPickerPageState extends State<RestPickerPage> {
  late int _tens;
  late int _units;
  late final FixedExtentScrollController _tensController;
  late final FixedExtentScrollController _unitsController;

  int get _seconds => _tens * 10 + _units;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSeconds.clamp(
      RestPickerPage.minSeconds,
      RestPickerPage.maxSeconds,
    );
    _tens = initial ~/ 10;
    _units = initial % 10;
    _tensController = FixedExtentScrollController(initialItem: _tens - 1);
    _unitsController = FixedExtentScrollController(initialItem: _units);
  }

  @override
  void dispose() {
    _tensController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  void _start() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => SessionPage(restDuration: Duration(seconds: _seconds)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return WatchScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.biggest.shortestSide;
          final itemExtent = (side * 0.16).clamp(32.0, 56.0);
          final digitStyle = TextStyle(
            fontSize: itemExtent * 0.72,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          );

          return Center(
            child: SizedBox(
              width: side * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: side * 0.08),
                  Text(
                    'REST TIME',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(
                    height: itemExtent * 2.6,
                    child: Row(
                      children: [
                        _Wheel(
                          semanticLabel: 'Tens of seconds',
                          controller: _tensController,
                          itemExtent: itemExtent,
                          values: List.generate(9, (i) => i + 1),
                          style: digitStyle,
                          onChanged: (value) => setState(() => _tens = value),
                        ),
                        _Wheel(
                          semanticLabel: 'Seconds',
                          controller: _unitsController,
                          itemExtent: itemExtent,
                          values: List.generate(10, (i) => i),
                          style: digitStyle,
                          onChanged: (value) => setState(() => _units = value),
                        ),
                        Text(
                          's',
                          style: digitStyle.copyWith(
                            fontSize: itemExtent * 0.45,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: side * 0.02),
                  Semantics(
                    label: 'Start with $_seconds seconds of rest',
                    excludeSemantics: true,
                    child: IconButton.filled(
                      key: const Key('rest-picker-start'),
                      onPressed: _start,
                      iconSize: 30,
                      style: IconButton.styleFrom(
                        minimumSize: const Size.square(52),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Wheel extends StatelessWidget {
  const _Wheel({
    required this.semanticLabel,
    required this.controller,
    required this.itemExtent,
    required this.values,
    required this.style,
    required this.onChanged,
  });

  final String semanticLabel;
  final FixedExtentScrollController controller;
  final double itemExtent;
  final List<int> values;
  final TextStyle style;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Semantics(
        label: semanticLabel,
        child: CupertinoPicker(
          scrollController: controller,
          itemExtent: itemExtent,
          looping: true,
          squeeze: 1.1,
          selectionOverlay: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSelectedItemChanged: (index) => onChanged(values[index]),
          children: [
            for (final value in values)
              Center(child: Text('$value', style: style)),
          ],
        ),
      ),
    );
  }
}
