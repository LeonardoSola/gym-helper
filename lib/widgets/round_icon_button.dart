import 'package:flutter/material.dart';

/// Small circular control used on the sides of the session screen.
///
/// Always at least 48x48 dp, the Material minimum touch target, which matters
/// on a watch used with sweaty hands mid-workout.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.tooltip,
    required this.onPressed,
    required this.child,
    required this.color,
    this.selected = false,
    this.size = 48,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final Widget child;
  final Color color;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final background = selected ? color : Colors.transparent;
    final foreground = selected
        ? ThemeData.estimateBrightnessForColor(color) == Brightness.dark
              ? Colors.white
              : Colors.black
        : color;

    return Semantics(
      button: true,
      toggled: selected ? true : null,
      enabled: onPressed != null,
      label: tooltip,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            minimumSize: Size.square(size),
            backgroundColor: background,
            foregroundColor: foreground,
            disabledForegroundColor: color.withValues(alpha: 0.3),
            side: BorderSide(
              color: onPressed == null ? color.withValues(alpha: 0.3) : color,
              width: 1.5,
            ),
          ),
          child: IconTheme.merge(
            data: IconThemeData(size: size * 0.48),
            child: child,
          ),
        ),
      ),
    );
  }
}
