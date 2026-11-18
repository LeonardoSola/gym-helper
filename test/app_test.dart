import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_helper/main.dart';
import 'package:gym_helper/pages/rest_picker_page.dart';
import 'package:gym_helper/pages/session_page.dart';

import 'test_utils.dart';

void main() {
  testWidgets('home shows the rest presets and a custom option', (
    tester,
  ) async {
    useWatchScreen(tester);
    await tester.pumpWidget(const GymHelperApp());

    for (final seconds in ['30', '40', '50']) {
      expect(find.text(seconds), findsOneWidget);
    }
    expect(find.bySemanticsLabel('Custom rest time'), findsOneWidget);
  });

  testWidgets('a preset opens a session with that rest time', (tester) async {
    useWatchScreen(tester);
    await tester.pumpWidget(const GymHelperApp());

    await tester.tap(find.text('40'));
    await tester.pumpAndSettle();

    final page = tester.widget<SessionPage>(find.byType(SessionPage));
    expect(page.restDuration, const Duration(seconds: 40));
    expect(find.text('Tap to start'), findsOneWidget);
  });

  testWidgets('the custom picker starts a session with the chosen time', (
    tester,
  ) async {
    useWatchScreen(tester);
    await tester.pumpWidget(const GymHelperApp());

    await tester.tap(find.bySemanticsLabel('Custom rest time'));
    await tester.pumpAndSettle();
    expect(find.byType(RestPickerPage), findsOneWidget);

    await tester.tap(find.byKey(const Key('rest-picker-start')));
    await tester.pumpAndSettle();

    final page = tester.widget<SessionPage>(find.byType(SessionPage));
    expect(page.restDuration, const Duration(seconds: 60));

    // The picker is replaced, so going back returns to the home screen.
    Navigator.of(tester.element(find.byType(SessionPage))).pop();
    await tester.pumpAndSettle();
    expect(find.text('30'), findsOneWidget);
  });
}
