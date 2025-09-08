import 'package:flutter/material.dart';
import 'package:jeevan_vigyan/constants/colors.dart';
import 'package:jeevan_vigyan/screens/home_page.dart';
import 'package:jeevan_vigyan/screens/members_page.dart';
import 'package:jeevan_vigyan/screens/reports_page.dart';
import 'package:jeevan_vigyan/screens/calculator_page.dart';

// Placeholder pages for other navigation items
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('सेटिङ्स Page'));
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Change this from 'static const List' to a FUNCTION that RETURNS a List.
  static List<Widget> _pages(void Function(int) onItemTapped) {
    return [
      const HomePage(),
      const MembersPage(),
      const ReportsPage(),
      const SettingsPage(),
      // This is now a regular widget, not a const widget.
      CalculatorPage(onBackToHome: () => onItemTapped(0)),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body now CALLS the _pages function, passing the onItemTapped callback.
      body: _pages(_onItemTapped).elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
              IconButton(
                icon: const Icon(Icons.home),
                color: _selectedIndex == 0
                    ? AppColors.brightSkyBlue
                    : AppColors.gray,
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: const Icon(Icons.people),
                color: _selectedIndex == 1
                    ? AppColors.brightSkyBlue
                    : AppColors.gray,
                onPressed: () => _onItemTapped(1),
              ),
              const SizedBox(width: 48),
              IconButton(
                icon: const Icon(Icons.description),
                color: _selectedIndex == 2
                    ? AppColors.brightSkyBlue
                    : AppColors.gray,
                onPressed: () => _onItemTapped(2),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                color: _selectedIndex == 3
                    ? AppColors.brightSkyBlue
                    : AppColors.gray,
                onPressed: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
