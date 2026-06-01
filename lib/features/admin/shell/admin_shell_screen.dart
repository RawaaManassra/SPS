import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flut/features/admin/inspectors/screens/admin_inspectors_screen.dart';
import 'package:flut/features/admin/models/admin_dashboard_data.dart';
import 'package:flut/features/admin/services/admin_dashboard_service.dart';
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
      const AdminInspectorsScreen(),
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

class _AdminOverviewScreen extends StatefulWidget {
  const _AdminOverviewScreen();

  @override
  State<_AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<_AdminOverviewScreen> {
  final AdminDashboardService _service = AdminDashboardService();

  bool _isLoading = true;
  String? _errorMessage;
  AdminDashboardData? _dashboard;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'لوحة المتابعة اليومية',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'تابع الجلسات النشطة، المخالفات، القفل، وأداء المفتشين من مكان واحد.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFFE7F8F5),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _loadDashboard,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('تحديث'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_errorMessage != null)
          _AdminErrorCard(
            message: _errorMessage!,
            onRetry: _loadDashboard,
          )
        else if (_dashboard != null) ...[
          GridView.count(
            crossAxisCount: wide ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: wide ? 1.35 : 1.05,
            children: [
              _DashboardMetricCard(
                title: 'الجلسات النشطة',
                value: _dashboard!.activeSessionsCount.toString(),
                subtitle: 'عدد الجلسات الجارية حالياً',
                icon: Icons.local_parking_outlined,
              ),
              _DashboardMetricCard(
                title: 'المخالفات اليوم',
                value: _dashboard!.finesCount.toString(),
                subtitle: 'المخالفات المسجلة اليوم',
                icon: Icons.gavel_rounded,
              ),
              _DashboardMetricCard(
                title: 'حالات القفل',
                value: _dashboard!.clampEventsCount.toString(),
                subtitle: 'عدد المركبات المقفلة اليوم',
                icon: Icons.lock_outline_rounded,
              ),
              _DashboardMetricCard(
                title: 'إيراد اليوم',
                value: '${_dashboard!.dailyRevenue.toStringAsFixed(0)} شيكل',
                subtitle: 'إجمالي رسوم الجلسات اليوم',
                icon: Icons.payments_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _InspectorPerformanceSection(inspectors: _dashboard!.inspectors),
        ],
      ],
    );
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dashboard = await _service.getDashboard();
      if (!mounted) return;
      setState(() {
        _dashboard = dashboard;
      });
    } on AdminDashboardException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class _DashboardMetricCard extends StatelessWidget {
  const _DashboardMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
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
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F766E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
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

class _InspectorPerformanceSection extends StatelessWidget {
  const _InspectorPerformanceSection({
    required this.inspectors,
  });

  final List<AdminInspectorPerformance> inspectors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8E3D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'أداء المفتشين اليوم',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ترتيب يومي بناءً على مجموع المخالفات وحالات القفل المسجلة.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5B6472),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          if (inspectors.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7F3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'لا توجد بيانات أداء للمفتشين اليوم حتى الآن.',
              ),
            )
          else
            ...inspectors.asMap().entries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(bottom: entry.key == inspectors.length - 1 ? 0 : 12),
                child: _InspectorPerformanceTile(
                  rank: entry.key + 1,
                  performance: entry.value,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InspectorPerformanceTile extends StatelessWidget {
  const _InspectorPerformanceTile({
    required this.rank,
    required this.performance,
  });

  final int rank;
  final AdminInspectorPerformance performance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F2EF),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F766E),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  performance.inspectorName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'مخالفات: ${performance.finesCount} • قفل: ${performance.clampsCount}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5B6472),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${performance.totalActions}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F766E),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminErrorCard extends StatelessWidget {
  const _AdminErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1B7B0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFB42318),
            size: 34,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
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
          'هذا القسم مخصص لمراجعة الشكاوى الواردة من السائقين وتحديث حالتها حسب قرار البلدية.',
      icon: Icons.feedback_outlined,
      highlights: [
        'عرض جميع الشكاوى',
        'تحديث حالة الشكوى',
        'ربط الشكوى بالمخالفة أو المستخدم',
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
          'هذا القسم سيعرض الجلسات النشطة والمركبات المقفلة على مستوى المدينة، ويمكن لاحقاً توسيعه إلى لوحة تشغيل مباشرة.',
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
              'هذا القسم مخصص لإعدادات حساب الإدارة، ويمكن توسيعه لاحقاً ببيانات المستخدم والصلاحيات وسجل العمليات.',
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
