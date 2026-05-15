import 'package:flutter/material.dart';

import 'package:flut/features/driver/complaints/driver_complaints_screen.dart';
import 'package:flut/features/driver/violations/models/driver_fine.dart';
import 'package:flut/features/driver/violations/services/fine_service.dart';

class DriverViolationsScreen extends StatefulWidget {
  const DriverViolationsScreen({super.key});

  @override
  State<DriverViolationsScreen> createState() => _DriverViolationsScreenState();
}

class _DriverViolationsScreenState extends State<DriverViolationsScreen> {
  final _fineService = FineService();

  List<DriverFine> _fines = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFines();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unpaidCount = _fines.where((item) => !item.isPaid).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المخالفات'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openComplaints,
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('شكوى / اعتراض'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadFines,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6E8),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFF0D39B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
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
                              'يمكنك عرض التفاصيل وإكمال الدفع أو تقديم اعتراض من هنا.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF5B6472),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_fines.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.gpp_good_outlined,
                      size: 40,
                      color: Color(0xFF0F766E),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لا توجد مخالفات مسجلة حالياً.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(_fines.length, (index) {
                final fine = _fines[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: index == _fines.length - 1 ? 0 : 12),
                  child: _ViolationCard(
                    fine: fine,
                    onTap: () => _openDetails(fine),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _loadFines() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fines = await _fineService.getDriverFines();
      if (!mounted) return;
      setState(() {
        _fines = fines;
      });
    } on FineException catch (error) {
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

  Future<void> _openDetails(DriverFine fine) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DriverViolationDetailsScreen(fine: fine),
      ),
    );

    await _loadFines();
  }

  Future<void> _openComplaints() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const DriverComplaintsScreen(),
      ),
    );
  }
}

class DriverViolationDetailsScreen extends StatefulWidget {
  const DriverViolationDetailsScreen({
    super.key,
    required this.fine,
  });

  final DriverFine fine;

  @override
  State<DriverViolationDetailsScreen> createState() => _DriverViolationDetailsScreenState();
}

class _DriverViolationDetailsScreenState extends State<DriverViolationDetailsScreen> {
  final _fineService = FineService();

  bool _isProcessing = false;
  late bool _isPaid;

  @override
  void initState() {
    super.initState();
    _isPaid = widget.fine.isPaid;
  }

  Future<void> _completePayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await _fineService.payFine(widget.fine.id);
      if (!mounted) return;

      setState(() {
        _isPaid = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تسجيل دفع المخالفة بنجاح.'),
        ),
      );
    } on FineException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _openComplaint() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DriverComplaintsScreen(
          initialComplaintType: 'اعتراض على مخالفة',
          initialDescription:
              'اعتراض بخصوص المخالفة رقم ${widget.fine.id} للمركبة ${widget.fine.licensePlate} بسبب "${widget.fine.violationName}".',
        ),
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
            clipBehavior: Clip.antiAlias,
            child: widget.fine.photoUrl != null && widget.fine.photoUrl!.trim().isNotEmpty
                ? Image.network(
                    widget.fine.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _buildPhotoPlaceholder(theme),
                  )
                : _buildPhotoPlaceholder(theme),
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
                  widget.fine.violationName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                _DetailRow(label: 'رقم المخالفة', value: '#${widget.fine.id}'),
                _DetailRow(label: 'رقم المركبة', value: widget.fine.licensePlate),
                _DetailRow(
                  label: 'الموقع',
                  value: '${widget.fine.latitude?.toStringAsFixed(4) ?? '-'}, ${widget.fine.longitude?.toStringAsFixed(4) ?? '-'}',
                ),
                _DetailRow(label: 'وقت الإصدار', value: _formatDateTime(widget.fine.finedAt)),
                _DetailRow(label: 'المبلغ', value: '${widget.fine.amount} شيكل'),
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
                else ...[
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _completePayment,
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('إكمال الدفع'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _openComplaint,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      side: const BorderSide(color: Color(0xFF0F766E)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('تقديم اعتراض / شكوى'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder(ThemeData theme) {
    return Center(
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
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'بدون تاريخ';
    }
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'م' : 'ص';
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} - $hour:$minute $suffix';
  }
}

class _ViolationCard extends StatelessWidget {
  const _ViolationCard({
    required this.fine,
    required this.onTap,
  });

  final DriverFine fine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = fine.isPaid ? const Color(0xFF0F766E) : const Color(0xFFD63C31);

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
                fine.isPaid ? Icons.check_circle_outline : Icons.report_gmailerrorred,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fine.violationName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${fine.licensePlate} • ${fine.amount} شيكل',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5B6472),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fine.isPaid ? 'مدفوعة' : 'غير مدفوعة',
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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: valueColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
