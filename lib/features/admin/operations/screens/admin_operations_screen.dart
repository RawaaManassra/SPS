import 'package:flutter/material.dart';

import 'package:flut/features/admin/clamps/models/admin_clamp_event.dart';
import 'package:flut/features/admin/complaints/screens/admin_complaints_screen.dart';
import 'package:flut/features/admin/fines/models/admin_fine.dart';
import 'package:flut/features/admin/operations/services/admin_operations_service.dart';
import 'package:flut/features/admin/violations/models/admin_violation_type.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
              Tab(text: 'أنواع المخالفات'),
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
              _AdminViolationTypesPanel(),
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
                    'المفتش: #${item.inspectorId} • السيارة: ${item.vehicleId != null ? '#${item.vehicleId}' : 'غير مسجلة #${item.unregisteredVehicleId ?? 0}'}',
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

class _AdminViolationTypesPanel extends StatefulWidget {
  const _AdminViolationTypesPanel();

  @override
  State<_AdminViolationTypesPanel> createState() =>
      _AdminViolationTypesPanelState();
}

class _AdminViolationTypesPanelState extends State<_AdminViolationTypesPanel> {
  final _service = AdminOperationsService();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  List<AdminViolationType> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return _OperationsCard(
      title: 'أنواع المخالفات',
      leadingAction: ElevatedButton.icon(
        onPressed: _isSaving ? null : _createViolationType,
        icon: const Icon(Icons.add_rounded),
        label: const Text('إضافة نوع'),
      ),
      onRefresh: _isLoading ? null : _load,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      onRetry: _load,
      isEmpty: _items.isEmpty,
      emptyMessage: 'لا توجد أنواع مخالفات حالياً.',
      children: _items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DataTile(
                title: item.name,
                subtitle: 'القيمة: ${item.amount.toStringAsFixed(0)} شيكل',
                trailing: '#${item.id}',
                actionLabel: 'تعديل',
                onAction: _isSaving ? null : () => _editViolationType(item),
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
      final result = await _service.getViolationTypes();
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

  Future<void> _createViolationType() async {
    final payload = await _showViolationTypeDialog();
    if (!mounted || payload == null) return;

    setState(() => _isSaving = true);
    try {
      await _service.addViolationType(
        name: payload.name,
        amount: payload.amount,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة نوع المخالفة بنجاح.')),
      );
      await _load();
    } on AdminOperationsException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isSaving = false);
    }
  }

  Future<void> _editViolationType(AdminViolationType item) async {
    final payload = await _showViolationTypeDialog(item: item);
    if (!mounted || payload == null) return;

    setState(() => _isSaving = true);
    try {
      await _service.updateViolationType(
        violationId: item.id,
        name: payload.name,
        amount: payload.amount,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث نوع المخالفة بنجاح.')),
      );
      await _load();
    } on AdminOperationsException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isSaving = false);
    }
  }

  Future<_ViolationTypePayload?> _showViolationTypeDialog({
    AdminViolationType? item,
  }) async {
    final nameController = TextEditingController(text: item?.name ?? '');
    final amountController =
        TextEditingController(text: item == null ? '' : item.amount.toString());
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<_ViolationTypePayload>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item == null ? 'إضافة نوع مخالفة' : 'تعديل نوع مخالفة'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'اسم المخالفة'),
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'هذا الحقل مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'القيمة'),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) return 'هذا الحقل مطلوب';
                    if (double.tryParse(text) == null) return 'أدخلي رقماً صحيحاً';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                Navigator.of(context).pop(
                  _ViolationTypePayload(
                    name: nameController.text.trim(),
                    amount: double.parse(amountController.text.trim()),
                  ),
                );
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    amountController.dispose();
    return result;
  }
}

class _OperationsCard extends StatelessWidget {
  const _OperationsCard({
    required this.title,
    this.leadingAction,
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
  final Widget? leadingAction;
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
              if (leadingAction != null) ...[
                leadingAction!,
                const SizedBox(width: 10),
              ],
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
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final String? details;
  final String? actionLabel;
  final VoidCallback? onAction;

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
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
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

class _ViolationTypePayload {
  const _ViolationTypePayload({
    required this.name,
    required this.amount,
  });

  final String name;
  final double amount;
}

String _formatDate(DateTime? date) {
  if (date == null) return 'غير متوفر';
  return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
}
