import 'package:flutter/material.dart';

import 'package:flut/features/admin/inspectors/models/admin_add_inspector_request.dart';
import 'package:flut/features/admin/inspectors/services/admin_inspector_service.dart';
import 'package:flut/features/admin/models/admin_dashboard_data.dart';
import 'package:flut/features/admin/services/admin_dashboard_service.dart';

class AdminInspectorsScreen extends StatefulWidget {
  const AdminInspectorsScreen({super.key});

  @override
  State<AdminInspectorsScreen> createState() => _AdminInspectorsScreenState();
}

class _AdminInspectorsScreenState extends State<AdminInspectorsScreen> {
  final AdminInspectorService _inspectorService = AdminInspectorService();
  final AdminDashboardService _dashboardService = AdminDashboardService();

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<AdminInspectorPerformance> _inspectors = const [];

  @override
  void initState() {
    super.initState();
    _loadInspectors();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wide = MediaQuery.of(context).size.width >= 1100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: _buildInspectorList(theme),
              ),
              const SizedBox(width: 18),
              Expanded(
                flex: 4,
                child: _AddInspectorCard(
                  isSubmitting: _isSubmitting,
                  onSubmit: _submitInspector,
                ),
              ),
            ],
          )
        else ...[
          _AddInspectorCard(
            isSubmitting: _isSubmitting,
            onSubmit: _submitInspector,
          ),
          const SizedBox(height: 18),
          _buildInspectorList(theme),
        ],
      ],
    );
  }

  Widget _buildInspectorList(ThemeData theme) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المفتشون النشطون اليوم',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _loadInspectors,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('تحديث'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            _AdminInspectorErrorCard(
              message: _errorMessage!,
              onRetry: _loadInspectors,
            )
          else if (_inspectors.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7F3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'لا توجد بيانات أداء للمفتشين اليوم حتى الآن.',
              ),
            )
          else
            ..._inspectors.asMap().entries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(bottom: entry.key == _inspectors.length - 1 ? 0 : 12),
                child: _InspectorPerformanceListTile(
                  rank: entry.key + 1,
                  performance: entry.value,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _loadInspectors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dashboard = await _dashboardService.getDashboard();
      if (!mounted) return;
      setState(() {
        _inspectors = dashboard.inspectors;
      });
    } on AdminDashboardException catch (error) {
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

  Future<void> _submitInspector(AdminAddInspectorRequest request) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await _inspectorService.addInspector(request);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة المفتش بنجاح.')),
      );
      await _loadInspectors();
    } on AdminInspectorException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر حفظ بيانات المفتش حالياً. حاولي مرة أخرى.'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}

class _AddInspectorCard extends StatefulWidget {
  const _AddInspectorCard({
    required this.isSubmitting,
    required this.onSubmit,
  });

  final bool isSubmitting;
  final Future<void> Function(AdminAddInspectorRequest request) onSubmit;

  @override
  State<_AddInspectorCard> createState() => _AddInspectorCardState();
}

class _AddInspectorCardState extends State<_AddInspectorCard> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'إضافة مفتش جديد',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'الاسم الكامل',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'اسم المستخدم',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nationalIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'رقم الهوية',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الجوال',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني (اختياري)',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: widget.isSubmitting ? null : _submit,
              icon: widget.isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.person_add_alt_1_rounded),
              label: Text(widget.isSubmitting ? 'جارٍ الحفظ...' : 'إضافة المفتش'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final request = AdminAddInspectorRequest(
      username: _usernameController.text.trim(),
      fullName: _fullNameController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
    );

    await widget.onSubmit(request);
    if (!mounted) return;

    _formKey.currentState?.reset();
    _usernameController.clear();
    _fullNameController.clear();
    _nationalIdController.clear();
    _phoneController.clear();
    _emailController.clear();
    _passwordController.clear();
  }

  String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }
}

class _InspectorPerformanceListTile extends StatelessWidget {
  const _InspectorPerformanceListTile({
    required this.rank,
    required this.performance,
  });

  final int rank;
  final AdminInspectorPerformance performance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F2EF),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F766E),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  performance.inspectorName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'مخالفات: ${performance.finesCount} • قفل: ${performance.clampsCount}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5B6472),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${performance.totalActions}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F766E),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminInspectorErrorCard extends StatelessWidget {
  const _AdminInspectorErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1B7B0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFB42318),
            size: 32,
          ),
          const SizedBox(height: 10),
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
