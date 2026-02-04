import 'package:flutter/material.dart';

enum CounterStatus { stop, running, resting, ready }

class CounterStatusDisplay extends StatelessWidget {
  final CounterStatus status;
  final int counter;
  final Duration restTime;
  final Duration elapsedTime;

  const CounterStatusDisplay({
    super.key,
    required this.status,
    required this.counter,
    required this.restTime,
    required this.elapsedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildStatusLabel(),
          const SizedBox(height: 10),
          _buildCounterText(),
          _buildTimeText(),
        ],
      ),
    );
  }

  Widget _buildStatusLabel() {
    if (status == CounterStatus.stop) return const SizedBox.shrink();

    return Text(
      _getStatusText(),
      style: TextStyle(
        fontSize: 20,
        color: _getStatusColor(),
      ),
    );
  }

  Widget _buildCounterText() {
    return Text(
      status == CounterStatus.stop ? "PRESS" : "$counter",
      style: TextStyle(
        fontSize: status == CounterStatus.stop ? 40 : 50,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTimeText() {
    if (status == CounterStatus.stop) {
      return const Text(
        "to start",
        style: TextStyle(fontSize: 30, color: Colors.greenAccent),
      );
    }

    final timeText = _getTimeText();
    final timeColor =
        status == CounterStatus.ready ? Colors.white : Colors.greenAccent[400]!;

    return Text(
      timeText,
      style: TextStyle(fontSize: 30, color: timeColor),
    );
  }

  String _getStatusText() {
    return switch (status) {
      CounterStatus.stop => "",
      CounterStatus.resting => "REST",
      CounterStatus.ready => "READY",
      CounterStatus.running => "GO",
    };
  }

  Color _getStatusColor() {
    return switch (status) {
      CounterStatus.resting => Colors.yellow,
      CounterStatus.ready => Colors.white,
      CounterStatus.running => Colors.green,
      CounterStatus.stop => Colors.white,
    };
  }

  String _getTimeText() {
    final elapsedSeconds = elapsedTime.inSeconds;
    final restSeconds = restTime.inSeconds;

    return switch (status) {
      CounterStatus.resting => "${restSeconds - elapsedSeconds}",
      CounterStatus.ready => "$elapsedSeconds",
      _ => "$elapsedSeconds",
    };
  }
}
