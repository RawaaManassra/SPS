import 'package:flutter/material.dart';

import 'package:flut/features/driver/profile/driver_change_password_screen.dart';
import 'package:flut/features/driver/profile/driver_edit_profile_screen.dart';
import 'package:flut/features/driver/profile/driver_notification_settings_screen.dart';
import 'package:flut/features/driver/profile/driver_profile_form_result.dart';
import 'package:flut/features/driver/profile/models/driver_user_profile.dart';
import 'package:flut/features/driver/profile/services/profile_service.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({
    super.key,
    required this.profile,
    required this.isLoading,
    required this.onRefreshProfile,
    required this.onSaveProfile,
    required this.onLogout,
  });

  final DriverUserProfile? profile;
  final bool isLoading;
  final Future<void> Function() onRefreshProfile;
  final Future<void> Function(DriverProfileFormResult result) onSaveProfile;
  final Future<void> Function() onLogout;

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  bool _isSavingProfile = false;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    if (widget.isLoading && profile == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (profile == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          _ProfileSection(
            title: 'بيانات الحساب',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'تعذر تحميل بيانات الحساب حالياً. تأكد من تشغيل الـ backend ثم أعد المحاولة.',
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: widget.onRefreshProfile,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
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
              Row(
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.fullName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'حساب سائق مفعل',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'تم توثيق بيانات الهوية ورخصة القيادة في الحساب، ويمكنك استخدام الوقوف والمحفظة والمخالفات من نفس التطبيق.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _ProfileSection(
          title: 'بيانات الحساب',
          child: Column(
            children: [
              _ProfileInfoRow(
                icon: Icons.person_outline_rounded,
                label: 'الاسم الكامل',
                value: profile.fullName,
              ),
              _ProfileInfoRow(
                icon: Icons.badge_outlined,
                label: 'رقم الهوية',
                value: profile.nationalId,
              ),
              _ProfileInfoRow(
                icon: Icons.credit_card_outlined,
                label: 'رقم رخصة القيادة',
                value: profile.drivingLicenceId ?? 'غير متوفر',
              ),
              _ProfileInfoRow(
                icon: Icons.phone_iphone_rounded,
                label: 'رقم الجوال',
                value: profile.phoneNumber,
              ),
              _ProfileInfoRow(
                icon: Icons.email_outlined,
                label: 'البريد الإلكتروني',
                value: profile.email ?? 'غير مضاف',
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _ProfileSection(
          title: 'إعدادات الحساب',
          child: Column(
            children: [
              _ProfileActionTile(
                icon: Icons.edit_outlined,
                title: 'تعديل البيانات الشخصية',
                subtitle: 'تحديث الاسم الكامل والجوال والبريد الإلكتروني.',
                onTap: _isSavingProfile ? () {} : () => _openEditProfile(profile),
              ),
              const SizedBox(height: 10),
              _ProfileActionTile(
                icon: Icons.lock_reset_rounded,
                title: 'تغيير كلمة المرور',
                subtitle: 'اختيار كلمة مرور جديدة للحساب.',
                onTap: _openChangePassword,
              ),
              const SizedBox(height: 10),
              _ProfileActionTile(
                icon: Icons.notifications_outlined,
                title: 'إعدادات الإشعارات',
                subtitle: 'التحكم بتنبيهات الجلسات والمخالفات.',
                onTap: _openNotificationSettings,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _ProfileSection(
          title: 'إجراءات الحساب',
          child: OutlinedButton.icon(
            onPressed: () => _confirmLogout(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              side: const BorderSide(color: Color(0xFFB42318)),
              foregroundColor: const Color(0xFFB42318),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('تسجيل الخروج'),
          ),
        ),
      ],
    );
  }

  Future<void> _openEditProfile(DriverUserProfile profile) async {
    final result = await Navigator.push<DriverProfileFormResult>(
      context,
      MaterialPageRoute(
        builder: (_) => DriverEditProfileScreen(
          initialFullName: profile.fullName,
          initialPhoneNumber: profile.phoneNumber,
          initialEmail: profile.email ?? '',
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _isSavingProfile = true;
    });

    try {
      await widget.onSaveProfile(result);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث بيانات الحساب بنجاح.'),
        ),
      );
    } on ProfileException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSavingProfile = false;
      });
    }
  }

  Future<void> _openChangePassword() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DriverChangePasswordScreen(),
      ),
    );
  }

  Future<void> _openNotificationSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DriverNotificationSettingsScreen(),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل تريد تسجيل الخروج من حساب السائق الآن؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await widget.onLogout();
    }
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
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
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F2EF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF0F766E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5B6472),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7F3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F2EF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF0F766E)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF5B6472),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF8A8F98),
            ),
          ],
        ),
      ),
    );
  }
}
