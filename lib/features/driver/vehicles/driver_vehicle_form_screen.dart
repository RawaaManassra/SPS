import 'package:flutter/material.dart';

class DriverVehicleFormScreen extends StatefulWidget {
  const DriverVehicleFormScreen({
    super.key,
    required this.title,
    required this.actionLabel,
    this.initialPlateNumber,
    this.initialModel,
  });

  final String title;
  final String actionLabel;
  final String? initialPlateNumber;
  final String? initialModel;

  @override
  State<DriverVehicleFormScreen> createState() => _DriverVehicleFormScreenState();
}

class _DriverVehicleFormScreenState extends State<DriverVehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _plateController;
  late final TextEditingController _modelController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _plateController = TextEditingController(text: widget.initialPlateNumber ?? '');
    _modelController = TextEditingController(text: widget.initialModel ?? '');
  }

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
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

    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(
      DriverVehicleFormResult(
        plateNumber: _plateController.text.trim(),
        model: _modelController.text.trim(),
      ),
    );
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
                      'أدخل رقم اللوحة وموديل المركبة فقط.',
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
                      controller: _modelController,
                      textInputAction: TextInputAction.done,
                      validator: _requiredValidator,
                      decoration: const InputDecoration(
                        labelText: 'موديل المركبة',
                        prefixIcon: Icon(Icons.directions_car_outlined),
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
    required this.model,
  });

  final String plateNumber;
  final String model;
}
