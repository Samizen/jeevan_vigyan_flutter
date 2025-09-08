import 'package:flutter/material.dart';
import 'package:jeevan_vigyan/screens/main_screen.dart';
import 'package:jeevan_vigyan/services/database_service.dart';
import 'package:jeevan_vigyan/screens/reports_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create an instance of the database service
  final dbService = DatabaseService();

  // Call the function to populate dummy data
  await dbService.populateDummyData();
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
