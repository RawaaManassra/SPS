import 'package:flutter/material.dart';

class OfficerShellScreen extends StatelessWidget {
  const OfficerShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('واجهة موظف التفتيش'),
      ),
      body: Center(
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
                    Icons.fact_check_outlined,
                    color: Color(0xFF0F766E),
                    size: 34,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'سيتم بناء هذه الواجهة لاحقاً',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'هنا سنضيف مسح اللوحات، إصدار المخالفات، وسجل نشاط الموظف.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5B6472),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
