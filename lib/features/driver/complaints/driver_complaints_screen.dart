import 'package:flutter/material.dart';

import 'package:flut/features/driver/complaints/models/driver_complaint.dart';
import 'package:flut/features/driver/complaints/services/complaint_service.dart';

class DriverComplaintsScreen extends StatefulWidget {
  const DriverComplaintsScreen({
    super.key,
    this.initialComplaintType,
    this.initialDescription,
  });

  final String? initialComplaintType;
  final String? initialDescription;

  @override
  State<DriverComplaintsScreen> createState() => _DriverComplaintsScreenState();
}

class _DriverComplaintsScreenState extends State<DriverComplaintsScreen> {
  final _complaintService = ComplaintService();

  List<DriverComplaint> _complaints = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الشكاوى والاعتراضات'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateComplaint,
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('شكوى جديدة'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadComplaints,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6F5),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'يمكنك من هنا تقديم شكوى أو اعتراض ومتابعة حالته لاحقاً.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF425466),
                        height: 1.5,
                      ),
                    ),
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
            else if (_complaints.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.inbox_outlined,
                      size: 40,
                      color: Color(0xFF8A8F98),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لا توجد شكاوى أو اعتراضات حالياً.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(_complaints.length, (index) {
                final complaint = _complaints[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: index == _complaints.length - 1 ? 0 : 12),
                  child: _ComplaintCard(
                    complaint: complaint,
                    onDelete: complaint.status.toLowerCase() == 'pending'
                        ? () => _deleteComplaint(complaint.id)
                        : null,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _loadComplaints() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final complaints = await _complaintService.getComplaints();
      if (!mounted) return;
      setState(() {
        _complaints = complaints;
      });
    } on ComplaintException catch (error) {
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

  Future<void> _openCreateComplaint() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _CreateComplaintScreen(
          initialComplaintType: widget.initialComplaintType,
          initialDescription: widget.initialDescription,
        ),
      ),
    );

    if (created == true) {
      await _loadComplaints();
    }
  }

  Future<void> _deleteComplaint(int complaintId) async {
    try {
      await _complaintService.deleteComplaint(complaintId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الشكوى بنجاح.')),
      );
      await _loadComplaints();
    } on ComplaintException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }
}

class _CreateComplaintScreen extends StatefulWidget {
  const _CreateComplaintScreen({
    required this.initialComplaintType,
    required this.initialDescription,
  });

  final String? initialComplaintType;
  final String? initialDescription;

  @override
  State<_CreateComplaintScreen> createState() => _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends State<_CreateComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _complaintService = ComplaintService();
  final _descriptionController = TextEditingController();
  String _selectedType = 'اعتراض على مخالفة';
  bool _isSubmitting = false;

  static const _complaintTypes = [
    'اعتراض على مخالفة',
    'شكوى خدمة',
    'استفسار',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialComplaintType != null && widget.initialComplaintType!.trim().isNotEmpty) {
      _selectedType = widget.initialComplaintType!;
    }
    _descriptionController.text = widget.initialDescription ?? '';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقديم شكوى'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'نوع الشكوى',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: _complaintTypes
                        .map(
                          (type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 6,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'أدخل وصف الشكوى أو الاعتراض';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'وصف الشكوى',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.edit_note_rounded),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitComplaint,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('إرسال الشكوى'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitComplaint() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _complaintService.createComplaint(
        complaintType: _selectedType,
        description: _descriptionController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال الشكوى بنجاح.')),
      );
      Navigator.of(context).pop(true);
    } on ComplaintException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}

class _ComplaintCard extends StatelessWidget {
  const _ComplaintCard({
    required this.complaint,
    this.onDelete,
  });

  final DriverComplaint complaint;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(complaint.status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  complaint.complaintType,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: const Color(0xFFB42318),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            complaint.description ?? 'لا يوجد وصف',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5B6472),
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                _statusLabel(complaint.status),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              Text(
                _formatDate(complaint.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8A8F98),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return 'تم الحل';
      case 'reviewed':
        return 'قيد المراجعة';
      default:
        return 'جديدة';
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return const Color(0xFF0F766E);
      case 'reviewed':
        return const Color(0xFFC8922E);
      default:
        return const Color(0xFFD63C31);
    }
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'بدون تاريخ';
    }
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
  }
}
