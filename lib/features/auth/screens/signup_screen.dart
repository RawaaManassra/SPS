import 'package:flutter/material.dart';

import 'package:flut/features/auth/models/register_request.dart';
import 'package:flut/features/auth/services/auth_service.dart';
import 'package:flut/features/driver/vehicles/vehicle_catalog.dart';
import 'package:flut/features/driver/vehicles/services/vehicle_service.dart';

import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _authService = AuthService();
  final _vehicleService = VehicleService();

  final _personalFormKey = GlobalKey<FormState>();
  final _vehiclesFormKey = GlobalKey<FormState>();
  final _identityFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _drivingLicenceController = TextEditingController();

  final List<_VehicleFormData> _vehicles = [_VehicleFormData()];

  int _currentStep = 0;
  bool _isSubmitting = false;

  static const _stepTitles = [
    'المعلومات الشخصية',
    'معلومات السيارة',
    'الهوية ورخصة القيادة',
  ];

  static const _stepSubtitles = [
    'أدخلي بياناتك الأساسية لإنشاء الحساب.',
    'أدخلي بيانات المركبة كما يطلبها النظام.',
    'أدخلي رقم الهوية الشخصية ورقم رخصة القيادة لإكمال التسجيل.',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nationalIdController.dispose();
    _drivingLicenceController.dispose();
    for (final vehicle in _vehicles) {
      vehicle.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F3EF),
              Color(0xFFF7F4ED),
              Color(0xFFF5EFE2),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'إنشاء حساب',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'الحقول التي تحتوي على * مطلوبة لإكمال التسجيل.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF55606E),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'الخطوة ${_currentStep + 1} من 3',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF0F766E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _StepProgress(
                  currentStep: _currentStep,
                  labels: const ['البيانات', 'السيارة', 'الهوية'],
                ),
                const SizedBox(height: 14),
                Text(
                  _stepTitles[_currentStep],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _stepSubtitles[_currentStep],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5B6472),
                  ),
                ),
                const SizedBox(height: 14),
                _buildCurrentStep(),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handlePrimaryAction,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_currentStep < 2 ? 'متابعة' : 'إنشاء الحساب'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          if (_currentStep > 0) {
                            setState(() {
                              _currentStep -= 1;
                            });
                            return;
                          }

                          Navigator.pop(context);
                        },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    side: const BorderSide(color: Color(0xFF0F766E)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(_currentStep == 0 ? 'لدي حساب بالفعل' : 'رجوع'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _SectionShell(
          title: 'المعلومات الشخصية',
          child: Form(
            key: _personalFormKey,
            child: Column(
              children: [
                _SignupField(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                  icon: Icons.person_outline_rounded,
                  required: true,
                ),
                const SizedBox(height: 14),
                _SignupField(
                  controller: _phoneController,
                  label: 'رقم الجوال',
                  icon: Icons.phone_iphone_rounded,
                  keyboardType: TextInputType.phone,
                  validator: _phoneValidator,
                ),
                const SizedBox(height: 14),
                _SignupField(
                  controller: _emailController,
                  label: 'البريد الإلكتروني',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: _optionalEmailValidator,
                ),
                const SizedBox(height: 14),
                _SignupField(
                  controller: _passwordController,
                  label: 'كلمة المرور',
                  icon: Icons.lock_outline_rounded,
                  obscureText: true,
                  validator: _passwordValidator,
                ),
                const SizedBox(height: 14),
                _SignupField(
                  controller: _confirmPasswordController,
                  label: 'تأكيد كلمة المرور',
                  icon: Icons.lock_reset_rounded,
                  obscureText: true,
                  validator: _confirmPasswordValidator,
                ),
              ],
            ),
          ),
        );
      case 1:
        return Form(
          key: _vehiclesFormKey,
          child: Column(
            children: [
              for (var index = 0; index < _vehicles.length; index++) ...[
                _SectionShell(
                  title: 'المركبة ${index + 1}',
                  trailing: _vehicles.length > 1
                      ? IconButton(
                          onPressed: () => _removeVehicle(index),
                          icon: const Icon(Icons.delete_outline_rounded),
                          color: const Color(0xFFB45309),
                        )
                      : null,
                  child: _VehicleFields(data: _vehicles[index]),
                ),
                const SizedBox(height: 14),
              ],
              OutlinedButton.icon(
                onPressed: _addVehicle,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  side: const BorderSide(color: Color(0xFF0F766E)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text('إضافة سيارة أخرى'),
              ),
            ],
          ),
        );
      default:
        return _SectionShell(
          title: 'الهوية ورخصة القيادة',
          child: Form(
            key: _identityFormKey,
            child: Column(
              children: [
                _SignupField(
                  controller: _nationalIdController,
                  label: 'رقم الهوية الشخصية',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  validator: _identityValidator,
                ),
                const SizedBox(height: 14),
                _SignupField(
                  controller: _drivingLicenceController,
                  label: 'رقم رخصة القيادة',
                  icon: Icons.credit_card_outlined,
                  keyboardType: TextInputType.number,
                  validator: _identityValidator,
                ),
                const SizedBox(height: 10),
                Text(
                  'هذه الخطوة تطابق متطلبات الباك الحالية. لا يوجد حالياً رفع فعلي لصورة الهوية.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF5B6472),
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        );
    }
  }

  Future<void> _handlePrimaryAction() async {
    FocusScope.of(context).unfocus();

    if (!_validateCurrentStep()) {
      return;
    }

    if (_currentStep < 2) {
      setState(() {
        _currentStep += 1;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final nationalId = _nationalIdController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await _authService.register(
        RegisterRequest(
          username: nationalId,
          fullName: _nameController.text.trim(),
          nationalId: nationalId,
          drivingLicenceId: _drivingLicenceController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          password: password,
          confirmPassword: _confirmPasswordController.text.trim(),
        ),
      );

      await _authService.login(
        nationalId: nationalId,
        password: password,
      );

      for (var index = 0; index < _vehicles.length; index++) {
        final vehicle = _vehicles[index];
        await _vehicleService.addVehicle(
          licensePlate: vehicle.plateController.text.trim(),
          vehicleType: vehicle.typeController.text.trim(),
          color: vehicle.colorController.text.trim(),
          isDefault: index == 0,
        );
      }

      await _authService.clearSession();
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    } on VehicleException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر إكمال التسجيل حالياً. تأكدي أن الـ backend شغال ثم حاولي مرة أخرى.',
          ),
        ),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(
          successMessage: 'تم إنشاء الحساب والمركبات بنجاح. يمكنك تسجيل الدخول الآن.',
        ),
      ),
      (route) => false,
    );
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      return _personalFormKey.currentState?.validate() ?? false;
    }

    if (_currentStep == 1) {
      return _vehiclesFormKey.currentState?.validate() ?? false;
    }

    return _identityFormKey.currentState?.validate() ?? false;
  }

  String? _optionalEmailValidator(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return null;
    }

    if (!email.contains('@') || !email.contains('.')) {
      return 'أدخلي بريداً إلكترونياً صحيحاً أو اتركي الحقل فارغاً';
    }

    return null;
  }

  String? _identityValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'هذا الحقل مطلوب';
    }

    if (text.length < 6) {
      return 'أدخلي رقماً صحيحاً';
    }

    return null;
  }

  String? _phoneValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'هذا الحقل مطلوب';
    }

    if (text.length < 9) {
      return 'أدخلي رقم جوال صحيح';
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'هذا الحقل مطلوب';
    }

    if (text.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف أو أكثر';
    }

    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'هذا الحقل مطلوب';
    }

    if (text != _passwordController.text.trim()) {
      return 'كلمة المرور غير متطابقة';
    }

    return null;
  }

  void _addVehicle() {
    setState(() {
      _vehicles.add(_VehicleFormData());
    });
  }

  void _removeVehicle(int index) {
    if (_vehicles.length == 1) {
      return;
    }

    setState(() {
      final removed = _vehicles.removeAt(index);
      removed.dispose();
    });
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({
    required this.currentStep,
    required this.labels,
  });

  final int currentStep;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length * 2 - 1, (index) {
        if (index.isOdd) {
          final lineIndex = index ~/ 2;
          final isDone = currentStep > lineIndex;
          return Expanded(
            child: Container(
              height: 1.5,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: isDone
                  ? const Color(0xFF0F766E)
                  : const Color(0xFFD8D2C7),
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final isActive = currentStep == stepIndex;
        final isDone = currentStep > stepIndex;

        return _ProgressNode(
          number: stepIndex + 1,
          label: labels[stepIndex],
          isActive: isActive,
          isDone: isDone,
        );
      }),
    );
  }
}

