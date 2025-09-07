import 'package:flutter/material.dart';
import 'package:jeevan_vigyan/constants/colors.dart';

// Placeholder pages for each navigation item
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('गृह Page'));
  }
}

class MembersPage extends StatelessWidget {
  const MembersPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('सदस्य Page'));
  }
}

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('विवरण Page'));
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('सेटिङ्स Page'));
  }
}

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('क्याल्कुलेटर Page'));
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    MembersPage(),
    ReportPage(),
    SettingsPage(),
    CalculatorPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the calculator page
          _onItemTapped(4);
        },
        backgroundColor: AppColors.maroonishRed,
        child: const Icon(Icons.calculate_outlined, color: AppColors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.charcoalBlack,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Left half of the bar
              IconButton(
                icon: const Icon(Icons.home, color: AppColors.brightSkyBlue),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: const Icon(Icons.people, color: AppColors.gray),
                onPressed: () => _onItemTapped(1),
              ),
              // The `SizedBox` adds a space for the notched FAB
              const SizedBox(width: 48),
              // Right half of the bar
              IconButton(
                icon: const Icon(Icons.description, color: AppColors.gray),
                onPressed: () => _onItemTapped(2),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: AppColors.gray),
                onPressed: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
