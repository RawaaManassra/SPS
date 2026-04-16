import 'package:flutter/material.dart';

import 'select_vehicle_screen.dart';

class DriverMainScreen extends StatefulWidget {
  const DriverMainScreen({super.key});

  @override
  State<DriverMainScreen> createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
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
          _HomeTab(
            hasActiveSession: _hasActiveSession,
            onStartSession: _openStartParkingFlow,
            onEndSession: () {
              setState(() {
                _hasActiveSession = false;
              });
            },
          ),
          const _PlaceholderTab(
            title: 'الخريطة',
            description: 'هنا ستظهر خريطة المواقف والحالة المباشرة لاحقاً.',
            icon: Icons.map_outlined,
          ),
          const _HistoryTab(),
          const _VehiclesTab(),
          const _PlaceholderTab(
            title: 'حسابي',
            description: 'هنا ستظهر بيانات المستخدم والإعدادات وتحديث الحساب.',
            icon: Icons.person_outline_rounded,
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
    final started = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const SelectVehicleScreen(),
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

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.hasActiveSession,
    required this.onStartSession,
    required this.onEndSession,
  });

  final bool hasActiveSession;
  final VoidCallback onStartSession;
  final VoidCallback onEndSession;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0F766E),
                Color(0xFF17867D),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'مرحباً، روعة',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'إدارة جلسات الوقوف والمركبات من مكان واحد.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'رصيد المحفظة',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '42.00 شيكل',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (hasActiveSession)
          _ActiveSessionCard(onEndSession: onEndSession)
        else
          _EmptySessionCard(onStartSession: onStartSession),
        const SizedBox(height: 18),
        _SectionCard(
          title: 'النشاط الأخير',
          child: Text(
            hasActiveSession
                ? 'تم بدء جلسة وقوف تجريبية للمركبة 24-381-15.'
                : 'هذا القسم مخصص لعرض آخر جلسة أو آخر إشعار أو آخر عملية دفع.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5B6472),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        Text(
          'سجل النشاط',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'نموذج مبدئي لسجل جلسات الوقوف والمدفوعات والمخالفات.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF5B6472),
          ),
        ),
        const SizedBox(height: 18),
        const _HistoryItemCard(
          icon: Icons.local_parking_outlined,
          title: 'جلسة وقوف مكتملة',
          subtitle: 'المركبة 24-381-15 • شارع عين سارة',
          trailing: '30 دقيقة',
          amount: '1 شيكل',
          status: 'مدفوعة',
        ),
        const SizedBox(height: 12),
        const _HistoryItemCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'شحن المحفظة',
          subtitle: 'Jawwal Pay',
          trailing: 'اليوم',
          amount: '+20 شيكل',
          status: 'ناجحة',
        ),
        const SizedBox(height: 12),
        const _HistoryItemCard(
          icon: Icons.gavel_outlined,
          title: 'مخالفة وقوف',
          subtitle: 'المركبة 31-662-08 • صورة مرفقة',
          trailing: 'أمس',
          amount: '15 شيكل',
          status: 'بانتظار الدفع',
        ),
      ],
    );
  }
}

class _VehiclesTab extends StatelessWidget {
  const _VehiclesTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مركباتي',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'إدارة المركبات المرتبطة بحسابك.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5B6472),
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filled(
              onPressed: () {},
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _VehicleListCard(
          plateNumber: '24-381-15',
          model: 'Hyundai i20',
          status: 'مركبة مفعلة',
        ),
        const SizedBox(height: 12),
        const _VehicleListCard(
          plateNumber: '31-662-08',
          model: 'Kia Picanto',
          status: 'مركبة مفعلة',
        ),
      ],
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  const _HistoryItemCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.amount,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final String amount;
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F2EF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF0F766E)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      trailing,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5B6472),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      amount,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2EEE5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        status,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: const Color(0xFF5B6472),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleListCard extends StatelessWidget {
  const _VehicleListCard({
    required this.plateNumber,
    required this.model,
    required this.status,
  });

  final String plateNumber;
  final String model;
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F2EF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.directions_car_outlined,
              color: Color(0xFF0F766E),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plateNumber,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  model,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5B6472),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF0F766E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
    );
  }
}

class _EmptySessionCard extends StatelessWidget {
  const _EmptySessionCard({required this.onStartSession});

  final VoidCallback onStartSession;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _SectionCard(
      title: 'حالة الوقوف الحالية',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'لا توجد جلسة وقوف نشطة حالياً.',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ جلسة جديدة باختيار المركبة والموقع والمدة وطريقة الدفع.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF5B6472),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onStartSession,
            icon: const Icon(Icons.local_parking_outlined),
            label: const Text('ابدأ جلسة وقوف'),
          ),
        ],
      ),
    );
  }
}

class _ActiveSessionCard extends StatelessWidget {
  const _ActiveSessionCard({required this.onEndSession});

  final VoidCallback onEndSession;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _SectionCard(
      title: 'جلسة وقوف نشطة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: SizedBox(
              width: 170,
              height: 170,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: 0.67,
                      strokeWidth: 12,
                      backgroundColor: const Color(0xFFE7E1D6),
                      color: const Color(0xFF0F766E),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '20',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F766E),
                        ),
                      ),
                      Text(
                        'دقيقة متبقية',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF5B6472),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _SessionDetailRow(
            icon: Icons.directions_car_outlined,
            label: 'المركبة',
            value: '24-381-15',
          ),
          const _SessionDetailRow(
            icon: Icons.place_outlined,
            label: 'الموقع',
            value: 'الموقع الحالي',
          ),
          const _SessionDetailRow(
            icon: Icons.payments_outlined,
            label: 'الدفع',
            value: 'المحفظة',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('تمديد الوقت'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onEndSession,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    side: const BorderSide(color: Color(0xFF0F766E)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('إنهاء الجلسة'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionDetailRow extends StatelessWidget {
  const _SessionDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0F766E)),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5B6472),
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F2EF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF0F766E),
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5B6472),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
