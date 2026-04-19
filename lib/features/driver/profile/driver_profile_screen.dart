import 'package:flutter/material.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F2EF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFF0F766E),
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'حسابي',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'هنا ستظهر بيانات المستخدم والإعدادات وتحديث الحساب.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5B6472),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
