import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym_helper/models/workout_session.dart';
import 'package:gym_helper/theme/app_theme.dart';
import 'package:gym_helper/utils/haptics.dart';
import 'package:gym_helper/widgets/rest_ring.dart';
import 'package:gym_helper/widgets/round_icon_button.dart';
import 'package:gym_helper/widgets/watch_scaffold.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// The training screen. The whole display is one big button that alternates
/// between "set" and "rest"; small controls on the sides complete an
/// exercise, toggle auto-restart and undo the last tap.
class SessionPage extends StatefulWidget {
  const SessionPage({super.key, required this.restDuration, this.clock});

  final Duration restDuration;

  /// Time source, overridable in tests.
  final DateTime Function()? clock;

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  /// How often the display refreshes. Shorter than a second so the countdown
  /// never visibly lags behind the real time.
  static const Duration _refreshInterval = Duration(milliseconds: 200);

  late final WorkoutSession _session;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _session = WorkoutSession(
      restDuration: widget.restDuration,
      clock: widget.clock,
    );
    _ticker = Timer.periodic(_refreshInterval, (_) => _onTick());
    // Keep the screen on for the whole session. Not supported everywhere
    // (for example in tests), which is fine.
    WakelockPlus.enable().catchError((Object _) {});
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _session.dispose();
    WakelockPlus.disable().catchError((Object _) {});
    super.dispose();
  }

  void _onTick() {
    if (!mounted) return;
    if (_session.tick()) Haptics.restFinished();
    setState(() {});
  }

  void _run(VoidCallback action) {
    Haptics.tap();
    setState(action);
  }

  @override
  Widget build(BuildContext context) {
    final phase = _session.phase;
    final colors = PhaseColors.of(context, phase);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      color: colors.background,
      child: WatchScaffold(
        backgroundColor: Colors.transparent,
        clockColor: colors.foreground.withValues(alpha: 0.7),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final side = constraints.biggest.shortestSide;
            final controlSize = (side * 0.22).clamp(48.0, 64.0);

            return Stack(
              fit: StackFit.expand,
              children: [
                if (phase == SessionPhase.resting)
                  RestRing(
                    progress: _session.restProgress,
                    color: colors.accent,
                    strokeWidth: (side * 0.03).clamp(4.0, 8.0),
                  ),
                Semantics(
                  button: true,
                  label: _primaryActionLabel(phase),
                  child: InkWell(
                    key: const Key('session-primary'),
                    hoverColor: Colors.transparent,
                    onTap: () => _run(_session.primaryAction),
                    child: const SizedBox.expand(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: side * 0.06),
                  child: Row(
                    children: [
                      _sideSlot(
                        controlSize,
                        RoundIconButton(
                          key: const Key('session-exercise'),
                          tooltip:
                              'Exercises done: ${_session.exercises}. '
                              'Finish this exercise',
                          size: controlSize,
                          color: colors.foreground,
                          onPressed: () => _run(_session.completeExercise),
                          child: _ExerciseCount(count: _session.exercises),
                        ),
                      ),
                      Expanded(
                        child: IgnorePointer(
                          child: _SessionDisplay(
                            session: _session,
                            colors: colors,
                            size: side,
                          ),
                        ),
                      ),
                      _sideSlot(
                        controlSize,
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RoundIconButton(
                              key: const Key('session-auto-restart'),
                              tooltip: 'Start next set automatically',
                              size: controlSize,
                              color: colors.foreground,
                              selected: _session.autoRestart,
                              onPressed: () => _run(_session.toggleAutoRestart),
                              child: const Icon(Icons.repeat_rounded),
                            ),
                            SizedBox(height: side * 0.03),
                            RoundIconButton(
                              key: const Key('session-undo'),
                              tooltip: 'Undo last tap',
                              size: controlSize,
                              color: colors.foreground,
                              onPressed: _session.canUndo
                                  ? () => _run(_session.undo)
                                  : null,
                              child: const Icon(Icons.undo_rounded),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Side controls are hidden until the session starts, but keep their space
  /// so the centre content does not jump.
  Widget _sideSlot(double size, Widget child) {
    final visible = _session.phase != SessionPhase.idle;
    return SizedBox(
      width: size,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: IgnorePointer(ignoring: !visible, child: child),
      ),
    );
  }

  static String _primaryActionLabel(SessionPhase phase) => switch (phase) {
    SessionPhase.idle => 'Start first set',
    SessionPhase.working => 'Finish set and rest',
    SessionPhase.resting => 'Skip rest and start next set',
    SessionPhase.ready => 'Start next set',
  };
}

class _ExerciseCount extends StatelessWidget {
  const _ExerciseCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: AppTheme.timerStyle(22).copyWith(letterSpacing: 0),
            ),
            const SizedBox(height: 2),
            const Text(
              'EX',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centre of the session screen: phase label, timer and set count.
class _SessionDisplay extends StatelessWidget {
  const _SessionDisplay({
    required this.session,
    required this.colors,
    required this.size,
  });

  final WorkoutSession session;
  final PhaseColors colors;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phase = session.phase;
    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      color: colors.accent,
      fontWeight: FontWeight.w800,
      letterSpacing: 2,
      fontSize: size * 0.07,
    );
    final timerStyle = AppTheme.timerStyle(
      size * 0.26,
    ).copyWith(color: colors.foreground);
    final setsStyle = theme.textTheme.titleMedium?.copyWith(
      color: colors.foreground.withValues(alpha: 0.85),
      fontSize: size * 0.075,
    );

    if (phase == SessionPhase.idle) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'REST ${formatTimer(session.restDuration)}s',
              style: labelStyle,
            ),
            Icon(
              Icons.play_arrow_rounded,
              size: size * 0.3,
              color: colors.accent,
            ),
            Text('Tap to start', style: setsStyle),
          ],
        ),
      );
    }

    final (label, time) = switch (phase) {
      SessionPhase.working => ('GO', formatTimer(session.elapsed)),
      SessionPhase.resting => (
        'REST',
        formatTimer(ceilToSecond(session.restRemaining)),
      ),
      SessionPhase.ready => ('READY', '+${formatTimer(session.elapsed)}'),
      SessionPhase.idle => throw StateError('handled above'),
    };
    final sets = session.sets;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, key: const Key('session-phase'), style: labelStyle),
          SizedBox(height: size * 0.02),
          Text(time, key: const Key('session-timer'), style: timerStyle),
          SizedBox(height: size * 0.03),
          Text.rich(
            key: const Key('session-sets'),
            TextSpan(
              children: [
                TextSpan(
                  text: '$sets',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(text: sets == 1 ? ' set' : ' sets'),
              ],
            ),
            style: setsStyle,
          ),
        ],
      ),
    );
  }
}
