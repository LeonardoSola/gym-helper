import 'package:flutter/material.dart';
import 'package:gym_helper/pages/rest_picker_page.dart';
import 'package:gym_helper/pages/session_page.dart';
import 'package:gym_helper/widgets/circle_button.dart';
import 'package:gym_helper/widgets/watch_scaffold.dart';

/// First screen: pick how long to rest between sets.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<int> presets = [30, 40, 50];

  void _start(BuildContext context, int seconds) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SessionPage(restDuration: Duration(seconds: seconds)),
      ),
    );
  }

  void _openPicker(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const RestPickerPage()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WatchScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Keep the grid inside the square inscribed in a round screen.
          final side = constraints.biggest.shortestSide * 0.74;
          final gap = side * 0.06;
          final buttonSize = (side - gap) / 2;

          return Center(
            child: SizedBox.square(
              dimension: side,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final row in [
                    [presets[0], presets[1]],
                    [presets[2], null],
                  ])
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final seconds in row)
                          SizedBox.square(
                            dimension: buttonSize,
                            child: seconds == null
                                ? CircleButton(
                                    semanticLabel: 'Custom rest time',
                                    tonal: true,
                                    onPressed: () => _openPicker(context),
                                    child: Icon(
                                      Icons.tune_rounded,
                                      size: buttonSize * 0.38,
                                    ),
                                  )
                                : CircleButton(
                                    semanticLabel: 'Rest $seconds seconds',
                                    onPressed: () => _start(context, seconds),
                                    child: _PresetLabel(
                                      seconds: seconds,
                                      size: buttonSize,
                                      unitStyle: theme.textTheme.labelSmall,
                                    ),
                                  ),
                          ),
                      ],
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

class _PresetLabel extends StatelessWidget {
  const _PresetLabel({
    required this.seconds,
    required this.size,
    required this.unitStyle,
  });

  final int seconds;
  final double size;
  final TextStyle? unitStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$seconds',
          style: TextStyle(
            fontSize: size * 0.34,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        Text('sec', style: unitStyle?.copyWith(fontSize: size * 0.13)),
      ],
    );
  }
}
