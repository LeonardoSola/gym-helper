import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

/// Renders tests on a 227x227 dp screen, the size of a large round Wear OS
/// watch, so layout problems on small displays are caught.
void useWatchScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(454, 454);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
}
