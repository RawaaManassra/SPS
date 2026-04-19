import 'package:flutter/material.dart';

import 'package:flut/features/driver/history/driver_history_screen.dart';
import 'package:flut/features/driver/home/driver_home_screen.dart';
import 'package:flut/features/driver/map/driver_map_screen.dart';
import 'package:flut/features/driver/parking/start_parking_screen.dart';
import 'package:flut/features/driver/profile/driver_profile_screen.dart';
import 'package:flut/features/driver/vehicles/driver_vehicles_screen.dart';

class DriverShellScreen extends StatefulWidget {
  const DriverShellScreen({super.key});

  @override
  State<DriverShellScreen> createState() => _DriverShellScreenState();
}

class _DriverShellScreenState extends State<DriverShellScreen> {
  int _currentIndex = 0;
  bool _hasActiveSession = false;

  static const _titles = [
    'الرئيسية',
    'الخريطة',
    'السجل',
    'مركباتي',
    'حسابي',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: _currentIndex == 0
            ? [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ]
            : null,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DriverHomeScreen(
            hasActiveSession: _hasActiveSession,
            onStartSession: _openStartParkingFlow,
            onEndSession: () {
              setState(() {
                _hasActiveSession = false;
              });
            },
          ),
          const DriverMapScreen(),
          const DriverHistoryScreen(),
          const DriverVehiclesScreen(),
          const DriverProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0x1F0F766E),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'الخريطة',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'السجل',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car_rounded),
            label: 'مركباتي',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }

  Future<void> _openStartParkingFlow() async {
    final started = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const StartParkingScreen(),
      ),
    );

    if (started == true) {
      setState(() {
        _hasActiveSession = true;
        _currentIndex = 0;
      });
    }
  }
}
