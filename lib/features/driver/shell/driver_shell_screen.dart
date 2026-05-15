import 'package:flutter/material.dart';

import 'package:flut/features/driver/history/driver_history_screen.dart';
import 'package:flut/features/driver/home/driver_home_screen.dart';
import 'package:flut/features/driver/map/driver_map_screen.dart';
import 'package:flut/features/driver/notifications/driver_notifications_screen.dart';
import 'package:flut/features/driver/parking/driver_parking_session.dart';
import 'package:flut/features/driver/parking/extend_parking_screen.dart';
import 'package:flut/features/driver/parking/services/parking_service.dart';
import 'package:flut/features/driver/parking/start_parking_screen.dart';
import 'package:flut/features/driver/profile/driver_profile_form_result.dart';
import 'package:flut/features/driver/profile/driver_profile_screen.dart';
import 'package:flut/features/driver/profile/models/driver_user_profile.dart';
import 'package:flut/features/driver/profile/services/profile_service.dart';
import 'package:flut/features/driver/vehicles/driver_vehicles_screen.dart';
import 'package:flut/features/driver/vehicles/services/vehicle_service.dart';
import 'package:flut/features/driver/violations/driver_violations_screen.dart';
import 'package:flut/features/driver/wallet/driver_wallet_screen.dart';
import 'package:flut/features/driver/wallet/services/wallet_service.dart';

class DriverShellScreen extends StatefulWidget {
  const DriverShellScreen({super.key});

  @override
  State<DriverShellScreen> createState() => _DriverShellScreenState();
}

class _DriverShellScreenState extends State<DriverShellScreen> {
  final _walletService = WalletService();
  final _vehicleService = VehicleService();
  final _parkingService = ParkingService();
  final _profileService = ProfileService();

  int _currentIndex = 0;
  DriverParkingSession? _activeSession;
  DriverUserProfile? _currentUser;
  double _walletBalance = 0;
  bool _isWalletLoading = true;
  bool _isProfileLoading = true;

  static const _titles = [
    'الرئيسية',
    'الخريطة',
    'السجل',
    'مركباتي',
    'حسابي',
  ];

  @override
  void initState() {
    super.initState();
    _bootstrapHomeState();
  }

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
            greetingName: _currentUser?.fullName.isNotEmpty == true
                ? _currentUser!.fullName
                : 'السائق',
            activeSession: _activeSession,
            walletBalance: _walletBalance,
            isWalletLoading: _isWalletLoading,
            onStartSession: _openStartParkingFlow,
            onEndSession: _confirmEndSession,
            onExtendSession: _openExtendSessionFlow,
            onOpenViolations: _openViolations,
            onOpenWallet: _openWallet,
          ),
          const DriverMapScreen(),
          const DriverHistoryScreen(),
          const DriverVehiclesScreen(),
          DriverProfileScreen(
            profile: _currentUser,
            isLoading: _isProfileLoading,
            onRefreshProfile: _loadCurrentUser,
            onSaveProfile: _saveProfileChanges,
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

  Future<void> _bootstrapHomeState() async {
    await Future.wait([
      _loadWalletBalance(),
      _loadActiveSession(),
      _loadCurrentUser(),
    ]);
  }

  Future<void> _loadWalletBalance() async {
    setState(() {
      _isWalletLoading = true;
    });

    try {
      final wallet = await _walletService.getWallet();
      if (!mounted) return;
      setState(() {
        _walletBalance = wallet.balance;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _walletBalance = 0;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isWalletLoading = false;
      });
    }
  }

  Future<void> _loadActiveSession() async {
    try {
      final vehicles = await _vehicleService.getVehicles();
      final session = await _parkingService.getActiveSession(vehicles);
      if (!mounted) return;
      setState(() {
        _activeSession = session;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _activeSession = null;
      });
    }
  }

  Future<void> _loadCurrentUser() async {
    setState(() {
      _isProfileLoading = true;
    });

    try {
      final profile = await _profileService.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _currentUser = profile;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _currentUser = null;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isProfileLoading = false;
      });
    }
  }

  Future<void> _saveProfileChanges(DriverProfileFormResult result) async {
    await _profileService.updateProfile(
      username: _currentUser?.username ?? '',
      fullName: result.fullName,
      phoneNumber: result.phoneNumber,
      email: result.email.trim().isEmpty ? null : result.email.trim(),
    );

    if (!mounted) return;
    setState(() {
      _currentUser = (_currentUser ??
              const DriverUserProfile(
                id: 0,
                username: '',
                fullName: '',
                nationalId: '',
                phoneNumber: '',
                email: null,
                drivingLicenceId: null,
              ))
          .copyWith(
        fullName: result.fullName,
        phoneNumber: result.phoneNumber,
        email: result.email.trim().isEmpty ? null : result.email.trim(),
      );
    });
  }

  Future<void> _openStartParkingFlow() async {
    final session = await Navigator.push<DriverParkingSession>(
      context,
      MaterialPageRoute(
        builder: (_) => const StartParkingScreen(),
      ),
    );

    if (session == null) {
      return;
    }

    setState(() {
      _activeSession = session;
      _currentIndex = 0;
    });

    await _loadWalletBalance();
  }

  Future<void> _openExtendSessionFlow() async {
    final activeSession = _activeSession;
    if (activeSession == null) {
      return;
    }

    final extendResult = await Navigator.of(context).push<ExtendParkingResult>(
      MaterialPageRoute(
        builder: (_) => const ExtendParkingScreen(),
      ),
    );

    if (extendResult == null || !mounted) {
      return;
    }

    try {
      await _parkingService.extendSession(
        vehicleId: activeSession.vehicleId,
        durationMinutes: extendResult.extraMinutes,
      );

      setState(() {
        _activeSession = activeSession.copyWith(
          durationMinutes: activeSession.durationMinutes + extendResult.extraMinutes,
          totalPrice: activeSession.totalPrice + (extendResult.extraMinutes ~/ 30),
          endsAt: activeSession.endsAt.add(Duration(minutes: extendResult.extraMinutes)),
          paymentMethodLabel: 'المحفظة',
        );
      });

      await _loadWalletBalance();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تمديد الجلسة ${extendResult.extraMinutes} دقيقة بنجاح.'),
        ),
      );
    } on ParkingException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  Future<void> _confirmEndSession() async {
    final activeSession = _activeSession;
    if (activeSession == null) {
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

    if (shouldEnd != true || !mounted) {
      return;
    }

    try {
      await _parkingService.endSession(vehicleId: activeSession.vehicleId);
      setState(() {
        _activeSession = null;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنهاء الجلسة الحالية.'),
        ),
      );
    } on ParkingException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
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

  Future<void> _openWallet() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const DriverWalletScreen(),
      ),
    );

    await _loadWalletBalance();
  }

  void _handleLogout() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
