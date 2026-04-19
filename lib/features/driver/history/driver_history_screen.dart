import 'package:flutter/material.dart';

class DriverHistoryScreen extends StatelessWidget {
  const DriverHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        Text(
          'سجل النشاط',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'نموذج مبدئي لسجل جلسات الوقوف والمدفوعات والمخالفات.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF5B6472),
          ),
        ),
        const SizedBox(height: 18),
        const HistoryItemCard(
          icon: Icons.local_parking_outlined,
          title: 'جلسة وقوف مكتملة',
          subtitle: 'المركبة 24-381-15 • شارع عين سارة',
          trailing: '30 دقيقة',
          amount: '1 شيكل',
          status: 'مدفوعة',
        ),
        const SizedBox(height: 12),
        const HistoryItemCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'شحن المحفظة',
          subtitle: 'Jawwal Pay',
          trailing: 'اليوم',
          amount: '+20 شيكل',
          status: 'ناجحة',
        ),
        const SizedBox(height: 12),
        const HistoryItemCard(
          icon: Icons.gavel_outlined,
          title: 'مخالفة وقوف',
          subtitle: 'المركبة 31-662-08 • صورة مرفقة',
          trailing: 'أمس',
          amount: '15 شيكل',
          status: 'بانتظار الدفع',
        ),
      ],
    );
  }
}

class HistoryItemCard extends StatelessWidget {
  const HistoryItemCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.amount,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final String amount;
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F2EF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF0F766E)),
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
                      trailing,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5B6472),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      amount,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2EEE5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        status,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: const Color(0xFF5B6472),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