class _ProgressNode extends StatelessWidget {
  const _ProgressNode({
    required this.number,
    required this.label,
    required this.isActive,
    required this.isDone,
  });

  final int number;
  final String label;
  final bool isActive;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final circleColor =
        isActive || isDone ? const Color(0xFF0F766E) : const Color(0xFFE7E1D6);

    final textColor =
        isActive ? const Color(0xFF0F766E) : const Color(0xFF8A8F98);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Colors.white,
                )
              : Text(
                  '$number',
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 52,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: textColor,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _VehicleFields extends StatelessWidget {
  const _VehicleFields({required this.data});

  final _VehicleFormData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SignupField(
          controller: data.plateController,
          label: 'رقم اللوحة',
          icon: Icons.pin_outlined,
          validator: _plateValidator,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: data.typeController,
          readOnly: true,
          validator: _requiredValidator,
          onTap: () => _showVehicleTypePicker(context, data),
          decoration: const InputDecoration(
            labelText: 'نوع السيارة',
            prefixIcon: Icon(Icons.directions_car_filled_outlined),
            suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: data.colorController,
          readOnly: true,
          validator: _requiredValidator,
          onTap: () => _showVehicleColorPicker(context, data),
          decoration: const InputDecoration(
            labelText: 'لون السيارة',
            prefixIcon: Icon(Icons.palette_outlined),
            suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ),
      ],
    );
  }

  String? _plateValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'هذا الحقل مطلوب';
    }

    if (text.length < 4) {
      return 'أدخلي رقم لوحة صحيح';
    }

    return null;
  }

  String? _requiredValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'هذا الحقل مطلوب';
    }

    return null;
  }

  Future<void> _showVehicleTypePicker(
    BuildContext context,
    _VehicleFormData data,
  ) async {
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
          initialValue: data.typeController.text.trim(),
        );
      },
    );

    if (selected != null) {
      data.typeController.text = selected;
    }
  }

  Future<void> _showVehicleColorPicker(
    BuildContext context,
    _VehicleFormData data,
  ) async {
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
          initialValue: data.colorController.text.trim(),
        );
      },
    );

    if (selected != null) {
      data.colorController.text = selected;
    }
  }
}

class _SignupField extends StatelessWidget {
  const _SignupField({
    required this.controller,
    required this.label,
    required this.icon,
    this.required = false,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool required;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final displayLabel = required ? '$label *' : label;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator ?? (required ? _requiredValidator : null),
      decoration: InputDecoration(
        labelText: displayLabel,
        prefixIcon: Icon(icon),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }

    return null;
  }
}

class _VehicleFormData {
  final plateController = TextEditingController();
  final typeController = TextEditingController();
  final colorController = TextEditingController();

  void dispose() {
    plateController.dispose();
    typeController.dispose();
    colorController.dispose();
  }
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
