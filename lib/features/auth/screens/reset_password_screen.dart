import 'package:flutter/material.dart';

import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  int _currentStep = 0;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'التحقق وإعادة التعيين',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'تحقق من الرمز المرسل على الجوال أولاً، ثم قم بتعيين كلمة مرور جديدة.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF55606E),
                  ),
                ),
                const SizedBox(height: 20),
                _ResetTabs(currentStep: _currentStep),
                const SizedBox(height: 18),
                if (_currentStep == 0)
                  const _ResetSection(
                    title: 'رمز التحقق',
                    subtitle: 'أدخل الرمز الذي وصلك برسالة نصية على رقم الجوال.',
                    icon: Icons.verified_user_outlined,
                    child: Column(
                      children: [
                        TextField(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            labelText: 'رمز التحقق',
                            prefixIcon: Icon(Icons.password_rounded),
                          ),
                        ),
                        SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: null,
                            child: Text('إعادة إرسال الرمز'),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const _ResetSection(
                    title: 'كلمة المرور الجديدة',
                    subtitle: 'أدخل كلمة مرور جديدة ثم قم بتأكيدها.',
                    icon: Icons.lock_reset_rounded,
                    child: Column(
                      children: [
                        TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور الجديدة',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                          ),
                        ),
                        SizedBox(height: 14),
                        TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'تأكيد كلمة المرور الجديدة',
                            prefixIcon: Icon(Icons.lock_reset_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () {
                    if (_currentStep == 0) {
                      setState(() {
                        _currentStep = 1;
                      });
                      return;
                    }

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تغيير كلمة المرور بنجاح. يمكنك تسجيل الدخول الآن.'),
                      ),
                    );
                  },
                  child: Text(_currentStep == 0 ? 'تحقق من الرمز' : 'حفظ وتسجيل الدخول'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    if (_currentStep == 1) {
                      setState(() {
                        _currentStep = 0;
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
                  child: Text(_currentStep == 0 ? 'رجوع' : 'العودة لخطوة الرمز'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetTabs extends StatelessWidget {
  const _ResetTabs({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ResetTab(
            title: 'التحقق',
            isActive: currentStep == 0,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ResetTab(
            title: 'كلمة مرور جديدة',
            isActive: currentStep == 1,
          ),
        ),
      ],
    );
  }
}

class _ResetTab extends StatelessWidget {
  const _ResetTab({
    required this.title,
    required this.isActive,
  });

  final String title;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0F766E) : const Color(0xFFF0ECE2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isActive ? Colors.white : const Color(0xFF8A8F98),
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
            ),
      ),
    );
  }
}

class _ResetSection extends StatelessWidget {
  const _ResetSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.84),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
