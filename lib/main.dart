import 'package:flutter/material.dart';
import 'package:jeevan_vigyan/screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeevan Vigyan',
      theme: ThemeData(fontFamily: 'Yantramanav'),
      home: const MainScreen(), // Here is the change
    );
  }
}
