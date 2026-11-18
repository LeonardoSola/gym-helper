import 'package:flutter/material.dart';
import 'package:gym_helper/pages/home_page.dart';
import 'package:gym_helper/theme/app_theme.dart';

void main() {
  runApp(const GymHelperApp());
}

class GymHelperApp extends StatelessWidget {
  const GymHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Helper',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const HomePage(),
    );
  }
}
