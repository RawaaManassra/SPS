import 'package:flutter/material.dart';

import 'package:flut/features/driver/vehicles/vehicle_catalog.dart';

class DriverVehicleFormScreen extends StatefulWidget {
  const DriverVehicleFormScreen({
    super.key,
    required this.title,
    required this.actionLabel,
    this.initialPlateNumber,
    this.initialVehicleType,
    this.initialColor,
  });

  final String title;
  final String actionLabel;
  final String? initialPlateNumber;
  final String? initialVehicleType;
  final String? initialColor;

  @override
  State<DriverVehicleFormScreen> createState() => _DriverVehicleFormScreenState();
}

class _DriverVehicleFormScreenState extends State<DriverVehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _plateController;
  late final TextEditingController _vehicleTypeController;
  late final TextEditingController _colorController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _plateController = TextEditingController(text: widget.initialPlateNumber ?? '');
    _vehicleTypeController = TextEditingController(
      text: widget.initialVehicleType ?? '',
    );
    _colorController = TextEditingController(text: widget.initialColor ?? '');
  }

  @override
  void dispose() {
    _plateController.dispose();
    _vehicleTypeController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(
      DriverVehicleFormResult(
        plateNumber: _plateController.text.trim(),
        vehicleType: _vehicleTypeController.text.trim(),
        color: _colorController.text.trim(),
      ),
    );
  }

  Future<void> _pickVehicleType() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return _SearchSelectionSheet(
          title: 'اختيار نوع السيارة',
          items: vehicleTypeOptions,
          initialValue: _vehicleTypeController.text.trim(),
        );
      },
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _vehicleTypeController.text = selected;
    });
  }

  Future<void> _pickColor() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return _SimpleSelectionSheet(
          title: 'اختيار لون السيارة',
          items: vehicleColorOptions,
          initialValue: _colorController.text.trim(),
        );
      },
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _colorController.text = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
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
                      'بيانات المركبة',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أدخلي رقم اللوحة، ثم اختاري نوع السيارة ولونها من القائمة.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5B6472),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _plateController,
                      textInputAction: TextInputAction.next,
                      validator: _requiredValidator,
                      decoration: const InputDecoration(
                        labelText: 'رقم اللوحة',
                        prefixIcon: Icon(Icons.pin_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _vehicleTypeController,
                      readOnly: true,
                      validator: _requiredValidator,
                      onTap: _pickVehicleType,
                      decoration: const InputDecoration(
                        labelText: 'نوع السيارة',
                        prefixIcon: Icon(Icons.directions_car_outlined),
                        suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _colorController,
                      readOnly: true,
                      validator: _requiredValidator,
                      onTap: _pickColor,
                      decoration: const InputDecoration(
                        labelText: 'لون السيارة',
                        prefixIcon: Icon(Icons.palette_outlined),
                        suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _submit,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.2),
                            )
                          : Text(widget.actionLabel),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DriverVehicleFormResult {
  const DriverVehicleFormResult({
    required this.plateNumber,
    required this.vehicleType,
    required this.color,
  });

  final String plateNumber;
  final String vehicleType;
  final String color;
}

class _SearchSelectionSheet extends StatefulWidget {
  const _SearchSelectionSheet({
    required this.title,
    required this.items,
    required this.initialValue,
  });

  final String title;
  final List<String> items;
  final String initialValue;

  @override
  State<_SearchSelectionSheet> createState() => _SearchSelectionSheetState();
}

class _SearchSelectionSheetState extends State<_SearchSelectionSheet> {
  late final TextEditingController _searchController;
  late List<String> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_applyFilter)
      ..dispose();
    super.dispose();
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFD8D2C7),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'ابحثي عن نوع السيارة',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 14),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _filteredItems.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final isSelected = item == widget.initialValue;
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    tileColor: Colors.white,
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: isSelected
                          ? const Color(0xFF0F766E)
                          : const Color(0xFFB8B2A7),
                    ),
                    title: Text(item),
                    onTap: () => Navigator.of(context).pop(item),
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
    required this.items,
    required this.initialValue,
  });

  final String title;
  final List<String> items;
  final String initialValue;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFD8D2C7),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 14),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item == initialValue;
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    tileColor: Colors.white,
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: isSelected
                          ? const Color(0xFF0F766E)
                          : const Color(0xFFB8B2A7),
                    ),
                    title: Text(item),
                    onTap: () => Navigator.of(context).pop(item),
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
