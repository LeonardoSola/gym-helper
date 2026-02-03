import 'package:flutter/material.dart';
import 'package:gym_helper/pages/counter_page.dart';
import 'package:gym_helper/widgets/circle_button.dart';
import 'package:gym_helper/widgets/time_picker.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    void openCounterPage(int seconds) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              CounterPage(restTime: Duration(seconds: seconds)),
        ),
      );
    }

    void openTimePicker() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TimePicker(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.count(
        crossAxisCount: 2,
        children: [
          CircleButton(
              child: const Text("30s"), onPress: () => openCounterPage(30)),
          CircleButton(
              child: const Text("40s"), onPress: () => openCounterPage(40)),
          CircleButton(
              child: const Text("50s"), onPress: () => openCounterPage(50)),
          CircleButton(
              onPress: openTimePicker,
              child: const Icon(Icons.timer_outlined, size: 30)),
        ],
      ),
    );
  }
}
