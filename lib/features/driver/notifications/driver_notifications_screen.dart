import 'package:flutter/material.dart';

class DriverNotificationsScreen extends StatelessWidget {
  const DriverNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Text(
            'تابع آخر التنبيهات المتعلقة بجلسات الوقوف والمخالفات والمدفوعات.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5B6472),
            ),
          ),
          const SizedBox(height: 18),
          const _NotificationCard(
            icon: Icons.timer_outlined,
            iconColor: Color(0xFF0F766E),
            title: 'اقتراب انتهاء الجلسة',
            subtitle: 'تبقى 15 دقيقة على انتهاء جلسة الوقوف الحالية.',
            timeLabel: 'الآن',
            isUnread: true,
          ),
          const SizedBox(height: 12),
          const _NotificationCard(
            icon: Icons.gpp_good_outlined,
            iconColor: Color(0xFFC8922E),
            title: 'مخالفة جديدة',
            subtitle: 'تم تسجيل مخالفة على المركبة 31-662-08 وتحتاج إلى متابعة.',
            timeLabel: 'اليوم',
            isUnread: true,
          ),
          const SizedBox(height: 12),
          const _NotificationCard(
            icon: Icons.payments_outlined,
            iconColor: Color(0xFF2563EB),
            title: 'نجاح عملية الدفع',
            subtitle: 'تم دفع 3 شيكل بنجاح لبدء جلسة الوقوف.',
            timeLabel: 'اليوم',
          ),
          const SizedBox(height: 12),
          const _NotificationCard(
            icon: Icons.done_all_rounded,
            iconColor: Color(0xFF0F766E),
            title: 'تم إنهاء الجلسة',
            subtitle: 'انتهت جلسة الوقوف السابقة بنجاح وتم حفظها في السجل.',
            timeLabel: 'أمس',
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    this.isUnread = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String timeLabel;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: isUnread
            ? Border.all(
                color: const Color(0xFFE7F2EF),
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      timeLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5B6472),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (isUnread) ...[
            const SizedBox(width: 10),
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF0F766E),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
