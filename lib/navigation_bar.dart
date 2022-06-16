import 'package:firebase_demo/nav_bar_screens/images_screen.dart';
import 'package:firebase_demo/nav_bar_screens/sounds_screen.dart';
import 'package:firebase_demo/nav_bar_screens/statistics_screen.dart';
import 'package:flutter/material.dart';

class NavigationBarScreen extends StatefulWidget {
  NavigationBarScreen({Key? key}) : super(key: key);

  @override
  State<NavigationBarScreen> createState() => _NavigationBarScreenState();
}

class _NavigationBarScreenState extends State<NavigationBarScreen> {
  int _selectedIndex = 0;

  // list of screens of the navigation bar
  static List<Widget> _pages = <Widget>[
    StatisticsScreen(),
    ImagesScreen(),
    SoundsScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Storage Demo'),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey.shade900,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.data_usage_rounded),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image_rounded),
            label: 'Images',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volume_up_rounded),
            label: 'Sounds',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
