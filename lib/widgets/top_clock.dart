import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TopClock extends StatefulWidget {
  const TopClock({super.key});

  @override
  State<TopClock> createState() => TopClockState();
}

class TopClockState extends State<TopClock> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Start a timer to update the clock every minute
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer in the dispose() callback
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 5,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          DateFormat('HH:mm').format(DateTime.now()),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
