import 'package:flutter/material.dart';

import 'package:flut/features/officer/history/models/officer_history_item.dart';
import 'package:flut/features/officer/history/services/officer_history_service.dart';
import 'package:flut/features/officer/shared/officer_activity_refresh_signal.dart';

class OfficerHistoryScreen extends StatefulWidget {
  const OfficerHistoryScreen({super.key});

  @override
  State<OfficerHistoryScreen> createState() => _OfficerHistoryScreenState();
}

class _OfficerHistoryScreenState extends State<OfficerHistoryScreen> {
  final OfficerHistoryService _historyService = OfficerHistoryService();

  bool _isLoading = true;
  String? _errorMessage;
  List<OfficerHistoryItem> _items = const [];

  @override
  void initState() {
    super.initState();
    officerActivityRefreshSignal.addListener(_handleRefreshSignal);
    _loadHistory();
  }

  @override
  void dispose() {
    officerActivityRefreshSignal.removeListener(_handleRefreshSignal);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _loadHistory,
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
            'يعرض هذا القسم آخر المخالفات وحالات الكلبشة المرتبطة بحساب الشرطي.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5B6472),
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
          else if (_errorMessage != null)
            _OfficerHistoryErrorState(
              message: _errorMessage!,
              onRetry: _loadHistory,
            )
          else if (_items.isEmpty)
            const _EmptyOfficerHistoryState()
          else
            ...List.generate(_items.length, (index) {
              final item = _items[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == _items.length - 1 ? 0 : 12,
                ),
                child: _OfficerHistoryCard(
                  item: item,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            _OfficerHistoryDetailsScreen(item: item),
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

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _historyService.getHistory();
      if (!mounted) return;
      setState(() {
        _items = items;
      });
    } on OfficerHistoryException catch (error) {
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

  void _handleRefreshSignal() {
    _loadHistory();
  }
}

class _OfficerHistoryCard extends StatelessWidget {
  const _OfficerHistoryCard({
    required this.item,
    required this.onTap,
  });

  final OfficerHistoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor =
        item.isFine ? const Color(0xFF1F6F8B) : const Color(0xFFB45309);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(item.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF5B6472),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.displayTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.displaySubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5B6472),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.isFine ? 'مخالفة' : 'كلبشة',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                item.isFine ? Icons.gavel_rounded : Icons.lock_outline_rounded,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfficerHistoryDetailsScreen extends StatelessWidget {
  const _OfficerHistoryDetailsScreen({
    required this.item,
  });

  final OfficerHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل السجل')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
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
                Text(
                  item.displayTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                _HistoryDetailTile(
                  label: 'التاريخ',
                  value: _formatDateTime(item.date),
                ),
                if (item.licensePlate != null) ...[
                  const SizedBox(height: 12),
                  _HistoryDetailTile(
                    label: 'رقم اللوحة',
                    value: item.licensePlate!,
                  ),
                ],
                if (item.violationName != null) ...[
                  const SizedBox(height: 12),
                  _HistoryDetailTile(
                    label: 'نوع المخالفة',
                    value: item.violationName!,
                  ),
                ],
                if (item.amount != null) ...[
                  const SizedBox(height: 12),
                  _HistoryDetailTile(
                    label: 'القيمة',
                    value:
                        '${item.amount!.toStringAsFixed(item.amount! % 1 == 0 ? 0 : 2)} شيكل',
                  ),
                ],
                if (item.status != null) ...[
                  const SizedBox(height: 12),
                  _HistoryDetailTile(
                    label: 'الحالة',
                    value: item.status!,
                  ),
                ],
                if (item.localizedReason.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _HistoryDetailTile(
                    label: 'السبب',
                    value: item.localizedReason,
                  ),
                ],
                if (item.latitude != null && item.longitude != null) ...[
                  const SizedBox(height: 12),
                  _HistoryDetailTile(
                    label: 'الموقع',
                    value:
                        '${item.latitude!.toStringAsFixed(4)}, ${item.longitude!.toStringAsFixed(4)}',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryDetailTile extends StatelessWidget {
  const _HistoryDetailTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF5B6472),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfficerHistoryErrorState extends StatelessWidget {
  const _OfficerHistoryErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1B7B0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFB42318),
            size: 30,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 14),
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

class _EmptyOfficerHistoryState extends StatelessWidget {
  const _EmptyOfficerHistoryState();

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
            'سيظهر هنا سجل المخالفات والكلبشات الخاصة بحساب الشرطي عند توفره.',
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

String _formatDate(DateTime? date) {
  if (date == null) return 'غير متوفر';
  return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
}

String _formatDateTime(DateTime? date) {
  if (date == null) return 'غير متوفر';
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = date.hour >= 12 ? 'م' : 'ص';
  return '${_formatDate(date)} - $hour:$minute $suffix';
}
