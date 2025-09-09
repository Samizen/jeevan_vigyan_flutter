import 'package:flutter/material.dart';
import 'package:jeevan_vigyan/screens/main_screen.dart';
import 'package:jeevan_vigyan/services/database_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

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
      home: const MainScreen(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('ne', 'NP')],
    );
  }
}
