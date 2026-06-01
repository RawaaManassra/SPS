import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flut/features/officer/check/models/officer_vehicle_check_result.dart';
import 'package:flut/features/officer/check/officer_issue_fine_screen.dart';
import 'package:flut/features/officer/check/officer_set_clamp_screen.dart';
import 'package:flut/features/officer/check/services/officer_inspector_service.dart';

class OfficerCheckVehicleScreen extends StatefulWidget {
  const OfficerCheckVehicleScreen({
    super.key,
    this.initialScanMode = false,
  });

  final bool initialScanMode;

  @override
  State<OfficerCheckVehicleScreen> createState() =>
      _OfficerCheckVehicleScreenState();
}

class _OfficerCheckVehicleScreenState extends State<OfficerCheckVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _inspectorService = OfficerInspectorService();
  final _imagePicker = ImagePicker();

  bool _isLoading = false;
  bool _isImageMode = false;
  OfficerVehicleCheckResult? _result;

  @override
  void initState() {
    super.initState();
    _isImageMode = widget.initialScanMode;
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('فحص مركبة'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isImageMode
                        ? 'استخدمي الكاميرا أو اختاري صورة واضحة للوحة المركبة، وسنحاول استخراج الرقم منها ثم متابعة الفحص تلقائياً.'
                        : 'أدخلي رقم لوحة المركبة يدوياً. يجب إدخال رقم اللوحة الفعلي للمركبة، وليس رقم هوية المالك.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5B6472),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _EntryModeChip(
                          title: 'إدخال رقم اللوحة',
                          icon: Icons.keyboard_alt_outlined,
                          isSelected: !_isImageMode,
                          onTap: () {
                            setState(() {
                              _isImageMode = false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _EntryModeChip(
                          title: 'تصوير اللوحة',
                          icon: Icons.photo_camera_back_outlined,
                          isSelected: _isImageMode,
                          onTap: () {
                            setState(() {
                              _isImageMode = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isImageMode)
                    _PlateImageCard(
                      currentPlate: _plateController.text.trim().isEmpty
                          ? null
                          : _plateController.text.trim(),
                      isLoading: _isLoading,
                      onCameraTap: _isLoading
                          ? null
                          : () => _extractPlateFromImage(ImageSource.camera),
                      onGalleryTap: _isLoading
                          ? null
                          : () => _extractPlateFromImage(ImageSource.gallery),
                    )
                  else
                    TextFormField(
                      controller: _plateController,
                      validator: _plateValidator,
                      decoration: const InputDecoration(
                        labelText: 'رقم اللوحة',
                        prefixIcon: Icon(Icons.pin_outlined),
                      ),
                    ),
                  if (_plateController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F7F3),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_parking_outlined,
                            color: Color(0xFF0F766E),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'رقم اللوحة الحالي: ${_plateController.text.trim()}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _checkVehicle,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.search_rounded),
                    label:
                        Text(_isLoading ? 'جارٍ الفحص...' : 'فحص المركبة'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (_result != null)
            _ResultCard(
              result: _result!,
              onSetClamp: _result!.isUnregistered && !_result!.isCurrentlyClamped
                  ? _openSetClampScreen
                  : null,
              onRemoveClamp: _result!.isCurrentlyClamped ? _removeClamp : null,
              onIssueFine: _result!.vehicleId == null ? null : _openIssueFine,
            ),
        ],
      ),
    );
  }

  Future<void> _checkVehicle() async {
    if (_isImageMode) {
      if (_plateController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('التقطي صورة اللوحة أو استخرجي الرقم أولاً.'),
          ),
        );
        return;
      }
    } else if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final result = await _inspectorService.checkVehicle(
        _plateController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _result = result;
      });
    } on OfficerInspectorException catch (error) {
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

  Future<void> _extractPlateFromImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final plate =
          await _inspectorService.extractPlateFromImage(pickedFile.path);
      if (!mounted) return;

      setState(() {
        _plateController.text = plate;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم استخراج اللوحة: $plate')),
      );

      await _checkVehicle();
    } on OfficerInspectorException catch (error) {
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

  Future<void> _openSetClampScreen() async {
    final currentResult = _result;
    if (currentResult == null) return;

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OfficerSetClampScreen(result: currentResult),
      ),
    );

    if (!mounted || updated != true) return;

    setState(() {
      _result = currentResult.copyWith(
        status: 'clamped',
        clampedCount: (currentResult.clampedCount ?? 0) + 1,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تسجيل كلبشة السيارة بنجاح.'),
      ),
    );
  }

  Future<void> _removeClamp() async {
    final currentResult = _result;
    if (currentResult == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _inspectorService.unclamp(
        licensePlate: currentResult.licensePlate,
      );

      if (!mounted) return;
      setState(() {
        _result = currentResult.copyWith(
          status: 'unclamped',
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت إزالة الكلبشة بنجاح.'),
        ),
      );
    } on OfficerInspectorException catch (error) {
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

  Future<void> _openIssueFine() async {
    final currentResult = _result;
    if (currentResult == null) return;

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OfficerIssueFineScreen(result: currentResult),
      ),
    );

    if (!mounted || updated != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إصدار المخالفة بنجاح.'),
      ),
    );
  }

  String? _plateValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'أدخلي رقم اللوحة';
    }
    if (text.length < 4) {
      return 'أدخلي رقم لوحة صحيح';
    }
    return null;
  }
}

