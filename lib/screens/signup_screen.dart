import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _currentStep = 0;
  final List<_VehicleFormData> _vehicles = [_VehicleFormData()];

  static const _stepTitles = [
    'المعلومات الشخصية',
    'معلومات السيارة',
    'التحقق من الهوية',
  ];

  static const _stepSubtitles = [
    'أدخل بياناتك الأساسية. البريد الإلكتروني اختياري.',
    'أدخل رقم اللوحة وموديل السيارة.',
    'أدخل رقم الهوية وأضف صورة الهوية.',
  ];

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
                  'سجّل حسابك بخطوات واضحة وسهلة.',
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
                  onPressed: () {
                    if (_currentStep < 2) {
                      setState(() {
                        _currentStep += 1;
                      });
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'تم تجهيز خطوات التسجيل للربط مع الـ API لاحقاً.',
                        ),
                      ),
                    );
                  },
                  child: Text(_currentStep < 2 ? 'متابعة' : 'إنشاء الحساب'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
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
        return const _SectionShell(
          title: 'المعلومات الشخصية',
          child: Column(
            children: [
              _SignupField(
                label: 'الاسم الكامل',
                icon: Icons.person_outline_rounded,
              ),
              SizedBox(height: 14),
              _SignupField(
                label: 'رقم الهوية',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 14),
              _SignupField(
                label: 'رقم الجوال',
                icon: Icons.phone_iphone_rounded,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 14),
              _SignupField(
                label: 'البريد الإلكتروني - اختياري',
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 14),
              _SignupField(
                label: 'كلمة المرور',
                icon: Icons.lock_outline_rounded,
                obscureText: true,
              ),
              SizedBox(height: 14),
              _SignupField(
                label: 'تأكيد كلمة المرور',
                icon: Icons.lock_reset_rounded,
                obscureText: true,
              ),
            ],
          ),
        );
      case 1:
        return Column(
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
        );
      default:
        return const _SectionShell(
          title: 'التحقق من الهوية',
          child: Column(
            children: [
              _SignupField(
                label: 'رقم الهوية',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 14),
              _UploadHintCard(
                title: 'صورة الهوية',
                subtitle: 'أضف صورة واضحة للهوية لاستخدامها في التحقق من الحساب.',
                buttonLabel: 'اختيار صورة',
                icon: Icons.upload_file_rounded,
              ),
            ],
          ),
        );
    }
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
      _vehicles.removeAt(index);
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
    final circleColor = isActive || isDone
        ? const Color(0xFF0F766E)
        : const Color(0xFFE7E1D6);

    final textColor = isActive
        ? const Color(0xFF0F766E)
        : const Color(0xFF8A8F98);

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

class _VehicleFields extends StatefulWidget {
  const _VehicleFields({required this.data});

  final _VehicleFormData data;

  @override
  State<_VehicleFields> createState() => _VehicleFieldsState();
}

class _VehicleFieldsState extends State<_VehicleFields> {
  late final TextEditingController _plateController;
  late final TextEditingController _modelController;

  @override
  void initState() {
    super.initState();
    _plateController = TextEditingController(text: widget.data.plateNumber);
    _modelController = TextEditingController(text: widget.data.model);
  }

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _plateController,
          decoration: const InputDecoration(
            labelText: 'رقم اللوحة',
            prefixIcon: Icon(Icons.pin_outlined),
          ),
          onChanged: (value) => widget.data.plateNumber = value,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _modelController,
          decoration: const InputDecoration(
            labelText: 'موديل السيارة',
            prefixIcon: Icon(Icons.directions_car_filled_outlined),
          ),
          onChanged: (value) => widget.data.model = value,
        ),
      ],
    );
  }
}

class _UploadHintCard extends StatelessWidget {
  const _UploadHintCard({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8E1E7)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F2EF),
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
            onPressed: () {},
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

class _SignupField extends StatelessWidget {
  const _SignupField({
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
  });

  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}

class _VehicleFormData {
  _VehicleFormData({
    this.plateNumber = '',
    this.model = '',
  });

  String plateNumber;
  String model;
}
