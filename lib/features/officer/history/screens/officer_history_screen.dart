import 'package:flutter/material.dart';

import 'package:flut/features/driver/history/driver_history_screen.dart';
import 'package:flut/features/driver/history/models/driver_activity_item.dart';
import 'package:flut/features/driver/history/services/activity_service.dart';

class OfficerHistoryScreen extends StatefulWidget {
  const OfficerHistoryScreen({super.key});

  @override
  State<OfficerHistoryScreen> createState() => _OfficerHistoryScreenState();
}

class _OfficerHistoryScreenState extends State<OfficerHistoryScreen> {
  final _activityService = ActivityService();

  bool _isLoading = true;
  List<DriverActivityItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            'تابع العمليات المسجلة على حساب الشرطي من مكان واحد.',
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
          else if (_items.isEmpty)
            const _EmptyOfficerHistoryState()
          else
            ...List.generate(_items.length, (index) {
              final item = _items[index];
              return Padding(
                padding: EdgeInsets.only(bottom: index == _items.length - 1 ? 0 : 12),
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
            'سيظهر هنا سجل نشاط الشرطي عند توفره من الباك.',
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
