import 'package:flutter/material.dart';

class SeriesButton extends StatelessWidget {
  final int series;
  final VoidCallback onPressed;

  const SeriesButton({
    super.key,
    required this.series,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white),
        shape: const CircleBorder(),
      ),
      onPressed: onPressed,
      child: Text("$series"),
    );
  }
}




