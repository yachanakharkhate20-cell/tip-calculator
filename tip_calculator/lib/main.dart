import 'package:flutter/material.dart';

import 'tip_page.dart';

void main() {
  runApp(const TipCalculatorApp());
}

/// Root widget of the app. It only sets up the theme and the first screen.
class TipCalculatorApp extends StatelessWidget {
  const TipCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tip Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5), // indigo
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F5FB),
      ),
      home: const TipPage(),
    );
  }
}
