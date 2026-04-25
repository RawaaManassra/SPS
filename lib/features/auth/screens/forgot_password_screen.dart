import 'package:flutter/material.dart';

import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
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
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'استعادة كلمة المرور',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أدخل رقم الجوال المرتبط بالحساب وسنرسل لك رسالة تحتوي على رمز التحقق لإعادة تعيين كلمة المرور.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF55606E),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.84),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _FlowHeader(
                          title: 'إرسال الرمز',
                          subtitle: 'سيتم إرسال رمز مكون من 6 أرقام برسالة نصية إلى رقم الجوال.',
                          icon: Icons.sms_outlined,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          validator: _phoneValidator,
                          decoration: const InputDecoration(
                            labelText: 'رقم الجوال',
                            prefixIcon: Icon(Icons.phone_iphone_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitPhone,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('إرسال الرمز'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitPhone() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ResetPasswordScreen(),
      ),
    );
  }

  String? _phoneValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'هذا الحقل مطلوب';
    }

    if (text.length < 9) {
      return 'أدخل رقم جوال صحيح';
    }

    return null;
  }
}

class _FlowHeader extends StatelessWidget {
  const _FlowHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5B6472),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F2EF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF0F766E),
          ),
        ),
      ],
    );
  }
}
