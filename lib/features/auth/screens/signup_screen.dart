import 'package:flutter/material.dart';

import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _currentStep = 0;
  bool _identityImageSelected = false;
  bool _isSubmitting = false;

  final _personalFormKey = GlobalKey<FormState>();
  final _vehiclesFormKey = GlobalKey<FormState>();
  final _identityFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _identityIdController = TextEditingController();

  final List<_VehicleFormData> _vehicles = [_VehicleFormData()];

  static const _stepTitles = [
    'المعلومات الشخصية',
    'معلومات السيارة',
    'التحقق من الهوية',
  ];

  static const _stepSubtitles = [
    'أدخل بياناتك الأساسية لإنشاء الحساب.',
    'أدخل رقم اللوحة وموديل السيارة.',
    'أدخل رقم الهوية وأضف صورة الهوية.',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _identityIdController.dispose();
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
                  controller: _idController,
                  label: 'رقم الهوية',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  validator: _identityValidator,
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
                  title: 'السيارة ${index + 1}',
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
          title: 'التحقق من الهوية',
          child: Form(
            key: _identityFormKey,
            child: Column(
              children: [
                _SignupField(
                  controller: _identityIdController,
                  label: 'رقم الهوية',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  validator: _identityValidator,
                ),
                const SizedBox(height: 14),
                _UploadHintCard(
                  title: 'صورة الهوية *',
                  subtitle: _identityImageSelected
                      ? 'تم اختيار صورة الهوية.'
                      : 'أضف صورة واضحة للهوية لاستخدامها في التحقق من الحساب.',
                  buttonLabel:
                      _identityImageSelected ? 'تغيير الصورة' : 'اختيار صورة',
                  icon: Icons.upload_file_rounded,
                  selected: _identityImageSelected,
                  onPressed: () {
                    setState(() {
                      _identityImageSelected = true;
                    });
                  },
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

    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(
          successMessage: 'تم إنشاء الحساب بنجاح. يمكنك تسجيل الدخول الآن.',
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

    final isFormValid = _identityFormKey.currentState?.validate() ?? false;
    if (!_identityImageSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار صورة الهوية.')),
      );
      return false;
    }

    return isFormValid;
  }

  String? _optionalEmailValidator(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return null;
    }

    if (!email.contains('@') || !email.contains('.')) {
      return 'أدخل بريد إلكتروني صحيح أو اترك الحقل فارغاً';
    }

    return null;
  }

  String? _identityValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'هذا الحقل مطلوب';
    }

    if (text.length < 6) {
      return 'أدخل رقم هوية صحيح';
    }

    return null;
  }

  String? _phoneValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'هذا الحقل مطلوب';
    }

    if (text.length < 9) {
      return 'أدخل رقم جوال صحيح';
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
        _SignupField(
          controller: data.modelController,
          label: 'موديل السيارة',
          icon: Icons.directions_car_filled_outlined,
          validator: _modelValidator,
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
      return 'أدخل رقم لوحة صحيح';
    }

    return null;
  }

  String? _modelValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'هذا الحقل مطلوب';
    }

    return null;
  }
}

class _UploadHintCard extends StatelessWidget {
  const _UploadHintCard({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.icon,
    required this.onPressed,
    this.selected = false,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData icon;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE7F2EF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? const Color(0xFF0F766E) : const Color(0xFFD8E1E7),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF0F766E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5B6472),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: onPressed,
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
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
  _VehicleFormData();

  final plateController = TextEditingController();
  final modelController = TextEditingController();

  void dispose() {
    plateController.dispose();
    modelController.dispose();
  }
}
