import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Small `HH:mm` clock shown at the top of every screen.
class TopClock extends StatefulWidget {
  const TopClock({super.key, this.color});

  final Color? color;

  @override
  State<TopClock> createState() => _TopClockState();
}

class _TopClockState extends State<TopClock> {
  static final DateFormat _format = DateFormat('HH:mm');
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          _format.format(DateTime.now()),
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: widget.color ?? theme.colorScheme.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
