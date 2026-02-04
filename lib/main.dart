import 'package:flutter/material.dart';
import 'package:gym_helper/pages/home_page.dart';
import 'package:gym_helper/widgets/top_clock.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Helper',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SafeArea(
        key: UniqueKey(),
        child: const Stack(
          children: [
            HomePage(),
            TopClock(),
          ],
        ),
      ),
    );
  }
}
