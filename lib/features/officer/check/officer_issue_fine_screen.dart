import 'package:flutter/material.dart';

import 'package:flut/features/officer/check/models/officer_vehicle_check_result.dart';
import 'package:flut/features/officer/check/models/officer_violation_type.dart';
import 'package:flut/features/officer/check/services/officer_inspector_service.dart';

class OfficerIssueFineScreen extends StatefulWidget {
  const OfficerIssueFineScreen({
    super.key,
    required this.result,
  });

  final OfficerVehicleCheckResult result;

  @override
  State<OfficerIssueFineScreen> createState() => _OfficerIssueFineScreenState();
}

class _OfficerIssueFineScreenState extends State<OfficerIssueFineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = OfficerInspectorService();
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  bool _isLoadingTypes = true;
  bool _isSubmitting = false;
  List<OfficerViolationType> _violationTypes = const [];
  OfficerViolationType? _selectedType;

  @override
  void initState() {
    super.initState();
    _latitudeController = TextEditingController(
      text: (widget.result.latitude ?? 31.5326).toString(),
    );
    _longitudeController = TextEditingController(
      text: (widget.result.longitude ?? 35.0998).toString(),
    );
    _loadViolationTypes();
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إصدار مخالفة'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7F3),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.result.licensePlate,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.result.vehicleType ?? 'نوع غير محدد'} • ${widget.result.color ?? 'لون غير محدد'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5B6472),
                  ),
                ),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'نوع المخالفة',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_isLoadingTypes)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_violationTypes.isEmpty)
                    Text(
                      'لا توجد أنواع مخالفات متاحة حالياً.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5B6472),
                      ),
                    )
                  else
                    ..._violationTypes.map(
                      (type) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ViolationTypeTile(
                          violationType: type,
                          isSelected: _selectedType?.id == type.id,
                          onTap: () {
                            setState(() {
                              _selectedType = type;
                            });
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    'موقع تسجيل المخالفة',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _latitudeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: _requiredCoordinateValidator,
                    decoration: const InputDecoration(
                      labelText: 'خط العرض (Latitude)',
                      prefixIcon: Icon(Icons.my_location_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _longitudeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: _requiredCoordinateValidator,
                    decoration: const InputDecoration(
                      labelText: 'خط الطول (Longitude)',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitFine,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.gavel_rounded),
                    label: Text(_isSubmitting ? 'جارٍ إصدار المخالفة...' : 'إصدار المخالفة'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadViolationTypes() async {
    try {
      final types = await _service.getViolationTypes();
      if (!mounted) return;
      setState(() {
        _violationTypes = types;
        _selectedType = types.isEmpty ? null : types.first;
      });
    } on OfficerInspectorException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingTypes = false;
      });
    }
  }

  Future<void> _submitFine() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر نوع المخالفة أولاً.')),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final vehicleId = widget.result.vehicleId;
    if (vehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تحديد المركبة المطلوبة لإصدار المخالفة.')),
      );
      return;
    }

    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل إحداثيات صحيحة للموقع.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _service.issueFine(
        vehicleId: vehicleId,
        violationTypeId: _selectedType!.id,
        latitude: latitude,
        longitude: longitude,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إصدار المخالفة بنجاح.')),
      );
      Navigator.of(context).pop(true);
    } on OfficerInspectorException catch (error) {
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

  String? _requiredCoordinateValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (double.tryParse(text) == null) {
      return 'أدخل قيمة رقمية صحيحة';
    }
    return null;
  }
}

class _ViolationTypeTile extends StatelessWidget {
  const _ViolationTypeTile({
    required this.violationType,
    required this.isSelected,
    required this.onTap,
  });

  final OfficerViolationType violationType;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE7F2EF) : const Color(0xFFF8F7F3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F766E) : const Color(0xFFE7E1D6),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    violationType.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${violationType.amount.toStringAsFixed(0)} شيكل',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5B6472),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF9AA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
