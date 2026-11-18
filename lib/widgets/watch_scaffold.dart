import 'package:flutter/material.dart';
import 'package:gym_helper/widgets/top_clock.dart';

/// Base layout for every screen: black background, safe area and the current
/// time at the top, as is conventional on Wear OS.
class WatchScaffold extends StatelessWidget {
  const WatchScaffold({
    super.key,
    required this.body,
    this.backgroundColor,
    this.clockColor,
  });

  final Widget body;
  final Color? backgroundColor;
  final Color? clockColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(child: body),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: TopClock(color: clockColor),
            ),
          ),
        ],
      ),
    );
  }
}
