import 'package:flutter/material.dart';

/// Large circular button that fills the space it is given.
class CircleButton extends StatelessWidget {
  const CircleButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.semanticLabel,
    this.tonal = false,
  });

  final VoidCallback onPressed;
  final Widget child;
  final String semanticLabel;

  /// Use the quieter tonal style instead of the default dark surface.
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          minimumSize: const Size.square(48),
          backgroundColor: tonal
              ? scheme.secondaryContainer
              : scheme.surfaceContainerHighest,
          foregroundColor: tonal ? scheme.onSecondaryContainer : scheme.primary,
        ),
        child: FittedBox(fit: BoxFit.scaleDown, child: child),
      ),
    );
  }
}
