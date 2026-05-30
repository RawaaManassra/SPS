import 'package:flutter/material.dart';

import 'package:flut/features/driver/notifications/models/driver_notification.dart';
import 'package:flut/features/driver/notifications/services/notification_service.dart';

class DriverNotificationsScreen extends StatefulWidget {
  const DriverNotificationsScreen({super.key});

  @override
  State<DriverNotificationsScreen> createState() => _DriverNotificationsScreenState();
}

class _DriverNotificationsScreenState extends State<DriverNotificationsScreen> {
  final _notificationService = NotificationService();

  bool _isLoading = true;
  List<DriverNotification> _notifications = const [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Text(
              'تابعي آخر التنبيهات المتعلقة بجلسات الوقوف والمخالفات والمدفوعات من مكان واحد.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5B6472),
              ),
            ),
            const SizedBox(height: 18),
            if (_isLoading)
              const _NotificationsLoadingState()
            else if (_notifications.isEmpty)
              const _EmptyNotificationsState()
            else
              ...List.generate(_notifications.length, (index) {
                final item = _notifications[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: index == _notifications.length - 1 ? 0 : 12),
                  child: _NotificationCard(
                    notification: item,
                    onTap: () => _markAsRead(item),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications = await _notificationService.getNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
      });
    } on NotificationException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(DriverNotification notification) async {
    if (notification.isRead) return;

    setState(() {
      _notifications = _notifications
          .map((item) => item.id == notification.id ? item.copyWith(isRead: true) : item)
          .toList();
    });

    try {
      await _notificationService.markAsRead(notification.id);
    } on NotificationException catch (error) {
      if (!mounted) return;
      setState(() {
        _notifications = _notifications
            .map((item) => item.id == notification.id ? item.copyWith(isRead: false) : item)
            .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final DriverNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = _notificationVisual(notification.type);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          border: notification.isRead
              ? null
              : Border.all(
                  color: const Color(0xFFE7F2EF),
                  width: 1.5,
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: visual.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(visual.icon, color: visual.color),
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
                          notification.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        _formatRelativeTime(notification.createdAt),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF5B6472),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead) ...[
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
      ),
    );
  }

  _NotificationVisual _notificationVisual(String type) {
    switch (type) {
      case 'fine':
        return const _NotificationVisual(
          icon: Icons.gpp_good_outlined,
          color: Color(0xFFC8922E),
        );
      case 'session_ended':
        return const _NotificationVisual(
          icon: Icons.done_all_rounded,
          color: Color(0xFF0F766E),
        );
      case 'session_expiring':
        return const _NotificationVisual(
          icon: Icons.timer_outlined,
          color: Color(0xFF0F766E),
        );
      default:
        return const _NotificationVisual(
          icon: Icons.notifications_none_rounded,
          color: Color(0xFF2563EB),
        );
    }
  }

  String _formatRelativeTime(DateTime? dateTime) {
    if (dateTime == null) return 'الآن';

    final now = DateTime.now();
    final localTime = dateTime.toLocal();
    final difference = now.difference(localTime);

    if (difference.inMinutes < 1) return 'الآن';
    if (difference.inHours < 1) return 'منذ ${difference.inMinutes} د';
    if (difference.inDays < 1) return 'منذ ${difference.inHours} س';
    if (difference.inDays == 1) return 'أمس';
    return 'منذ ${difference.inDays} يوم';
  }
}

class _NotificationsLoadingState extends StatelessWidget {
  const _NotificationsLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _EmptyNotificationsState extends StatelessWidget {
  const _EmptyNotificationsState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F2EF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              color: Color(0xFF0F766E),
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'لا توجد إشعارات حالياً',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر هنا التنبيهات الجديدة المتعلقة بالمخالفات والجلسات والمدفوعات عند توفرها.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5B6472),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationVisual {
  const _NotificationVisual({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;
}
