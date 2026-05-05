import 'package:flutter/material.dart';

import 'package:flut/features/driver/history/driver_history_screen.dart';
import 'package:flut/features/driver/home/driver_home_screen.dart';
import 'package:flut/features/driver/map/driver_map_screen.dart';
import 'package:flut/features/driver/notifications/driver_notifications_screen.dart';
import 'package:flut/features/driver/parking/driver_parking_session.dart';
import 'package:flut/features/driver/parking/extend_parking_screen.dart';
import 'package:flut/features/driver/parking/start_parking_screen.dart';
import 'package:flut/features/driver/profile/driver_profile_screen.dart';
import 'package:flut/features/driver/vehicles/driver_vehicles_screen.dart';
import 'package:flut/features/driver/violations/driver_violations_screen.dart';

class DriverShellScreen extends StatefulWidget {
  const DriverShellScreen({super.key});

  @override
  State<DriverShellScreen> createState() => _DriverShellScreenState();
}

class _DriverShellScreenState extends State<DriverShellScreen> {
  int _currentIndex = 0;
  DriverParkingSession? _activeSession;

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
                  onPressed: _openNotifications,
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ]
            : null,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DriverHomeScreen(
            activeSession: _activeSession,
            onStartSession: _openStartParkingFlow,
            onEndSession: _confirmEndSession,
            onExtendSession: _openExtendSessionFlow,
            onOpenViolations: _openViolations,
          ),
          const DriverMapScreen(),
          const DriverHistoryScreen(),
          const DriverVehiclesScreen(),
          DriverProfileScreen(
            onLogout: _handleLogout,
          ),
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
    final session = await Navigator.push<DriverParkingSession>(
      context,
      MaterialPageRoute(
        builder: (_) => const StartParkingScreen(),
      ),
    );

    if (session != null) {
      setState(() {
        _activeSession = session;
        _currentIndex = 0;
      });
    }
  }

  Future<void> _openExtendSessionFlow() async {
    if (_activeSession == null) {
      return;
    }

    final extendResult = await Navigator.of(context).push<ExtendParkingResult>(
      MaterialPageRoute(
        builder: (_) => const ExtendParkingScreen(),
      ),
    );

    if (extendResult == null || _activeSession == null) {
      return;
    }

    final addedPrice = extendResult.extraMinutes ~/ 30;
    setState(() {
      _activeSession = _activeSession!.copyWith(
        durationMinutes: _activeSession!.durationMinutes + extendResult.extraMinutes,
        totalPrice: _activeSession!.totalPrice + addedPrice,
        paymentMethodLabel: extendResult.paymentMethodTitle,
        endsAt: _activeSession!.endsAt.add(Duration(minutes: extendResult.extraMinutes)),
      );
    });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تمديد الجلسة ${extendResult.extraMinutes} دقيقة عبر ${extendResult.paymentMethodTitle}.',
        ),
      ),
    );
  }

  Future<void> _confirmEndSession() async {
    if (_activeSession == null) {
      return;
    }

    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إنهاء الجلسة'),
          content: const Text('هل تريد إنهاء جلسة الوقوف الحالية الآن؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('إنهاء'),
            ),
          ],
        );
      },
    );

    if (shouldEnd == true) {
      setState(() {
        _activeSession = null;
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنهاء الجلسة الحالية.'),
        ),
      );
    }
  }

  Future<void> _openViolations() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const DriverViolationsScreen(),
      ),
    );
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const DriverNotificationsScreen(),
      ),
    );
  }

  void _handleLogout() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
