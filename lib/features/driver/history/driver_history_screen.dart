import 'package:flutter/material.dart';

import 'package:flut/features/driver/history/models/driver_activity_item.dart';
import 'package:flut/features/driver/history/services/activity_service.dart';

class DriverHistoryScreen extends StatefulWidget {
  const DriverHistoryScreen({super.key});

  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen> {
  final _activityService = ActivityService();

  int _selectedFilterIndex = 0;
  bool _isLoading = true;
  List<DriverActivityItem> _items = const [];

  List<DriverActivityItem> get _filteredItems {
    switch (_selectedFilterIndex) {
      case 1:
        return _items.where((item) => item.isSession).toList();
      case 2:
        return _items.where((item) => item.isTransaction).toList();
      case 3:
        return _items.where((item) => item.isFine).toList();
      default:
        return _items;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _filteredItems;

    return RefreshIndicator(
      onRefresh: _loadActivity,
      child: ListView(
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
            'راجعي جلسات الوقوف والمدفوعات والمخالفات السابقة من مكان واحد.',
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
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (items.isEmpty)
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
      ),
    );
  }

  Future<void> _loadActivity() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final activity = await _activityService.getActivity();
      if (!mounted) return;
      setState(() {
        _items = activity;
      });
    } on ActivityException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class DriverHistoryDetailsScreen extends StatelessWidget {
  const DriverHistoryDetailsScreen({
    super.key,
    required this.item,
  });

  final DriverActivityItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detailEntries = _detailEntries(item);

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
                        color: _itemColor(item).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(_itemIcon(item), color: _itemColor(item)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _itemTitle(item),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _itemSubtitle(item),
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
                ...detailEntries.entries.map(
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
                        _statusLabel(item),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: _statusColor(item),
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

  final DriverActivityItem item;
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
                color: _itemColor(item).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(_itemIcon(item), color: _itemColor(item)),
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
                          _itemTitle(item),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        _dateLabel(item.date),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _itemSubtitle(item),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF5B6472),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        _amountLabel(item),
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
                          _statusLabel(item),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: _statusColor(item),
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

IconData _itemIcon(DriverActivityItem item) {
  if (item.isSession) return Icons.local_parking_outlined;
  if (item.isFine) return Icons.gavel_outlined;
  return Icons.account_balance_wallet_outlined;
}

Color _itemColor(DriverActivityItem item) {
  if (item.isSession) return const Color(0xFF0F766E);
  if (item.isFine) return const Color(0xFFC8922E);
  return const Color(0xFF2563EB);
}

String _itemTitle(DriverActivityItem item) {
  if (item.isSession) return 'جلسة وقوف';
  if (item.isFine) return item.violationName?.trim().isNotEmpty == true ? item.violationName! : 'مخالفة';

  switch (item.transactionType) {
    case 'top_up':
      return 'شحن المحفظة';
    case 'session_start':
      return 'دفع بدء الجلسة';
    case 'session_extension':
      return 'دفع تمديد الجلسة';
    case 'refund':
      return 'استرجاع رصيد';
    default:
      return 'عملية محفظة';
  }
}

String _itemSubtitle(DriverActivityItem item) {
  if (item.isSession) {
    final plate = item.licensePlate ?? 'غير متوفر';
    final duration = item.durationMinutes == null ? '' : ' • ${item.durationMinutes} دقيقة';
    return 'المركبة $plate$duration';
  }

  if (item.isFine) {
    final plate = item.licensePlate ?? 'غير متوفر';
    return 'المركبة $plate';
  }

  switch (item.transactionType) {
    case 'top_up':
      return 'تمت إضافة رصيد إلى المحفظة';
    case 'session_start':
      return 'تم خصم رسوم بدء جلسة الوقوف';
    case 'session_extension':
      return 'تم خصم رسوم تمديد الجلسة';
    case 'refund':
      return 'تم استرجاع مبلغ إلى المحفظة';
    default:
      return 'عملية مالية مرتبطة بالمحفظة';
  }
}

String _amountLabel(DriverActivityItem item) {
  final amount = item.amount ?? 0;
  if (item.isTransaction && item.transactionType == 'top_up') {
    return '+${amount.toStringAsFixed(0)} شيكل';
  }
  if (item.isTransaction && item.transactionType == 'refund') {
    return '+${amount.toStringAsFixed(0)} شيكل';
  }
  return '${amount.toStringAsFixed(0)} شيكل';
}

String _statusLabel(DriverActivityItem item) {
  if (item.isSession) {
    switch (item.status) {
      case 'active':
        return 'نشطة';
      case 'ended':
        return 'منتهية';
      default:
        return item.status;
    }
  }

  if (item.isFine) {
    switch (item.status) {
      case 'paid':
        return 'مدفوعة';
      case 'unpaid':
        return 'بانتظار الدفع';
      default:
        return item.status;
    }
  }

  return 'ناجحة';
}

Color _statusColor(DriverActivityItem item) {
  final status = _statusLabel(item);
  if (status == 'بانتظار الدفع') return const Color(0xFFD63C31);
  if (status == 'نشطة') return const Color(0xFF2563EB);
  return const Color(0xFF0F766E);
}

String _dateLabel(DateTime? dateTime) {
  if (dateTime == null) return 'الآن';

  final local = dateTime.toLocal();
  final now = DateTime.now();
  final diff = now.difference(local);

  if (diff.inDays == 0) return 'اليوم';
  if (diff.inDays == 1) return 'أمس';
  return '${local.day}/${local.month}/${local.year}';
}

Map<String, String> _detailEntries(DriverActivityItem item) {
  if (item.isSession) {
    return {
      'نوع العملية': 'جلسة وقوف',
      'المركبة': item.licensePlate ?? 'غير متوفر',
      'المدة': item.durationMinutes == null ? 'غير متوفرة' : '${item.durationMinutes} دقيقة',
      'الموقع': '${item.latitude?.toStringAsFixed(4) ?? '-'}, ${item.longitude?.toStringAsFixed(4) ?? '-'}',
      'المبلغ': _amountLabel(item),
      'التاريخ': item.date?.toLocal().toString() ?? 'غير متوفر',
    };
  }

  if (item.isFine) {
    return {
      'نوع العملية': 'مخالفة',
      'المركبة': item.licensePlate ?? 'غير متوفر',
      'نوع المخالفة': item.violationName ?? 'غير متوفر',
      'الموقع': '${item.latitude?.toStringAsFixed(4) ?? '-'}, ${item.longitude?.toStringAsFixed(4) ?? '-'}',
      'المبلغ': _amountLabel(item),
      'التاريخ': item.date?.toLocal().toString() ?? 'غير متوفر',
    };
  }

  return {
    'نوع العملية': _itemTitle(item),
    'نوع الحركة': item.transactionType ?? 'غير متوفر',
    'المبلغ': _amountLabel(item),
    'التاريخ': item.date?.toLocal().toString() ?? 'غير متوفر',
  };
}

const _historyFilters = [
  'الكل',
  'جلسات الوقوف',
  'المدفوعات',
  'المخالفات',
];
