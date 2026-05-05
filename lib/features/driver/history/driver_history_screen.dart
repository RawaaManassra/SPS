import 'package:flutter/material.dart';

class DriverHistoryScreen extends StatefulWidget {
  const DriverHistoryScreen({super.key});

  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen> {
  int _selectedFilterIndex = 0;

  final List<_HistoryItem> _items = const [
    _HistoryItem(
      type: _HistoryType.session,
      title: 'جلسة وقوف مكتملة',
      subtitle: 'المركبة 24-381-15 • باب الزاوية',
      trailing: 'اليوم',
      amount: '1 شيكل',
      status: 'مدفوعة',
      details: {
        'نوع العملية': 'جلسة وقوف',
        'المركبة': '24-381-15',
        'الموقع': 'باب الزاوية',
        'المدة': '30 دقيقة',
        'طريقة الدفع': 'المحفظة',
        'المبلغ': '1 شيكل',
      },
    ),
    _HistoryItem(
      type: _HistoryType.wallet,
      title: 'شحن المحفظة',
      subtitle: 'تمت إضافة رصيد جديد إلى المحفظة',
      trailing: 'اليوم',
      amount: '+20 شيكل',
      status: 'ناجحة',
      details: {
        'نوع العملية': 'شحن محفظة',
        'وسيلة الدفع': 'Jawwal Pay',
        'المبلغ': '+20 شيكل',
        'الحالة': 'ناجحة',
      },
    ),
    _HistoryItem(
      type: _HistoryType.violation,
      title: 'مخالفة وقوف',
      subtitle: 'المركبة 31-662-08 • منطقة البلدية',
      trailing: 'أمس',
      amount: '15 شيكل',
      status: 'بانتظار الدفع',
      details: {
        'نوع العملية': 'مخالفة',
        'المركبة': '31-662-08',
        'الموقع': 'منطقة البلدية',
        'السبب': 'انتهاء مدة الوقوف',
        'المبلغ': '15 شيكل',
        'الحالة': 'بانتظار الدفع',
      },
    ),
    _HistoryItem(
      type: _HistoryType.session,
      title: 'جلسة وقوف مكتملة',
      subtitle: 'المركبة 31-662-08 • عين سارة',
      trailing: '28 نيسان',
      amount: '3 شيكل',
      status: 'مدفوعة',
      details: {
        'نوع العملية': 'جلسة وقوف',
        'المركبة': '31-662-08',
        'الموقع': 'عين سارة',
        'المدة': 'ساعة و 30 دقيقة',
        'طريقة الدفع': 'بطاقة بنكية',
        'المبلغ': '3 شيكل',
      },
    ),
  ];

  List<_HistoryItem> get _filteredItems {
    switch (_selectedFilterIndex) {
      case 1:
        return _items.where((item) => item.type == _HistoryType.session).toList();
      case 2:
        return _items.where((item) => item.type == _HistoryType.wallet).toList();
      case 3:
        return _items.where((item) => item.type == _HistoryType.violation).toList();
      default:
        return _items;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _filteredItems;

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
          'راجع جلسات الوقوف والمدفوعات والمخالفات السابقة من مكان واحد.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF5B6472),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List.generate(_historyFilters.length, (index) {
              return Padding(
                padding: EdgeInsets.only(left: index == _historyFilters.length - 1 ? 0 : 8),
                child: _HistoryFilterChip(
                  label: _historyFilters[index],
                  selected: _selectedFilterIndex == index,
                  onTap: () {
                    setState(() {
                      _selectedFilterIndex = index;
                    });
                  },
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 18),
        if (items.isEmpty)
          const _EmptyHistoryState()
        else
          ...List.generate(items.length, (index) {
            final item = items[index];
            return Padding(
              padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 12),
              child: HistoryItemCard(
                item: item,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DriverHistoryDetailsScreen(item: item),
                    ),
                  );
                },
              ),
            );
          }),
      ],
    );
  }
}

class DriverHistoryDetailsScreen extends StatelessWidget {
  const DriverHistoryDetailsScreen({
    super.key,
    required this.item,
  });

  final _HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل العملية'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(item.icon, color: item.color),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF5B6472),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ...item.details.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _HistoryDetailRow(
                      label: entry.key,
                      value: entry.value,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F2EB),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'الحالة',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF5B6472),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.status,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: item.statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryItemCard extends StatelessWidget {
  const HistoryItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final _HistoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(item.icon, color: item.color),
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
                          item.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        item.trailing,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF5B6472),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        item.amount,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2EEE5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item.status,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: item.statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _HistoryFilterChip extends StatelessWidget {
  const _HistoryFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F766E) : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? Colors.white : const Color(0xFF1F2937),
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F2EF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.history_toggle_off_rounded,
              color: Color(0xFF0F766E),
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'لا يوجد سجل حالياً',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر هنا جلسات الوقوف السابقة والمدفوعات والمخالفات عند توفرها.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5B6472),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryDetailRow extends StatelessWidget {
  const _HistoryDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5B6472),
              ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ],
    );
  }
}

enum _HistoryType {
  session,
  wallet,
  violation,
}

class _HistoryItem {
  const _HistoryItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.amount,
    required this.status,
    required this.details,
  });

  final _HistoryType type;
  final String title;
  final String subtitle;
  final String trailing;
  final String amount;
  final String status;
  final Map<String, String> details;

  IconData get icon {
    switch (type) {
      case _HistoryType.session:
        return Icons.local_parking_outlined;
      case _HistoryType.wallet:
        return Icons.account_balance_wallet_outlined;
      case _HistoryType.violation:
        return Icons.gavel_outlined;
    }
  }

  Color get color {
    switch (type) {
      case _HistoryType.session:
        return const Color(0xFF0F766E);
      case _HistoryType.wallet:
        return const Color(0xFF2563EB);
      case _HistoryType.violation:
        return const Color(0xFFC8922E);
    }
  }

  Color get statusColor {
    if (status == 'بانتظار الدفع') {
      return const Color(0xFFD63C31);
    }
    return const Color(0xFF0F766E);
  }
}

const _historyFilters = [
  'الكل',
  'جلسات الوقوف',
  'المدفوعات',
  'المخالفات',
];
