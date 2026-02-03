import 'package:vibration/vibration.dart';

class VibrationHelper {
  static Future<void> vibrate() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate();
    }
  }
}

