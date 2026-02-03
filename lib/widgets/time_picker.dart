import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gym_helper/pages/counter_page.dart';

class TimePicker extends StatefulWidget {
  const TimePicker({super.key});

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  int _tens = 1;
  int _units = 0;

  void confirm() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CounterPage(
          restTime: Duration(seconds: _tens * 10 + _units),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Row(
          children: [
            _picker(1, 9, (value) => _tens = value),
            _picker(0, 10, (value) => _units = value),
            IconButton(onPressed: confirm, icon: const Icon(Icons.play_arrow)),
          ],
        ),
      ),
    );
  }

  Widget _picker(int min, int max, Function(dynamic value) onChange) =>
      Expanded(
        child: CupertinoPicker(
          itemExtent: 50,
          looping: true,
          onSelectedItemChanged: (value) => onChange(value + min),
          children: List.generate(
            max,
            (index) => Center(
              child: Text(
                '${index + min}',
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
}
