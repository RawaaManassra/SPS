import 'package:flutter/material.dart';

import 'package:flut/features/admin/complaints/models/admin_complaint.dart';
import 'package:flut/features/admin/complaints/services/admin_complaint_service.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  final _service = AdminComplaintService();

  bool _isLoading = true;
  String? _errorMessage;
  String _selectedStatus = 'all';
  int? _updatingComplaintId;
  List<AdminComplaint> _complaints = const [];

  static const _statusOptions = [
    ('all', 'الكل'),
    ('pending', 'جديدة'),
    ('reviewed', 'قيد المراجعة'),
    ('resolved', 'محلولة'),
  ];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
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
                      'الشكاوى والاعتراضات',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'عرض الشكاوى الواردة وتحديث حالتها.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5B6472),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _loadComplaints,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('تحديث'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _statusOptions.map((option) {
              final selected = _selectedStatus == option.$1;
              return ChoiceChip(
                selected: selected,
                label: Text(option.$2),
                onSelected: (_) {
                  setState(() {
                    _selectedStatus = option.$1;
                  });
                  _loadComplaints();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            _AdminComplaintsErrorCard(
              message: _errorMessage!,
              onRetry: _loadComplaints,
            )
          else if (_complaints.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7F3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text('لا توجد شكاوى ضمن هذا التصنيف حالياً.'),
            )
          else
            ...List.generate(_complaints.length, (index) {
              final complaint = _complaints[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == _complaints.length - 1 ? 0 : 12,
                ),
                child: _AdminComplaintTile(
                  complaint: complaint,
                  isUpdating: _updatingComplaintId == complaint.id,
                  onChangeStatus: (status) =>
                      _changeComplaintStatus(complaint.id, status),
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _loadComplaints() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final complaints = await _service.getComplaints(
        status: _selectedStatus == 'all' ? null : _selectedStatus,
      );
      if (!mounted) return;
      setState(() {
        _complaints = complaints;
      });
    } on AdminComplaintException catch (error) {
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

  Future<void> _changeComplaintStatus(int complaintId, String status) async {
    setState(() {
      _updatingComplaintId = complaintId;
    });

    try {
      await _service.updateComplaintStatus(
        complaintId: complaintId,
        status: status,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث حالة الشكوى بنجاح.')),
      );
      await _loadComplaints();
    } on AdminComplaintException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _updatingComplaintId = null;
      });
    }
  }
}

class _AdminComplaintTile extends StatelessWidget {
  const _AdminComplaintTile({
    required this.complaint,
    required this.isUpdating,
    required this.onChangeStatus,
  });

  final AdminComplaint complaint;
  final bool isUpdating;
  final ValueChanged<String> onChangeStatus;

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
                  complaint.complaintType,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _ComplaintStatusBadge(status: complaint.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            complaint.description?.trim().isNotEmpty == true
                ? complaint.description!
                : 'لا يوجد وصف إضافي.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5B6472),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              Text(
                'المستخدم: #${complaint.userId}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF5B6472),
                ),
              ),
              Text(
                'التاريخ: ${_formatDate(complaint.createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF5B6472),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isUpdating ? null : () => onChangeStatus('reviewed'),
                  child: isUpdating && complaint.status != 'reviewed'
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('قيد المراجعة'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: isUpdating ? null : () => onChangeStatus('resolved'),
                  child: const Text('تم الحل'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComplaintStatusBadge extends StatelessWidget {
  const _ComplaintStatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = switch (normalized) {
      'resolved' => const Color(0xFF0F766E),
      'reviewed' => const Color(0xFFB45309),
      _ => const Color(0xFFB42318),
    };
    final label = switch (normalized) {
      'resolved' => 'محلولة',
      'reviewed' => 'قيد المراجعة',
      _ => 'جديدة',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AdminComplaintsErrorCard extends StatelessWidget {
  const _AdminComplaintsErrorCard({
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

String _formatDate(DateTime? date) {
  if (date == null) return 'غير متوفر';
  return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
}
