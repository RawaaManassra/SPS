import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flut/features/auth/screens/login_screen.dart';
import 'package:flut/features/auth/services/auth_service.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  final AuthService _authService = AuthService();

  int _currentIndex = 0;

  static const List<_AdminNavItem> _navItems = [
    _AdminNavItem(
      title: 'الرئيسية',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    _AdminNavItem(
      title: 'المفتشون',
      icon: Icons.badge_outlined,
      selectedIcon: Icons.badge_rounded,
    ),
    _AdminNavItem(
      title: 'الشكاوى',
      icon: Icons.feedback_outlined,
      selectedIcon: Icons.feedback_rounded,
    ),
    _AdminNavItem(
      title: 'الخريطة',
      icon: Icons.map_outlined,
      selectedIcon: Icons.map_rounded,
    ),
    _AdminNavItem(
      title: 'الحساب',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final useWebLayout = kIsWeb || width >= 980;

    final pages = [
      const _AdminOverviewScreen(),
      const _AdminInspectorsScreen(),
      const _AdminComplaintsScreen(),
      const _AdminMapScreen(),
      _AdminAccountScreen(onLogout: _handleLogout),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EC),
      appBar: useWebLayout ? null : AppBar(title: Text(_navItems[_currentIndex].title)),
      body: useWebLayout
          ? _AdminWebLayout(
              currentIndex: _currentIndex,
              navItems: _navItems,
              onSelect: _handleSelect,
              child: pages[_currentIndex],
            )
          : IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
      bottomNavigationBar: useWebLayout
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _handleSelect,
              backgroundColor: Colors.white,
              indicatorColor: const Color(0x1F0F766E),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: _navItems
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: item.title,
                    ),
                  )
                  .toList(),
            ),
    );
  }

  void _handleSelect(int index) {
    setState(() {
      _currentIndex = index;
    });
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

class _AdminWebLayout extends StatelessWidget {
  const _AdminWebLayout({
    required this.currentIndex,
    required this.navItems,
    required this.onSelect,
    required this.child,
  });

  final int currentIndex;
  final List<_AdminNavItem> navItems;
  final ValueChanged<int> onSelect;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE6E1D6)),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Row(
            children: [
              const _AdminBrand(),
              const SizedBox(width: 36),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 12,
                  runSpacing: 8,
                  children: List.generate(
                    navItems.length,
                    (index) => _AdminTopNavButton(
                      item: navItems[index],
                      selected: index == currentIndex,
                      onTap: () => onSelect(index),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminBrand extends StatelessWidget {
  const _AdminBrand();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF0F766E),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: const Text(
            'P',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لوحة البلدية',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
            Text(
              'إدارة نظام موقفي',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AdminTopNavButton extends StatelessWidget {
  const _AdminTopNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _AdminNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F766E) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF0F766E) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.selectedIcon : item.icon,
              size: 18,
              color: selected ? Colors.white : const Color(0xFF334155),
            ),
            const SizedBox(width: 8),
            Text(
              item.title,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF334155),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminOverviewScreen extends StatelessWidget {
  const _AdminOverviewScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wide = MediaQuery.of(context).size.width >= 1100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF17867D)],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً، إدارة البلدية',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'واجهة متابعة تشغيلية للمفتشين والشكاوى والخريطة والخدمات الإدارية.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFFE7F8F5),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'الأقسام الرئيسية',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: wide ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: wide ? 1.25 : 1.05,
          children: const [
            _AdminStatCard(
              title: 'المفتشون',
              subtitle: 'إضافة ومتابعة حسابات التفتيش',
              icon: Icons.badge_outlined,
            ),
            _AdminStatCard(
              title: 'الشكاوى',
              subtitle: 'مراجعة الاعتراضات والشكاوى',
              icon: Icons.feedback_outlined,
            ),
            _AdminStatCard(
              title: 'الخريطة',
              subtitle: 'الجلسات والمركبات المقفلة',
              icon: Icons.map_outlined,
            ),
            _AdminStatCard(
              title: 'التقارير',
              subtitle: 'مساحة مخصصة للملخصات والإحصائيات',
              icon: Icons.assessment_outlined,
            ),
          ],
        ),
      ],
    );
  }
}

