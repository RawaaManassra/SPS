import 'package:flutter/material.dart';

import 'package:flut/features/officer/history/models/officer_history_item.dart';
import 'package:flut/features/officer/history/services/officer_history_service.dart';
import 'package:flut/features/officer/shared/officer_activity_refresh_signal.dart';

class OfficerHomeScreen extends StatefulWidget {
  const OfficerHomeScreen({
    super.key,
    required this.onOpenCheckOptions,
  });

  final VoidCallback onOpenCheckOptions;

  @override
  State<OfficerHomeScreen> createState() => _OfficerHomeScreenState();
}

class _OfficerHomeScreenState extends State<OfficerHomeScreen> {
  final OfficerHistoryService _historyService = OfficerHistoryService();

  bool _isLoadingSummary = true;
  int _todayFines = 0;
  int _todayClamps = 0;

  @override
  void initState() {
    super.initState();
    officerActivityRefreshSignal.addListener(_handleRefreshSignal);
    _loadTodaySummary();
  }

  @override
  void dispose() {
    officerActivityRefreshSignal.removeListener(_handleRefreshSignal);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
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
                'مرحباً، موظف التفتيش',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'تابع حالة المركبات، افحص اللوحات، وأصدر المخالفات من مكان واحد.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'الإجراء الرئيسي',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        _OfficerPrimaryActionCard(
          onTap: widget.onOpenCheckOptions,
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
                'ملخص اليوم',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              if (_isLoadingSummary)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _OfficerStatCard(
                        value: '$_todayClamps',
                        label: 'كلبشة مسجلة',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _OfficerStatCard(
                        value: '$_todayFines',
                        label: 'مخالفة صادرة',
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7F1),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFD3EBDD)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF2E7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF2F855A),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'ابدأ بفحص المركبة، ثم اختر بين إدخال رقم اللوحة أو تصويرها مباشرة بالكاميرا.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5B6472),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _loadTodaySummary() async {
    setState(() {
      _isLoadingSummary = true;
    });

    try {
      final items = await _historyService.getHistory();
      final today = DateTime.now();
      final todaysItems = items.where((item) {
        final date = item.date?.toLocal();
        if (date == null) return false;
        return date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
      }).toList();

      if (!mounted) return;
      setState(() {
        _todayFines = todaysItems.where((item) => item.isFine).length;
        _todayClamps = todaysItems.where((item) => item.isClamp).length;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _todayFines = 0;
        _todayClamps = 0;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingSummary = false;
      });
    }
  }

  void _handleRefreshSignal() {
    _loadTodaySummary();
  }
}

class _OfficerPrimaryActionCard extends StatelessWidget {
  const _OfficerPrimaryActionCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Ink(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0F766E),
              Color(0xFF17867D),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.directions_car_filled_outlined,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'فحص مركبة',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ابدأ الفحص ثم اختر بين إدخال رقم اللوحة أو تصوير اللوحة مباشرة.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _OfficerStatCard extends StatelessWidget {
  const _OfficerStatCard({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F3),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F766E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF5B6472),
            ),
          ),
        ],
      ),
    );
  }
}