class _PlateImageCard extends StatelessWidget {
  const _PlateImageCard({
    required this.currentPlate,
    required this.isLoading,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  final String? currentPlate;
  final bool isLoading;
  final VoidCallback? onCameraTap;
  final VoidCallback? onGalleryTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7E1D6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F2EF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  currentPlate == null
                      ? Icons.photo_camera_outlined
                      : Icons.credit_card_outlined,
                  color: const Color(0xFF0F766E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentPlate == null
                          ? 'تصوير لوحة المركبة'
                          : 'تم استخراج رقم اللوحة',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentPlate == null
                          ? 'الزر الأساسي يفتح الكاميرا مباشرة، ويمكنك استخدام المعرض إذا كانت الصورة موجودة مسبقاً.'
                          : 'رقم اللوحة الحالي: $currentPlate',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF5B6472),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(),
            ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCameraTap,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('فتح الكاميرا'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGalleryTap,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('من المعرض'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    this.onSetClamp,
    this.onRemoveClamp,
    this.onIssueFine,
  });

  final OfficerVehicleCheckResult result;
  final VoidCallback? onSetClamp;
  final VoidCallback? onRemoveClamp;
  final VoidCallback? onIssueFine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(result);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: statusColor.withValues(alpha: 0.22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      _statusIcon(result),
                      color: statusColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.licensePlate,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _statusTitle(result),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _statusDescription(result),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF5B6472),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (onSetClamp != null || onRemoveClamp != null) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onRemoveClamp ?? onSetClamp,
                  icon: Icon(
                    onRemoveClamp != null
                        ? Icons.lock_open_rounded
                        : Icons.lock_outline_rounded,
                  ),
                  label: Text(
                    onRemoveClamp != null
                        ? 'إزالة الكلبشة'
                        : 'كلبشة السيارة',
                  ),
                ),
              ],
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
                'تفاصيل الفحص',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              _DetailTile(
                label: 'رقم اللوحة',
                value: result.licensePlate,
              ),
              if (result.vehicleType != null) ...[
                const SizedBox(height: 12),
                _DetailTile(
                  label: 'نوع المركبة',
                  value: result.vehicleType!,
                ),
              ],
              if (result.color != null) ...[
                const SizedBox(height: 12),
                _DetailTile(
                  label: 'لون المركبة',
                  value: result.color!,
                ),
              ],
              if (result.isActive) ...[
                const SizedBox(height: 12),
                _DetailTile(
                  label: 'بداية الجلسة',
                  value: _formatDateTime(result.startTime),
                ),
                const SizedBox(height: 12),
                _DetailTile(
                  label: 'نهاية الجلسة',
                  value: _formatDateTime(result.expiryTime),
                ),
                const SizedBox(height: 12),
                _DetailTile(
                  label: 'الوقت المتبقي',
                  value: result.timeRemaining ?? 'غير متوفر',
                ),
                const SizedBox(height: 12),
                _DetailTile(
                  label: 'الموقع',
                  value:
                      '${result.latitude?.toStringAsFixed(4) ?? '-'}, ${result.longitude?.toStringAsFixed(4) ?? '-'}',
                ),
              ] else if (result.isUnregistered || result.isCurrentlyClamped) ...[
                const SizedBox(height: 12),
                _DetailTile(
                  label: result.isCurrentlyClamped
                      ? 'حالة الكلبشة'
                      : 'عدد مرات القفل السابقة',
                  value: result.isCurrentlyClamped
                      ? 'مركبة مكلبشة حالياً'
                      : '${result.clampedCount ?? 0}',
                ),
                if (result.isCurrentlyClamped) ...[
                  const SizedBox(height: 12),
                  _DetailTile(
                    label: 'عدد مرات الكلبشة',
                    value: '${result.clampedCount ?? 0}',
                  ),
                ],
              ] else if (result.isRegistered) ...[
                const SizedBox(height: 12),
                const _DetailTile(
                  label: 'الحالة',
                  value: 'مركبة مسجلة، لكن لا توجد جلسة وقوف نشطة حالياً.',
                ),
              ] else ...[
                const SizedBox(height: 12),
                _DetailTile(
                  label: 'الحالة',
                  value: result.message ?? 'تعذر تحديد حالة المركبة',
                ),
              ],
              if (onIssueFine != null) ...[
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: onIssueFine,
                  icon: const Icon(Icons.gavel_rounded),
                  label: const Text('إصدار مخالفة'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  IconData _statusIcon(OfficerVehicleCheckResult result) {
    if (result.isActive) return Icons.check_circle_outline;
    if (result.isCurrentlyClamped) return Icons.lock_outline_rounded;
    if (result.isUnregistered) return Icons.no_crash_outlined;
    if (result.isRegistered) return Icons.directions_car_filled_outlined;
    return Icons.error_outline_rounded;
  }

  Color _statusColor(OfficerVehicleCheckResult result) {
    if (result.isActive) return const Color(0xFF0F766E);
    if (result.isCurrentlyClamped) return const Color(0xFFB45309);
    if (result.isUnregistered) return const Color(0xFFD63C31);
    if (result.isRegistered) return const Color(0xFF1F6F8B);
    return const Color(0xFFC8922E);
  }

  String _statusTitle(OfficerVehicleCheckResult result) {
    if (result.isActive) return 'الجلسة نشطة';
    if (result.isCurrentlyClamped) return 'مركبة مكلبشة حالياً';
    if (result.isUnregistered) return 'مركبة غير مسجلة';
    if (result.isRegistered) return 'مركبة مسجلة';
    return result.message ?? result.status ?? 'نتيجة الفحص';
  }

  String _statusDescription(OfficerVehicleCheckResult result) {
    if (result.isActive) {
      return 'يمكنك متابعة بيانات الجلسة الحالية والتأكد من وقت انتهائها.';
    }
    if (result.isCurrentlyClamped) {
      return 'تم تسجيل كلبشة على هذه المركبة، ويمكنك إزالة الكلبشة عند الحاجة.';
    }
    if (result.isUnregistered) {
      return 'هذه المركبة غير موجودة في قاعدة بيانات النظام الحالية.';
    }
    if (result.isRegistered) {
      return 'هذه المركبة موجودة في النظام، لكن لا توجد لها جلسة وقوف نشطة حالياً.';
    }
    return 'تعذر تحديد حالة المركبة بشكل واضح من الاستجابة الحالية.';
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'غير متوفر';
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'م' : 'ص';
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} - $hour:$minute $suffix';
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
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
      child: Row(
        children: [
          Expanded(
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
          ),
        ],
      ),
    );
  }
}

class _EntryModeChip extends StatelessWidget {
  const _EntryModeChip({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFFE7F2EF) : const Color(0xFFF8F7F3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0F766E)
                : const Color(0xFFE7E1D6),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF0F766E)
                  : const Color(0xFF5B6472),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? const Color(0xFF0F766E)
                    : const Color(0xFF5B6472),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