class _AdminInspectorsScreen extends StatelessWidget {
  const _AdminInspectorsScreen();

  @override
  Widget build(BuildContext context) {
    return const _AdminSectionContent(
      title: 'إدارة المفتشين',
      subtitle:
          'هذا القسم مخصص لإضافة حسابات المفتشين ومتابعة بياناتهم وصلاحياتهم. الربط الحالي يسمح بإنشاء المفتشين، ويمكننا توسيعه لاحقاً بعرض الحالة التشغيلية والتفاصيل الكاملة.',
      icon: Icons.badge_outlined,
      highlights: [
        'إضافة حساب مفتش جديد',
        'متابعة بيانات المفتشين',
        'ربط الحالة التشغيلية لكل مفتش',
      ],
    );
  }
}

class _AdminComplaintsScreen extends StatelessWidget {
  const _AdminComplaintsScreen();

  @override
  Widget build(BuildContext context) {
    return const _AdminSectionContent(
      title: 'الشكاوى والاعتراضات',
      subtitle:
          'هذا القسم سيكون مخصصاً لمراجعة شكاوى السائقين، متابعة الحالات المفتوحة، وتحديث القرار النهائي لكل شكوى أو اعتراض.',
      icon: Icons.feedback_outlined,
      highlights: [
        'عرض جميع الشكاوى الواردة',
        'تحديث حالة الشكوى',
        'ربط الشكوى بالمخالفة أو بالحساب',
      ],
    );
  }
}

class _AdminMapScreen extends StatelessWidget {
  const _AdminMapScreen();

  @override
  Widget build(BuildContext context) {
    return const _AdminSectionContent(
      title: 'الخريطة التشغيلية',
      subtitle:
          'هذا القسم سيعرض الجلسات النشطة والمركبات المقفلة على مستوى المدينة، مع إمكانية التحول لاحقاً إلى لوحة متابعة لحظية أكثر تفصيلاً.',
      icon: Icons.map_outlined,
      highlights: [
        'الجلسات النشطة',
        'المركبات المقفلة',
        'مؤشرات تشغيلية على الخريطة',
      ],
    );
  }
}

class _AdminAccountScreen extends StatelessWidget {
  const _AdminAccountScreen({
    required this.onLogout,
  });

  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _AdminSectionContent(
          title: 'حساب البلدية',
          subtitle:
              'هذا القسم مخصص لإعدادات حساب الإدارة، ويمكن لاحقاً توسيعه ببيانات المستخدم والصلاحيات وسجل العمليات الإدارية.',
          icon: Icons.admin_panel_settings_outlined,
          highlights: [
            'بيانات الحساب',
            'الصلاحيات والإعدادات',
            'سجل التغييرات الإدارية',
          ],
        ),
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: onLogout,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(180, 52),
              side: const BorderSide(color: Color(0xFFB42318)),
              foregroundColor: const Color(0xFFB42318),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('تسجيل الخروج'),
          ),
        ),
      ],
    );
  }
}

class _AdminSectionContent extends StatelessWidget {
  const _AdminSectionContent({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.highlights,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8E3D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F2EF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: const Color(0xFF0F766E)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF5B6472),
              height: 1.8,
            ),
          ),
          const SizedBox(height: 22),
          ...highlights.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: Color(0xFF0F766E),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E3D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F2EF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF0F766E)),
          ),
          const Spacer(),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5B6472),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminNavItem {
  const _AdminNavItem({
    required this.title,
    required this.icon,
    required this.selectedIcon,
  });

  final String title;
  final IconData icon;
  final IconData selectedIcon;
}
