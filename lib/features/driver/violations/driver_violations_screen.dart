import 'package:flutter/material.dart';

class DriverViolationsScreen extends StatefulWidget {
  const DriverViolationsScreen({super.key});

  @override
  State<DriverViolationsScreen> createState() => _DriverViolationsScreenState();
}

class _DriverViolationsScreenState extends State<DriverViolationsScreen> {
  final List<_ViolationItem> _violations = [
    const _ViolationItem(
      id: 'V-2031',
      plateNumber: '24-381-15',
      reason: 'انتهاء مدة الوقوف',
      amount: '30 شيكل',
      issuedAt: 'اليوم، 10:15 صباحاً',
      location: 'باب الزاوية',
      isPaid: false,
    ),
    const _ViolationItem(
      id: 'V-1986',
      plateNumber: '31-662-08',
      reason: 'الوقوف خارج المنطقة المخصصة',
      amount: '50 شيكل',
      issuedAt: '28 نيسان، 02:40 مساءً',
      location: 'منطقة البلدية',
      isPaid: true,
    ),
  ];

  void _markAsPaid(String id) {
    setState(() {
      final index = _violations.indexWhere((item) => item.id == id);
      if (index == -1) {
        return;
      }

      final current = _violations[index];
      _violations[index] = _ViolationItem(
        id: current.id,
        plateNumber: current.plateNumber,
        reason: current.reason,
        amount: current.amount,
        issuedAt: current.issuedAt,
        location: current.location,
        isPaid: true,
      );
    });
  }

  Future<void> _openDetails(_ViolationItem violation) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DriverViolationDetailsScreen(
          violation: violation,
          onMarkPaid: violation.isPaid ? null : () => _markAsPaid(violation.id),
        ),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unpaidCount = _violations.where((item) => !item.isPaid).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المخالفات'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6E8),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFF0D39B)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE7BF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFC8922E),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unpaidCount == 0
                            ? 'لا توجد مخالفات غير مدفوعة'
                            : 'لديك $unpaidCount مخالفة تحتاج إلى متابعة',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'يمكنك عرض التفاصيل وإكمال الدفع من هنا.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF5B6472),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(_violations.length, (index) {
            final violation = _violations[index];
            return Padding(
              padding: EdgeInsets.only(bottom: index == _violations.length - 1 ? 0 : 12),
              child: _ViolationCard(
                violation: violation,
                onTap: () => _openDetails(violation),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class DriverViolationDetailsScreen extends StatefulWidget {
  const DriverViolationDetailsScreen({
    super.key,
    required this.violation,
    this.onMarkPaid,
  });

  final _ViolationItem violation;
  final VoidCallback? onMarkPaid;

  @override
  State<DriverViolationDetailsScreen> createState() => _DriverViolationDetailsScreenState();
}

class _DriverViolationDetailsScreenState extends State<DriverViolationDetailsScreen> {
  bool _isProcessing = false;
  late bool _isPaid;

  @override
  void initState() {
    super.initState();
    _isPaid = widget.violation.isPaid;
  }

  Future<void> _completePayment() async {
    setState(() {
      _isProcessing = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) {
      return;
    }

    widget.onMarkPaid?.call();

    setState(() {
      _isProcessing = false;
      _isPaid = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تسجيل الدفع بنجاح.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المخالفة'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F2EB),
              borderRadius: BorderRadius.circular(28),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.image_outlined,
                  size: 38,
                  color: Color(0xFF5B6472),
                ),
                const SizedBox(height: 10),
                Text(
                  'صورة المخالفة ستظهر هنا',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5B6472),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.violation.reason,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                _DetailRow(label: 'رقم المخالفة', value: widget.violation.id),
                _DetailRow(label: 'رقم المركبة', value: widget.violation.plateNumber),
                _DetailRow(label: 'الموقع', value: widget.violation.location),
                _DetailRow(label: 'وقت الإصدار', value: widget.violation.issuedAt),
                _DetailRow(label: 'المبلغ', value: widget.violation.amount),
                _DetailRow(
                  label: 'الحالة',
                  value: _isPaid ? 'مدفوعة' : 'غير مدفوعة',
                  valueColor: _isPaid ? const Color(0xFF0F766E) : const Color(0xFFD63C31),
                ),
                const SizedBox(height: 20),
                if (_isPaid)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F2EF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      'تم تسديد هذه المخالفة بنجاح.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF0F766E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _completePayment,
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : const Text('إكمال الدفع'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViolationCard extends StatelessWidget {
  const _ViolationCard({
    required this.violation,
    required this.onTap,
  });

  final _ViolationItem violation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor =
        violation.isPaid ? const Color(0xFF0F766E) : const Color(0xFFD63C31);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                violation.isPaid ? Icons.check_circle_outline : Icons.report_gmailerrorred,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    violation.reason,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${violation.plateNumber} • ${violation.amount}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5B6472),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    violation.isPaid ? 'مدفوعة' : 'غير مدفوعة',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                    ),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
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
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }
}

class _ViolationItem {
  const _ViolationItem({
    required this.id,
    required this.plateNumber,
    required this.reason,
    required this.amount,
    required this.issuedAt,
    required this.location,
    required this.isPaid,
  });

  final String id;
  final String plateNumber;
  final String reason;
  final String amount;
  final String issuedAt;
  final String location;
  final bool isPaid;
}
