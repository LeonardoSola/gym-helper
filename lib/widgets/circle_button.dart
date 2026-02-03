import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final void Function() onPress;
  final Widget child;

  const CircleButton({super.key, required this.onPress, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ElevatedButton(
        onPressed: onPress,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
          backgroundColor: const Color(0xff2c2c2c),
          foregroundColor: Colors.white,
        ),
        child: child,
      ),
    );
  }
}
