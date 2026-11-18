import 'package:flutter/material.dart';
import 'package:gym_helper/models/workout_session.dart';

/// Visual identity of the app.
///
/// Gym Helper runs on Wear OS, where the system UI is always dark and screens
/// are mostly OLED, so the app uses a single true-black Material 3 theme.
abstract final class AppTheme {
  static const Color seed = Color(0xFF00C853);

  /// Accent used while resting. Warm and clearly different from the green
  /// "go" colour, so the current phase can be read at a glance.
  static const Color rest = Color(0xFFFFC94D);

  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF3DDC84),
          onPrimary: const Color(0xFF00210E),
          surface: Colors.black,
        );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.black,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
    );
  }

  /// Text style for numbers that change every second: tabular figures keep
  /// the digits from jumping around as they update.
  static TextStyle timerStyle(double fontSize) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: 1,
      letterSpacing: -1,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}

/// Colours used to render each [SessionPhase].
@immutable
class PhaseColors {
  const PhaseColors({
    required this.background,
    required this.foreground,
    required this.accent,
  });

  factory PhaseColors.of(BuildContext context, SessionPhase phase) {
    final scheme = Theme.of(context).colorScheme;
    return switch (phase) {
      SessionPhase.idle => PhaseColors(
        background: Colors.black,
        foreground: scheme.onSurface,
        accent: scheme.primary,
      ),
      SessionPhase.working => PhaseColors(
        background: Colors.black,
        foreground: scheme.onSurface,
        accent: scheme.primary,
      ),
      SessionPhase.resting => PhaseColors(
        background: Colors.black,
        foreground: scheme.onSurface,
        accent: AppTheme.rest,
      ),
      SessionPhase.ready => PhaseColors(
        background: scheme.primary,
        foreground: scheme.onPrimary,
        accent: scheme.onPrimary,
      ),
    };
  }

  final Color background;
  final Color foreground;
  final Color accent;
}
