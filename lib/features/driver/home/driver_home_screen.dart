import 'package:flutter/material.dart';

import 'package:flut/features/driver/parking/driver_parking_session.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({
    super.key,
    required this.greetingName,
    required this.activeSession,
    required this.walletBalance,
    required this.isWalletLoading,
    required this.onStartSession,
    required this.onEndSession,
    required this.onExtendSession,
    required this.onOpenViolations,
    required this.onOpenWallet,
  });

  final String greetingName;
  final DriverParkingSession? activeSession;
  final double walletBalance;
  final bool isWalletLoading;
  final VoidCallback onStartSession;
  final VoidCallback onEndSession;
  final VoidCallback onExtendSession;
  final VoidCallback onOpenViolations;
  final VoidCallback onOpenWallet;

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
                'مرحباً، $greetingName',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'إدارة جلسات الوقوف والمركبات والمحفظة من مكان واحد.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.92),
                ),
              ),
              const SizedBox(height: 18),
              InkWell(
                onTap: onOpenWallet,
                borderRadius: BorderRadius.circular(20),
                child: Ink(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
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
                      if (isWalletLoading)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      else
                        Text(
                          '${walletBalance.toStringAsFixed(2)} شيكل',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFFFF4EF),
            Color(0xFFFFECE4),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF2C3AF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12B54708),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE1D4),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.report_gmailerrorred_rounded,
                  color: Color(0xFFCC5A2E),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المخالفات والمدفوعات',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF7A271A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تابعي المخالفات الحالية، حالة الدفع، وقدّمي شكوى أو اعتراض عند الحاجة.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF7D5246),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onOpenViolations,
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              backgroundColor: const Color(0xFFB54708),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            label: const Text('فتح صفحة المخالفات'),
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
              color: Colors.white.withOpacity(0.72),
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
              'تطبيق موقفي يساعدك على إدارة الوقوف بشكل أسرع، ومتابعة الرصيد والمركبات والمخالفات بدون الرجوع لعدادات الوقوف التقليدية.',
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
            'ابدئي جلسة جديدة باختيار المركبة والموقع والمدة، وسيتم خصم المبلغ من المحفظة مباشرة.',
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
    final progress = session.durationMinutes == 0
        ? 0.0
        : (remainingMinutes / session.durationMinutes).clamp(0.0, 1.0);

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
        color: Colors.white.withOpacity(0.92),
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
