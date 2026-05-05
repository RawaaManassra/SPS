import 'package:flutter/material.dart';

import 'package:flut/features/driver/parking/driver_parking_session.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({
    super.key,
    required this.activeSession,
    required this.onStartSession,
    required this.onEndSession,
    required this.onExtendSession,
    required this.onOpenViolations,
  });

  final DriverParkingSession? activeSession;
  final VoidCallback onStartSession;
  final VoidCallback onEndSession;
  final VoidCallback onExtendSession;
  final VoidCallback onOpenViolations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0F766E),
                Color(0xFF17867D),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'مرحباً، روعة',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'إدارة جلسات الوقوف والمركبات من مكان واحد.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'رصيد المحفظة',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '42.00 شيكل',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (activeSession != null)
          ActiveSessionCard(
            session: activeSession!,
            onEndSession: onEndSession,
            onExtendSession: onExtendSession,
          )
        else
          EmptySessionCard(onStartSession: onStartSession),
        const SizedBox(height: 18),
        HomeViolationsCard(onOpenViolations: onOpenViolations),
        const SizedBox(height: 18),
        const AppMessageCard(),
      ],
    );
  }
}

class HomeViolationsCard extends StatelessWidget {
  const HomeViolationsCard({
    super.key,
    required this.onOpenViolations,
  });

  final VoidCallback onOpenViolations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF0D39B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE7BF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.gpp_good_outlined,
                  color: Color(0xFFC8922E),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'متابعة المخالفات',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'لديك مخالفة غير مدفوعة تحتاج إلى متابعة.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5B6472),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onOpenViolations,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              side: const BorderSide(color: Color(0xFFC8922E)),
              foregroundColor: const Color(0xFF8D6417),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text('عرض المخالفات'),
          ),
        ],
      ),
    );
  }
}

class AppMessageCard extends StatelessWidget {
  const AppMessageCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E7D6),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Color(0xFFC8922E),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'موقفي يساعدك تدير وقوفك بسهولة، وتتابع وقتك ومركباتك بدون الرجوع للعدادات التقليدية.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF3F3A2F),
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptySessionCard extends StatelessWidget {
  const EmptySessionCard({
    super.key,
    required this.onStartSession,
  });

  final VoidCallback onStartSession;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      title: 'حالة الوقوف الحالية',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'لا توجد جلسة وقوف نشطة حالياً.',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ جلسة جديدة باختيار المركبة والموقع والمدة وطريقة الدفع.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF5B6472),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onStartSession,
            icon: const Icon(Icons.local_parking_outlined),
            label: const Text('ابدأ جلسة وقوف'),
          ),
        ],
      ),
    );
  }
}

class ActiveSessionCard extends StatelessWidget {
  const ActiveSessionCard({
    super.key,
    required this.session,
    required this.onEndSession,
    required this.onExtendSession,
  });

  final DriverParkingSession session;
  final VoidCallback onEndSession;
  final VoidCallback onExtendSession;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remainingMinutes = session.remainingMinutes;
    final progress = (remainingMinutes / session.durationMinutes).clamp(0.0, 1.0);

    return SectionCard(
      title: 'جلسة وقوف نشطة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: SizedBox(
              width: 182,
              height: 182,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 168,
                    height: 168,
                    child: CircularProgressIndicator(
                      value: progress.toDouble(),
                      strokeWidth: 12,
                      backgroundColor: const Color(0xFFE7E1D6),
                      color: const Color(0xFF0F766E),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$remainingMinutes',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F766E),
                        ),
                      ),
                      Text(
                        'دقيقة متبقية',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF5B6472),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SessionDetailRow(
            icon: Icons.directions_car_outlined,
            label: 'المركبة',
            value: session.vehiclePlateNumber,
          ),
          SessionDetailRow(
            icon: Icons.place_outlined,
            label: 'الموقع',
            value: session.locationLabel,
          ),
          SessionDetailRow(
            icon: Icons.payments_outlined,
            label: 'الدفع',
            value: session.paymentMethodLabel,
          ),
          SessionDetailRow(
            icon: Icons.schedule_outlined,
            label: 'الانتهاء',
            value: _formatTime(session.endsAt),
          ),
          SessionDetailRow(
            icon: Icons.receipt_long_outlined,
            label: 'المبلغ',
            value: '${session.totalPrice} شيكل',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onExtendSession,
                  child: const Text('تمديد الوقت'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onEndSession,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    side: const BorderSide(color: Color(0xFF0F766E)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('إنهاء الجلسة'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'م' : 'ص';
    return '$hour:$minute $suffix';
  }
}

class SessionDetailRow extends StatelessWidget {
  const SessionDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0F766E)),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5B6472),
                ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
