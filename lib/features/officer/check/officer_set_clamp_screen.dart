import 'package:flutter/material.dart';

import 'package:flut/features/driver/vehicles/vehicle_catalog.dart';
import 'package:flut/features/officer/check/models/officer_vehicle_check_result.dart';
import 'package:flut/features/officer/check/services/officer_inspector_service.dart';

class OfficerSetClampScreen extends StatefulWidget {
  const OfficerSetClampScreen({
    super.key,
    required this.result,
  });

  final OfficerVehicleCheckResult result;

  @override
  State<OfficerSetClampScreen> createState() => _OfficerSetClampScreenState();
}

class _OfficerSetClampScreenState extends State<OfficerSetClampScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = OfficerInspectorService();
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  bool _isSubmitting = false;
  String? _selectedVehicleType;
  String? _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedVehicleType = widget.result.vehicleType;
    _selectedColor = widget.result.color;
    _latitudeController = TextEditingController(
      text: (widget.result.latitude ?? 31.5326).toString(),
    );
    _longitudeController = TextEditingController(
      text: (widget.result.longitude ?? 35.0998).toString(),
    );
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
        title: const Text('كلبشة السيارة'),
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
                  'مركبة غير مسجلة',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFD63C31),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'سيتم تسجيل الكلبشة لأن المركبة غير موجودة في النظام.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5B6472),
                    height: 1.5,
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
                    'بيانات الكلبشة',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    initialValue: widget.result.licensePlate,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'رقم اللوحة',
                      prefixIcon: Icon(Icons.pin_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SelectionField(
                    label: 'نوع المركبة',
                    value: _selectedVehicleType,
                    icon: Icons.directions_car_outlined,
                    onTap: _pickVehicleType,
                  ),
                  const SizedBox(height: 12),
                  _SelectionField(
                    label: 'اللون',
                    value: _selectedColor,
                    icon: Icons.palette_outlined,
                    onTap: _pickColor,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'موقع الكلبشة',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _latitudeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: _requiredCoordinateValidator,
                    decoration: const InputDecoration(
                      labelText: 'خط العرض (Latitude)',
                      prefixIcon: Icon(Icons.my_location_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _longitudeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: _requiredCoordinateValidator,
                    decoration: const InputDecoration(
                      labelText: 'خط الطول (Longitude)',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitClamp,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.lock_outline_rounded),
                    label: Text(
                      _isSubmitting
                          ? 'جارٍ تسجيل الكلبشة...'
                          : 'تأكيد كلبشة السيارة',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickVehicleType() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchableSelectionSheet(
        title: 'اختيار نوع المركبة',
        options: vehicleTypeOptions,
        initialValue: _selectedVehicleType,
      ),
    );

    if (!mounted || selected == null) return;
    setState(() {
      _selectedVehicleType = selected;
    });
  }

  Future<void> _pickColor() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SimpleSelectionSheet(
        title: 'اختيار اللون',
        options: vehicleColorOptions,
        initialValue: _selectedColor,
      ),
    );

    if (!mounted || selected == null) return;
    setState(() {
      _selectedColor = selected;
    });
  }

  Future<void> _submitClamp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedVehicleType == null || _selectedVehicleType!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختاري نوع المركبة أولاً.')),
      );
      return;
    }

    if (_selectedColor == null || _selectedColor!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختاري لون المركبة أولاً.')),
      );
      return;
    }

    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخلي إحداثيات صحيحة للموقع.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _service.setClamp(
        licensePlate: widget.result.licensePlate,
        reason: 'Vehicle not registered in the system',
        vehicleType: _selectedVehicleType!,
        color: _selectedColor!,
        latitude: latitude,
        longitude: longitude,
        photoUrl: null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل كلبشة السيارة بنجاح.')),
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
      return 'أدخلي قيمة رقمية صحيحة';
    }
    return null;
  }
}

class _SelectionField extends StatelessWidget {
  const _SelectionField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String? value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE0E5EA)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF5B6472)),
            const SizedBox(width: 12),
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
                    value ?? 'اضغطي للاختيار',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: value == null
                          ? const Color(0xFF8D96A5)
                          : const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }
}

class _SearchableSelectionSheet extends StatefulWidget {
  const _SearchableSelectionSheet({
    required this.title,
    required this.options,
    required this.initialValue,
  });

  final String title;
  final List<String> options;
  final String? initialValue;

  @override
  State<_SearchableSelectionSheet> createState() =>
      _SearchableSelectionSheetState();
}

class _SearchableSelectionSheetState extends State<_SearchableSelectionSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = widget.options
        .where((option) => option.toLowerCase().contains(query))
        .toList();

    return SafeArea(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 560),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 54,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD6DADF),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Column(
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'ابحثي عن نوع المركبة',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final option = filtered[index];
                  final isSelected = option == widget.initialValue;
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    tileColor: isSelected
                        ? const Color(0xFFE7F2EF)
                        : const Color(0xFFF8F7F3),
                    title: Text(
                      option,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF0F766E),
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(option),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleSelectionSheet extends StatelessWidget {
  const _SimpleSelectionSheet({
    required this.title,
    required this.options,
    required this.initialValue,
  });

  final String title;
  final List<String> options;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 520),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 54,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD6DADF),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option == initialValue;
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    tileColor: isSelected
                        ? const Color(0xFFE7F2EF)
                        : const Color(0xFFF8F7F3),
                    title: Text(
                      option,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF0F766E),
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(option),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
