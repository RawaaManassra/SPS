import 'package:flutter/material.dart';

import 'package:flut/features/auth/screens/login_screen.dart';
import 'package:flut/features/auth/services/auth_service.dart';
import 'package:flut/features/officer/check/officer_check_vehicle_screen.dart';
import 'package:flut/features/officer/history/screens/officer_history_screen.dart';
import 'package:flut/features/officer/home/officer_home_screen.dart';
import 'package:flut/features/officer/profile/models/officer_user_profile.dart';
import 'package:flut/features/officer/profile/screens/officer_profile_screen.dart';
import 'package:flut/features/officer/profile/services/officer_profile_service.dart';

class OfficerShellScreen extends StatefulWidget {
  const OfficerShellScreen({super.key});

  @override
  State<OfficerShellScreen> createState() => _OfficerShellScreenState();
}

class _OfficerShellScreenState extends State<OfficerShellScreen> {
  final OfficerProfileService _profileService = OfficerProfileService();
  final AuthService _authService = AuthService();

  int _currentIndex = 0;
  OfficerUserProfile? _currentUser;
  bool _isProfileLoading = true;

  static const List<String> _titles = [
    'الرئيسية',
    'السجل',
    'الحساب',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          OfficerHomeScreen(
            onOpenCheckOptions: () => _openCheckOptions(context),
          ),
          const OfficerHistoryScreen(),
          OfficerProfileScreen(
            profile: _currentUser,
            isLoading: _isProfileLoading,
            onRefreshProfile: _loadCurrentUser,
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
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'السجل',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'الحساب',
          ),
        ],
      ),
    );
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

  Future<void> _openCheckOptions(BuildContext context) async {
    final option = await showDialog<_CheckEntryOption>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 26),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'اختيار طريقة الفحص',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _CheckOptionTile(
                        icon: Icons.photo_camera_back_outlined,
                        title: 'تصوير اللوحة',
                        subtitle: 'استخدام الكاميرا أو صورة جاهزة',
                        onTap: () =>
                            Navigator.of(context).pop(_CheckEntryOption.scan),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CheckOptionTile(
                        icon: Icons.keyboard_alt_outlined,
                        title: 'رقم اللوحة',
                        subtitle: 'إدخال يدوي مباشر',
                        onTap: () =>
                            Navigator.of(context).pop(_CheckEntryOption.manual),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (option == null || !context.mounted) return;

    _openCheckVehicle(
      context,
      initialScanMode: option == _CheckEntryOption.scan,
    );
  }

  void _openCheckVehicle(BuildContext context, {bool initialScanMode = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OfficerCheckVehicleScreen(
          initialScanMode: initialScanMode,
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    await _authService.clearSession();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}

class _CheckOptionTile extends StatelessWidget {
  const _CheckOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7F3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE7E1D6)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F2EF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF0F766E),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF5B6472),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _CheckEntryOption {
  scan,
  manual,
}
