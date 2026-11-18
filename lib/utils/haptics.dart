import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Haptic cues, so the watch can be used without looking at it.
///
/// Errors are ignored on purpose: vibration is a nice-to-have and is not
/// available on every platform (for example in tests or desktop browsers).
abstract final class Haptics {
  /// Short tick confirming a tap.
  static Future<void> tap() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Double buzz signalling that rest is over.
  static Future<void> restFinished() async {
    try {
      if (await Vibration.hasVibrator()) {
        await Vibration.vibrate(pattern: const [0, 400, 200, 400]);
      }
    } catch (_) {}
  }
}
