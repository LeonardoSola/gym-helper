import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym_helper/utils/vibration_helper.dart';
import 'package:gym_helper/widgets/counter_action_buttons.dart';
import 'package:gym_helper/widgets/counter_status_display.dart';
import 'package:gym_helper/widgets/series_button.dart';
import 'package:gym_helper/widgets/top_clock.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class CounterPage extends StatefulWidget {
  final Duration restTime;
  const CounterPage({super.key, required this.restTime});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  // Status and configuration
  CounterStatus _status = CounterStatus.stop;
  bool _autoPlay = false;
  late final Duration _restTime;

  // Counters
  int _counter = 0;
  int _series = 0;
  int _lastCounter = 0;

  // Timer management
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _restTime = widget.restTime;
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  // Timer control methods
  void _startTimer() {
    setState(() {
      _status = CounterStatus.running;
      _stopwatch.start();
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _onTimerTick);
  }

  void _restartTimer() {
    setState(() {
      _status = CounterStatus.running;
      _stopwatch.reset();
    });
  }

  void _onTimerTick(Timer timer) {
    if (!mounted) return;
    setState(() {});

    final elapsedSeconds = _stopwatch.elapsed.inSeconds;
    if (elapsedSeconds >= _restTime.inSeconds &&
        _status == CounterStatus.resting) {
      VibrationHelper.vibrate();
      if (_autoPlay) {
        _restartTimer();
      } else {
        setState(() {
          _status = CounterStatus.ready;
        });
      }
    }
  }

  // Counter actions
  void _handleMainButtonPress() {
    switch (_status) {
      case CounterStatus.stop:
        _startTimer();
        break;
      case CounterStatus.running:
        _enterRestMode();
        break;
      case CounterStatus.ready:
      case CounterStatus.resting:
        _restartTimer();
        break;
    }
  }

  void _enterRestMode() {
    setState(() {
      _status = CounterStatus.resting;
      _counter++;
      _lastCounter = _counter;
      _stopwatch.reset();
    });
  }

  void _finishSeries() {
    setState(() {
      _series++;
      _counter = 0;
      _status = CounterStatus.ready;
    });
  }

  void _undo() {
    setState(() {
      if (_counter > 0) {
        _counter--;
      } else if (_series > 0) {
        _series--;
        _counter = _lastCounter;
      }
    });
  }

  void _toggleAutoPlay() {
    setState(() {
      _autoPlay = !_autoPlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildMainButton(),
        const TopClock(),
      ],
    );
  }

  Widget _buildMainButton() {
    final isReady = _status == CounterStatus.ready;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isReady ? Colors.green : Colors.transparent,
        foregroundColor: Colors.green,
        padding: const EdgeInsets.all(0),
      ),
      onPressed: _handleMainButtonPress,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (_status != CounterStatus.stop)
            SeriesButton(series: _series, onPressed: _finishSeries),
          CounterStatusDisplay(
            status: _status,
            counter: _counter,
            restTime: _restTime,
            elapsedTime: _stopwatch.elapsed,
          ),
          if (_status != CounterStatus.stop)
            CounterActionButtons(
              isAutoPlayEnabled: _autoPlay,
              onAutoPlayToggle: _toggleAutoPlay,
              onUndo: _undo,
            ),
        ],
      ),
    );
  }
}
