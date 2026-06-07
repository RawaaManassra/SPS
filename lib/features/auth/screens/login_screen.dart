import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flut/features/admin/shell/admin_shell_screen.dart';
import 'package:flut/features/auth/services/auth_service.dart';
import 'package:flut/features/driver/shell/driver_shell_screen.dart';
import 'package:flut/features/officer/shell/officer_shell_screen.dart';

import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.successMessage,
  });

  final String? successMessage;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _didShowSuccessMessage = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.successMessage != null && !_didShowSuccessMessage) {
      _didShowSuccessMessage = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.successMessage!)),
        );
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE7F2EF),
              Color(0xFFF7F4ED),
              Color(0xFFF7F4ED),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      width: 94,
                      height: 94,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F766E),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x220F766E),
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'P',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Park Pal',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'إدارة مواقفك في مدينة الخليل بسهولة وشفافية.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'تسجيل الدخول',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'أدخل رقم الهوية وكلمة المرور للوصول إلى جلسات الوقوف والمخالفات والإشعارات.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _idController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            validator: _idValidator,
                            decoration: const InputDecoration(
                              labelText: 'رقم الهوية',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            validator: _passwordValidator,
                            decoration: const InputDecoration(
                              labelText: 'كلمة المرور',
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ForgotPasswordScreen(),
                                        ),
                                      );
                                    },
                              child: const Text('نسيت كلمة المرور؟'),
                            ),
                          ),
                          const SizedBox(height: 4),
                          ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitLogin,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('دخول'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7F1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD3EBDD)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          color: Color(0xFF2F855A),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'نظام رقمي موثوق لتسهيل الوقوف وتقليل المخالفات غير العادلة.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('ليس لديك حساب؟'),
                      TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignupScreen(),
                                  ),
                                );
                              },
                        child: const Text('إنشاء حساب'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitLogin() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _authService.login(
        nationalId: _idController.text.trim(),
        password: _passwordController.text,
      );

      final role = await _authService.getCurrentRole();
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      if (role == 'driver') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DriverShellScreen(),
          ),
        );
        return;
      }

      if (role == 'inspector') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const OfficerShellScreen(),
          ),
        );
        return;
      }

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminShellScreen(),
          ),
        );
        return;
      }

      await _authService.clearSession();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تسجيل الدخول، لكن هذا النوع من الحسابات لا يملك واجهة داخل تطبيق الموبايل حالياً.',
          ),
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
      setState(() {
        _isSubmitting = false;
      });
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'استغرق تسجيل الدخول وقتاً أطول من المتوقع. تأكد أن الـ backend شغال ثم حاول مرة أخرى.',
          ),
        ),
      );
      setState(() {
        _isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر الوصول إلى الخادم. تأكد أن الـ backend شغال ثم حاول مرة أخرى.',
          ),
        ),
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  String? _idValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (text.length < 6) {
      return 'أدخل رقم هوية صحيح';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (text.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف أو أكثر';
    }
    return null;
  }
}
