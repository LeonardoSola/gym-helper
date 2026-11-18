import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_helper/pages/session_page.dart';
import 'package:gym_helper/theme/app_theme.dart';

import 'test_utils.dart';

void main() {
  late DateTime now;

  Future<void> pumpSession(WidgetTester tester, {int restSeconds = 30}) async {
    useWatchScreen(tester);
    now = DateTime(2026, 1, 1, 8);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: SessionPage(
          restDuration: Duration(seconds: restSeconds),
          clock: () => now,
        ),
      ),
    );
  }

  /// Moves both the fake wall clock and the widget test clock forward.
  Future<void> advance(WidgetTester tester, Duration duration) async {
    now = now.add(duration);
    await tester.pump(duration);
  }

  String text(Key key) {
    final widget = find.byKey(key).evaluate().single.widget as Text;
    return widget.data ?? widget.textSpan!.toPlainText();
  }

  Future<void> tapScreen(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('session-primary')));
    await tester.pump();
    // Let the side controls finish fading in.
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('runs through a set, a rest and the ready state', (tester) async {
    await pumpSession(tester);
    expect(find.text('Tap to start'), findsOneWidget);

    await tapScreen(tester);
    await advance(tester, const Duration(seconds: 12));
    expect(text(const Key('session-phase')), 'GO');
    expect(text(const Key('session-timer')), '12');
    expect(text(const Key('session-sets')), '0 sets');

    await tapScreen(tester);
    await advance(tester, const Duration(milliseconds: 400));
    expect(text(const Key('session-phase')), 'REST');
    expect(text(const Key('session-timer')), '30');
    expect(text(const Key('session-sets')), '1 set');

    await advance(tester, const Duration(seconds: 10));
    expect(text(const Key('session-timer')), '20');

    await advance(tester, const Duration(seconds: 21));
    expect(text(const Key('session-phase')), 'READY');
    expect(text(const Key('session-timer')), startsWith('+'));
  });

  testWidgets('undo restores the set after an accidental tap', (tester) async {
    await pumpSession(tester);
    await tapScreen(tester);
    await advance(tester, const Duration(seconds: 5));
    await tapScreen(tester); // accidental

    await tester.tap(find.byKey(const Key('session-undo')));
    await tester.pump();

    expect(text(const Key('session-phase')), 'GO');
    expect(text(const Key('session-sets')), '0 sets');
  });

  testWidgets('auto restart skips the ready state', (tester) async {
    await pumpSession(tester, restSeconds: 10);
    await tapScreen(tester);
    await tester.tap(find.byKey(const Key('session-auto-restart')));
    await tester.pump();
    await tapScreen(tester);

    await advance(tester, const Duration(seconds: 11));

    expect(text(const Key('session-phase')), 'GO');
    expect(text(const Key('session-sets')), '1 set');
  });

  testWidgets('finishing an exercise resets the set count', (tester) async {
    await pumpSession(tester);
    await tapScreen(tester);
    await tapScreen(tester);

    await tester.tap(find.byKey(const Key('session-exercise')));
    await tester.pump();

    expect(find.bySemanticsLabel(RegExp('Exercises done: 1')), findsOneWidget);
    expect(text(const Key('session-phase')), 'READY');
    expect(text(const Key('session-sets')), '0 sets');
  });

  testWidgets('side controls stay hidden and inert before starting', (
    tester,
  ) async {
    await pumpSession(tester);

    await tester.tap(
      find.byKey(const Key('session-exercise')),
      warnIfMissed: false,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The tap went through to the main button and started the session.
    expect(text(const Key('session-phase')), 'GO');
    expect(find.bySemanticsLabel(RegExp('Exercises done: 0')), findsOneWidget);
  });
}
