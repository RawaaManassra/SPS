import 'package:flutter/material.dart';

class DriverVehiclesScreen extends StatefulWidget {
  const DriverVehiclesScreen({super.key});

  @override
  State<DriverVehiclesScreen> createState() => _DriverVehiclesScreenState();
}

class _DriverVehiclesScreenState extends State<DriverVehiclesScreen> {
  final List<_VehicleItem> _vehicles = [
    const _VehicleItem(
      plateNumber: '24-381-15',
      model: 'Hyundai i20',
      isPrimary: true,
    ),
    const _VehicleItem(
      plateNumber: '31-662-08',
      model: 'Kia Picanto',
    ),
  ];

  Future<void> _openVehicleForm({_VehicleItem? vehicle, int? index}) async {
    final result = await Navigator.of(context).push<_VehicleFormResult>(
      MaterialPageRoute(
        builder: (_) => DriverVehicleFormScreen(
          initialPlateNumber: vehicle?.plateNumber,
          initialModel: vehicle?.model,
          title: vehicle == null ? 'إضافة مركبة جديدة' : 'تعديل بيانات المركبة',
          actionLabel: vehicle == null ? 'إضافة المركبة' : 'حفظ التعديلات',
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      if (index == null) {
        _vehicles.add(
          _VehicleItem(
            plateNumber: result.plateNumber,
            model: result.model,
            isPrimary: _vehicles.isEmpty,
          ),
        );
      } else {
        final current = _vehicles[index];
        _vehicles[index] = _VehicleItem(
          plateNumber: result.plateNumber,
          model: result.model,
          isPrimary: current.isPrimary,
        );
      }
    });
  }

  Future<void> _showVehicleActions(int index) async {
    final vehicle = _vehicles[index];

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  vehicle.plateNumber,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 18),
                _ActionTile(
                  icon: Icons.edit_outlined,
                  label: 'تعديل بيانات المركبة',
                  onTap: () {
                    Navigator.of(context).pop();
                    _openVehicleForm(vehicle: vehicle, index: index);
                  },
                ),
                _ActionTile(
                  icon: Icons.star_outline_rounded,
                  label: 'تعيين كمركبة أساسية',
                  onTap: vehicle.isPrimary
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          _setPrimaryVehicle(index);
                        },
                ),
                _ActionTile(
                  icon: Icons.delete_outline_rounded,
                  label: 'حذف المركبة',
                  isDestructive: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmDeleteVehicle(index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _setPrimaryVehicle(int selectedIndex) {
    setState(() {
      for (var i = 0; i < _vehicles.length; i++) {
        _vehicles[i] = _VehicleItem(
          plateNumber: _vehicles[i].plateNumber,
          model: _vehicles[i].model,
          isPrimary: i == selectedIndex,
        );
      }
    });
  }

  Future<void> _confirmDeleteVehicle(int index) async {
    final vehicle = _vehicles[index];
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف المركبة'),
          content: Text('هل تريد حذف المركبة ${vehicle.plateNumber}؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'حذف',
                style: TextStyle(color: Color(0xFFD63C31)),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    setState(() {
      final wasPrimary = _vehicles[index].isPrimary;
      _vehicles.removeAt(index);

      if (wasPrimary && _vehicles.isNotEmpty) {
        _vehicles[0] = _VehicleItem(
          plateNumber: _vehicles[0].plateNumber,
          model: _vehicles[0].model,
          isPrimary: true,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مركباتي',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أدر المركبات المرتبطة بحسابك وأضف مركبة جديدة عند الحاجة.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5B6472),
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filled(
              onPressed: _openVehicleForm,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (_vehicles.isEmpty)
          const _EmptyVehiclesState()
        else
          ...List.generate(_vehicles.length, (index) {
            final vehicle = _vehicles[index];

            return Padding(
              padding: EdgeInsets.only(bottom: index == _vehicles.length - 1 ? 0 : 12),
              child: VehicleListCard(
                plateNumber: vehicle.plateNumber,
                model: vehicle.model,
                status: vehicle.isPrimary ? 'المركبة الأساسية' : 'مركبة مضافة',
                onMorePressed: () => _showVehicleActions(index),
              ),
            );
          }),
      ],
    );
  }
}

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
      _VehicleFormResult(
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

class VehicleListCard extends StatelessWidget {
  const VehicleListCard({
    super.key,
    required this.plateNumber,
    required this.model,
    required this.status,
    required this.onMorePressed,
  });

  final String plateNumber;
  final String model;
  final String status;
  final VoidCallback onMorePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F2EF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.directions_car_outlined,
              color: Color(0xFF0F766E),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plateNumber,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  model,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5B6472),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF0F766E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onMorePressed,
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFD63C31) : const Color(0xFF1F2937);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          color: onTap == null ? const Color(0xFF9AA3AF) : color,
          fontWeight: FontWeight.w700,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _EmptyVehiclesState extends StatelessWidget {
  const _EmptyVehiclesState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F2EF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.directions_car_outlined,
              color: Color(0xFF0F766E),
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'لا توجد مركبات حالياً',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإضافة مركبتك الأولى لتظهر هنا.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5B6472),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleItem {
  const _VehicleItem({
    required this.plateNumber,
    required this.model,
    this.isPrimary = false,
  });

  final String plateNumber;
  final String model;
  final bool isPrimary;
}

class _VehicleFormResult {
  const _VehicleFormResult({
    required this.plateNumber,
    required this.model,
  });

  final String plateNumber;
  final String model;
}
