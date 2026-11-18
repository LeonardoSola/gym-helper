import 'package:flutter/foundation.dart';

/// The phases a training session goes through.
enum SessionPhase {
  /// Nothing started yet.
  idle,

  /// The user is performing a set. The timer counts up.
  working,

  /// The user is resting between sets. The timer counts down.
  resting,

  /// Rest is over (or an exercise was just completed) and the next set can
  /// start. The timer counts up the time spent waiting.
  ready,
}

/// Pure, UI-independent state of a training session: the rest timer, the set
/// counter and the exercise counter.
///
/// Time is read from an injectable [clock] so the logic can be unit tested
/// without real timers. The owner is expected to call [tick] periodically
/// (a few times per second) so time-based transitions can happen.
class WorkoutSession extends ChangeNotifier {
  WorkoutSession({
    required this.restDuration,
    bool autoRestart = false,
    DateTime Function()? clock,
  })  : assert(restDuration > Duration.zero),
        _autoRestart = autoRestart,
        _clock = clock ?? DateTime.now;

  /// Maximum number of steps kept for [undo].
  static const int maxHistory = 100;

  final Duration restDuration;
  final DateTime Function() _clock;

  SessionPhase _phase = SessionPhase.idle;
  int _sets = 0;
  int _exercises = 0;
  bool _autoRestart;
  DateTime? _phaseStartedAt;
  final List<_Snapshot> _history = [];

  SessionPhase get phase => _phase;

  /// Sets completed in the current exercise.
  int get sets => _sets;

  /// Exercises completed in this session.
  int get exercises => _exercises;

  /// When enabled, the next set starts automatically as soon as rest ends.
  bool get autoRestart => _autoRestart;

  bool get canUndo => _history.isNotEmpty;

  /// Time spent in the current phase.
  Duration get elapsed {
    final start = _phaseStartedAt;
    if (start == null) return Duration.zero;
    final value = _clock().difference(start);
    return value.isNegative ? Duration.zero : value;
  }

  /// Rest time left. Only meaningful while [phase] is [SessionPhase.resting].
  Duration get restRemaining {
    if (_phase != SessionPhase.resting) return Duration.zero;
    final remaining = restDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Fraction of the rest already elapsed, from 0 to 1.
  double get restProgress {
    if (_phase != SessionPhase.resting) return 0;
    final value = elapsed.inMilliseconds / restDuration.inMilliseconds;
    return value.clamp(0.0, 1.0);
  }

  /// The single "big button" action, whose meaning depends on the phase:
  ///
  /// * idle: start the first set;
  /// * working: finish the set (counts it) and start resting;
  /// * resting or ready: start the next set right away.
  void primaryAction() {
    _saveSnapshot();
    switch (_phase) {
      case SessionPhase.idle:
      case SessionPhase.resting:
      case SessionPhase.ready:
        _enter(SessionPhase.working);
      case SessionPhase.working:
        _sets++;
        _enter(SessionPhase.resting);
    }
    notifyListeners();
  }

  /// Marks the current exercise as done and resets the set counter.
  void completeExercise() {
    if (_phase == SessionPhase.idle) return;
    _saveSnapshot();
    _exercises++;
    _sets = 0;
    _enter(SessionPhase.ready);
    notifyListeners();
  }

  void toggleAutoRestart() {
    _autoRestart = !_autoRestart;
    notifyListeners();
  }

  /// Reverts the last [primaryAction] or [completeExercise], including the
  /// phase and its timer, so an accidental tap can be fully corrected.
  void undo() {
    if (_history.isEmpty) return;
    final snapshot = _history.removeLast();
    _phase = snapshot.phase;
    _sets = snapshot.sets;
    _exercises = snapshot.exercises;
    _phaseStartedAt = snapshot.phaseStartedAt;
    notifyListeners();
  }

  /// Applies time-based transitions. Returns `true` exactly once when a rest
  /// period finishes, so the caller can alert the user.
  bool tick() {
    if (_phase != SessionPhase.resting || elapsed < restDuration) return false;

    // Start the next phase at the exact moment rest ended, not at the moment
    // this tick happened to run.
    final restEnd = _phaseStartedAt!.add(restDuration);
    _phase = _autoRestart ? SessionPhase.working : SessionPhase.ready;
    _phaseStartedAt = restEnd;
    notifyListeners();
    return true;
  }

  void _enter(SessionPhase phase) {
    _phase = phase;
    _phaseStartedAt = _clock();
  }

  void _saveSnapshot() {
    _history.add(_Snapshot(_phase, _sets, _exercises, _phaseStartedAt));
    if (_history.length > maxHistory) _history.removeAt(0);
  }
}

@immutable
class _Snapshot {
  const _Snapshot(this.phase, this.sets, this.exercises, this.phaseStartedAt);

  final SessionPhase phase;
  final int sets;
  final int exercises;
  final DateTime? phaseStartedAt;
}

/// Formats a duration for the timer display: `42` below one minute and
/// `1:05` from one minute on.
String formatTimer(Duration duration) {
  final totalSeconds = duration.inSeconds;
  if (totalSeconds < 60) return '$totalSeconds';
  final minutes = totalSeconds ~/ 60;
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

/// Seconds left in a countdown, rounded up so the display reads `1` until the
/// very end and never shows `0` while time is still running.
Duration ceilToSecond(Duration duration) {
  final ms = duration.inMilliseconds;
  return Duration(seconds: (ms + 999) ~/ 1000);
}
