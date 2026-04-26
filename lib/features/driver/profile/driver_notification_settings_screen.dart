import 'package:flutter/material.dart';

class DriverNotificationSettingsScreen extends StatefulWidget {
  const DriverNotificationSettingsScreen({super.key});

  @override
  State<DriverNotificationSettingsScreen> createState() =>
      _DriverNotificationSettingsScreenState();
}

class _DriverNotificationSettingsScreenState
    extends State<DriverNotificationSettingsScreen> {
  bool _sessionReminder = true;
  bool _violationAlerts = true;
  bool _paymentUpdates = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الإشعارات'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'تحكم بالتنبيهات التي تريد استقبالها داخل التطبيق.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5B6472),
                  ),
                ),
                const SizedBox(height: 18),
                SwitchListTile(
                  value: _sessionReminder,
                  onChanged: (value) {
                    setState(() {
                      _sessionReminder = value;
                    });
                  },
                  title: const Text('تذكير قرب انتهاء الجلسة'),
                  subtitle: const Text('إشعار قبل انتهاء الجلسة بـ 15 دقيقة.'),
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(height: 20),
                SwitchListTile(
                  value: _violationAlerts,
                  onChanged: (value) {
                    setState(() {
                      _violationAlerts = value;
                    });
                  },
                  title: const Text('تنبيهات المخالفات'),
                  subtitle: const Text('إشعار عند تسجيل مخالفة جديدة على المركبة.'),
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(height: 20),
                SwitchListTile(
                  value: _paymentUpdates,
                  onChanged: (value) {
                    setState(() {
                      _paymentUpdates = value;
                    });
                  },
                  title: const Text('تحديثات الدفع والمحفظة'),
                  subtitle: const Text('إشعار عند نجاح أو فشل الدفع والشحن.'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
