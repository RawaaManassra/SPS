import 'package:flutter/material.dart';

import 'package:flut/features/driver/vehicles/driver_vehicle_form_screen.dart';
import 'package:flut/features/driver/vehicles/models/driver_vehicle.dart';
import 'package:flut/features/driver/vehicles/services/vehicle_service.dart';

class DriverVehiclesScreen extends StatefulWidget {
  const DriverVehiclesScreen({super.key});

  @override
  State<DriverVehiclesScreen> createState() => _DriverVehiclesScreenState();
}

class _DriverVehiclesScreenState extends State<DriverVehiclesScreen> {
  final _vehicleService = VehicleService();

  List<DriverVehicle> _vehicles = const [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final vehicles = await _vehicleService.getVehicles();
      if (!mounted) return;
      setState(() {
        _vehicles = vehicles;
      });
    } on VehicleException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'تعذر تحميل المركبات حالياً.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openAddVehicleForm() async {
    final result = await Navigator.of(context).push<DriverVehicleFormResult>(
      MaterialPageRoute(
        builder: (_) => const DriverVehicleFormScreen(
          title: 'إضافة مركبة جديدة',
          actionLabel: 'إضافة المركبة',
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _vehicleService.addVehicle(
        licensePlate: result.plateNumber,
        vehicleType: result.vehicleType,
        color: result.color,
      );

      await _loadVehicles();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة المركبة بنجاح.')),
      );
    } on VehicleException catch (error) {
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

  Future<void> _openEditVehicleForm(DriverVehicle vehicle) async {
    final result = await Navigator.of(context).push<DriverVehicleFormResult>(
      MaterialPageRoute(
        builder: (_) => DriverVehicleFormScreen(
          title: 'تعديل بيانات المركبة',
          actionLabel: 'حفظ التعديلات',
          initialPlateNumber: vehicle.plateNumber,
          initialVehicleType: vehicle.vehicleType,
          initialColor: vehicle.color,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _vehicleService.updateVehicle(
        vehicleId: vehicle.id,
        licensePlate: result.plateNumber,
        vehicleType: result.vehicleType,
        color: result.color,
      );

      await _loadVehicles();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث بيانات المركبة بنجاح.')),
      );
    } on VehicleException catch (error) {
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

  Future<void> _setDefaultVehicle(DriverVehicle vehicle) async {
    if (vehicle.isDefault) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _vehicleService.setDefaultVehicle(vehicle.id);
      await _loadVehicles();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تعيين المركبة الأساسية بنجاح.')),
      );
    } on VehicleException catch (error) {
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

  Future<void> _showVehicleActions(DriverVehicle vehicle) async {
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
                    _openEditVehicleForm(vehicle);
                  },
                ),
                _ActionTile(
                  icon: Icons.star_outline_rounded,
                  label: vehicle.isDefault ? 'هذه هي المركبة الأساسية' : 'تعيين كمركبة أساسية',
                  onTap: vehicle.isDefault
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          _setDefaultVehicle(vehicle);
                        },
                ),
                _ActionTile(
                  icon: Icons.delete_outline_rounded,
                  label: 'حذف المركبة',
                  isDestructive: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmDeleteVehicle(vehicle);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteVehicle(DriverVehicle vehicle) async {
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
      _isSubmitting = true;
    });

    try {
      await _vehicleService.deleteVehicle(vehicle.id);
      await _loadVehicles();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المركبة بنجاح.')),
      );
    } on VehicleException catch (error) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _loadVehicles,
      child: ListView(
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
                      'الآن يمكنك عرض المركبات وإضافتها وتعديلها وتعيين المركبة الأساسية مباشرة من الباك.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5B6472),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filled(
                onPressed: _isSubmitting ? null : _openAddVehicleForm,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_isLoading)
            const _VehiclesLoadingState()
          else if (_errorMessage != null)
            _VehiclesErrorState(
              message: _errorMessage!,
              onRetry: _loadVehicles,
            )
          else if (_vehicles.isEmpty)
            const _EmptyVehiclesState()
          else
            ...List.generate(_vehicles.length, (index) {
              final vehicle = _vehicles[index];

              return Padding(
                padding: EdgeInsets.only(bottom: index == _vehicles.length - 1 ? 0 : 12),
                child: VehicleListCard(
                  plateNumber: vehicle.plateNumber,
                  vehicleType: vehicle.vehicleType,
                  color: vehicle.color ?? 'غير محدد',
                  status: vehicle.isDefault ? 'المركبة الأساسية' : 'مركبة مسجلة',
                  onMorePressed: () => _showVehicleActions(vehicle),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class VehicleListCard extends StatelessWidget {
  const VehicleListCard({
    super.key,
    required this.plateNumber,
    required this.vehicleType,
    required this.color,
    required this.status,
    required this.onMorePressed,
  });

  final String plateNumber;
  final String vehicleType;
  final String color;
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
                  '$vehicleType • $color',
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

class _VehiclesLoadingState extends StatelessWidget {
  const _VehiclesLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _VehiclesErrorState extends StatelessWidget {
  const _VehiclesErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

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
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFD63C31),
            size: 34,
          ),
          const SizedBox(height: 12),
          Text(
            'تعذر تحميل المركبات',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5B6472),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () {
              onRetry();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
