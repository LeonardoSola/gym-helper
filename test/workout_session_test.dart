import 'package:flutter_test/flutter_test.dart';
import 'package:gym_helper/models/workout_session.dart';

/// A controllable clock for deterministic timing tests.
class FakeClock {
  DateTime now = DateTime(2026, 1, 1, 8);

  void advance(Duration duration) => now = now.add(duration);
}

void main() {
  late FakeClock clock;
  late WorkoutSession session;

  setUp(() {
    clock = FakeClock();
    session = WorkoutSession(
      restDuration: const Duration(seconds: 40),
      clock: () => clock.now,
    );
  });

  test('starts idle with empty counters', () {
    expect(session.phase, SessionPhase.idle);
    expect(session.sets, 0);
    expect(session.exercises, 0);
    expect(session.elapsed, Duration.zero);
    expect(session.canUndo, isFalse);
  });

  test('first tap starts a set and the timer counts up', () {
    session.primaryAction();
    clock.advance(const Duration(seconds: 12));

    expect(session.phase, SessionPhase.working);
    expect(session.elapsed, const Duration(seconds: 12));
    expect(session.sets, 0);
  });

  test('tapping while working counts the set and starts resting', () {
    session.primaryAction();
    clock.advance(const Duration(seconds: 30));
    session.primaryAction();

    expect(session.phase, SessionPhase.resting);
    expect(session.sets, 1);
    expect(session.restRemaining, const Duration(seconds: 40));

    clock.advance(const Duration(seconds: 15));
    expect(session.restRemaining, const Duration(seconds: 25));
    expect(session.restProgress, closeTo(15 / 40, 0.0001));
  });

  test('rest ends exactly once and moves to ready', () {
    session
      ..primaryAction()
      ..primaryAction();

    clock.advance(const Duration(seconds: 39));
    expect(session.tick(), isFalse);
    expect(session.phase, SessionPhase.resting);

    clock.advance(const Duration(seconds: 3));
    expect(session.tick(), isTrue);
    expect(session.phase, SessionPhase.ready);
    // Ready time is measured from the moment rest ended.
    expect(session.elapsed, const Duration(seconds: 2));

    expect(session.tick(), isFalse);
  });

  test('auto restart goes straight to the next set', () {
    session
      ..toggleAutoRestart()
      ..primaryAction()
      ..primaryAction();
    clock.advance(const Duration(seconds: 41));

    expect(session.tick(), isTrue);
    expect(session.phase, SessionPhase.working);
    expect(session.elapsed, const Duration(seconds: 1));
    expect(session.sets, 1);
  });

  test('tapping during rest skips it without counting a set', () {
    session
      ..primaryAction()
      ..primaryAction();
    clock.advance(const Duration(seconds: 10));
    session.primaryAction();

    expect(session.phase, SessionPhase.working);
    expect(session.sets, 1);
    expect(session.elapsed, Duration.zero);
  });

  test('completing an exercise resets sets and waits for the next one', () {
    session
      ..primaryAction()
      ..primaryAction()
      ..primaryAction()
      ..primaryAction();
    expect(session.sets, 2);

    session.completeExercise();

    expect(session.exercises, 1);
    expect(session.sets, 0);
    expect(session.phase, SessionPhase.ready);
  });

  test('completing an exercise is ignored before the session starts', () {
    session.completeExercise();

    expect(session.exercises, 0);
    expect(session.phase, SessionPhase.idle);
    expect(session.canUndo, isFalse);
  });

  group('undo', () {
    test('reverts an accidental tap, keeping the original set timer', () {
      session.primaryAction();
      clock.advance(const Duration(seconds: 20));
      session.primaryAction(); // accidental: set was not finished
      clock.advance(const Duration(seconds: 3));

      session.undo();

      expect(session.phase, SessionPhase.working);
      expect(session.sets, 0);
      expect(session.elapsed, const Duration(seconds: 23));
    });

    test('restores the set count of a completed exercise', () {
      session
        ..primaryAction()
        ..primaryAction()
        ..primaryAction()
        ..primaryAction()
        ..primaryAction(); // working on the 3rd set
      session.completeExercise();

      session.undo();

      expect(session.exercises, 0);
      expect(session.sets, 2);
      expect(session.phase, SessionPhase.working);
    });

    test('steps back through history until the start', () {
      session
        ..primaryAction()
        ..primaryAction();

      session.undo();
      session.undo();

      expect(session.phase, SessionPhase.idle);
      expect(session.canUndo, isFalse);

      session.undo(); // no-op
      expect(session.phase, SessionPhase.idle);
    });

    test('keeps a bounded history', () {
      for (var i = 0; i < WorkoutSession.maxHistory + 20; i++) {
        session.primaryAction();
      }
      var steps = 0;
      while (session.canUndo) {
        session.undo();
        steps++;
      }
      expect(steps, WorkoutSession.maxHistory);
    });
  });

  test('notifies listeners on every state change', () {
    var notifications = 0;
    session.addListener(() => notifications++);

    session
      ..primaryAction()
      ..toggleAutoRestart()
      ..completeExercise()
      ..undo();

    expect(notifications, 4);
  });

  group('formatTimer', () {
    test('shows plain seconds below one minute', () {
      expect(formatTimer(Duration.zero), '0');
      expect(formatTimer(const Duration(seconds: 59)), '59');
    });

    test('shows minutes and padded seconds from one minute', () {
      expect(formatTimer(const Duration(seconds: 60)), '1:00');
      expect(formatTimer(const Duration(minutes: 2, seconds: 5)), '2:05');
    });
  });

  test('ceilToSecond rounds partial seconds up', () {
    expect(ceilToSecond(Duration.zero), Duration.zero);
    expect(
      ceilToSecond(const Duration(milliseconds: 1)),
      const Duration(seconds: 1),
    );
    expect(
      ceilToSecond(const Duration(milliseconds: 39001)),
      const Duration(seconds: 40),
    );
    expect(
      ceilToSecond(const Duration(seconds: 40)),
      const Duration(seconds: 40),
    );
  });
}
