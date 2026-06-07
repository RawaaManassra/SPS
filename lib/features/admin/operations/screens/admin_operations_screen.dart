import 'package:flutter/material.dart';

import 'package:flut/features/admin/clamps/models/admin_clamp_event.dart';
import 'package:flut/features/admin/complaints/screens/admin_complaints_screen.dart';
import 'package:flut/features/admin/fines/models/admin_fine.dart';
import 'package:flut/features/admin/operations/services/admin_operations_service.dart';

class AdminOperationsScreen extends StatefulWidget {
  const AdminOperationsScreen({super.key});

  @override
  State<AdminOperationsScreen> createState() => _AdminOperationsScreenState();
}

class _AdminOperationsScreenState extends State<AdminOperationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE8E3D7)),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: const Color(0xFF0F766E),
              borderRadius: BorderRadius.circular(16),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFF334155),
            tabs: const [
              Tab(text: 'الشكاوى'),
              Tab(text: 'المخالفات'),
              Tab(text: 'الكلبشات'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 820,
          child: TabBarView(
            controller: _tabController,
            children: const [
              AdminComplaintsScreen(),
              _AdminFinesPanel(),
              _AdminClampEventsPanel(),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminFinesPanel extends StatefulWidget {
  const _AdminFinesPanel();

  @override
  State<_AdminFinesPanel> createState() => _AdminFinesPanelState();
}

class _AdminFinesPanelState extends State<_AdminFinesPanel> {
  final _service = AdminOperationsService();
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedStatus = 'all';
  List<AdminFine> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return _OperationsCard(
      title: 'المخالفات',
      filters: _statusChips(
        value: _selectedStatus,
        options: const [
          ('all', 'الكل'),
          ('unpaid', 'غير مدفوعة'),
          ('paid', 'مدفوعة'),
        ],
        onSelect: (value) {
          setState(() => _selectedStatus = value);
          _load();
        },
      ),
      onRefresh: _isLoading ? null : _load,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      onRetry: _load,
      isEmpty: _items.isEmpty,
      emptyMessage: 'لا توجد مخالفات ضمن هذا التصنيف حالياً.',
      children: _items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DataTile(
                title: 'مخالفة #${item.id}',
                subtitle:
                    'المستخدم: #${item.userId} • المركبة: #${item.vehicleId} • المفتش: #${item.inspectorId}',
                trailing: item.status == 'paid' ? 'مدفوعة' : 'غير مدفوعة',
                details:
                    'الموقع: ${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)} • التاريخ: ${_formatDate(item.finedAt)}',
              ),
            ),
          )
          .toList(),
    );
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _service.getFines(
        status: _selectedStatus == 'all' ? null : _selectedStatus,
      );
      if (!mounted) return;
      setState(() => _items = result);
    } on AdminOperationsException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }
}

class _AdminClampEventsPanel extends StatefulWidget {
  const _AdminClampEventsPanel();

  @override
  State<_AdminClampEventsPanel> createState() => _AdminClampEventsPanelState();
}

class _AdminClampEventsPanelState extends State<_AdminClampEventsPanel> {
  final _service = AdminOperationsService();
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedStatus = 'all';
  List<AdminClampEvent> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return _OperationsCard(
      title: 'سجلات الكلبشة',
      filters: _statusChips(
        value: _selectedStatus,
        options: const [
          ('all', 'الكل'),
          ('clamped', 'مكلبشة'),
          ('unclamped', 'مفكوكة'),
        ],
        onSelect: (value) {
          setState(() => _selectedStatus = value);
          _load();
        },
      ),
      onRefresh: _isLoading ? null : _load,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      onRetry: _load,
      isEmpty: _items.isEmpty,
      emptyMessage: 'لا توجد سجلات كلبشة ضمن هذا التصنيف حالياً.',
      children: _items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DataTile(
                title: 'كلبشة #${item.id}',
                subtitle:
                    'المفتش: ${item.inspectorName?.trim().isNotEmpty == true ? item.inspectorName! : 'غير محدد'}',
                trailing: item.status == 'clamped' ? 'مكلبشة' : 'مفكوكة',
                details:
                    'الموقع: ${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)} • التاريخ: ${_formatDate(item.clampedAt)}',
              ),
            ),
          )
          .toList(),
    );
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _service.getClampEvents(
        status: _selectedStatus == 'all' ? null : _selectedStatus,
      );
      if (!mounted) return;
      setState(() => _items = result);
    } on AdminOperationsException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }
}

class _OperationsCard extends StatelessWidget {
  const _OperationsCard({
    required this.title,
    this.filters,
    required this.onRefresh,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.isEmpty,
    required this.emptyMessage,
    required this.children,
  });

  final String title;
  final Widget? filters;
  final VoidCallback? onRefresh;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final bool isEmpty;
  final String emptyMessage;
  final List<Widget> children;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('تحديث'),
              ),
            ],
          ),
          if (filters != null) ...[
            const SizedBox(height: 18),
            filters!,
          ],
          const SizedBox(height: 18),
          if (isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (errorMessage != null)
            _OperationsErrorCard(message: errorMessage!, onRetry: onRetry)
          else if (isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7F3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(emptyMessage),
            )
          else
            Expanded(
              child: ListView(
                children: children,
              ),
            ),
        ],
      ),
    );
  }
}

class _DataTile extends StatelessWidget {
  const _DataTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.details,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final String? details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF0F766E),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5B6472),
            ),
          ),
          if (details != null) ...[
            const SizedBox(height: 8),
            Text(
              details!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF5B6472),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OperationsErrorCard extends StatelessWidget {
  const _OperationsErrorCard({
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
          Text(
            message,
            textAlign: TextAlign.center,
          ),
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

Widget _statusChips({
  required String value,
  required List<(String, String)> options,
  required ValueChanged<String> onSelect,
}) {
  return Wrap(
    spacing: 10,
    runSpacing: 10,
    children: options.map((option) {
      return ChoiceChip(
        selected: value == option.$1,
        label: Text(option.$2),
        onSelected: (_) => onSelect(option.$1),
      );
    }).toList(),
  );
}

String _formatDate(DateTime? date) {
  if (date == null) return 'غير متوفر';
  return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
}
