import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _streakAlerts = true;
  bool _weeklyReport = true;
  bool _milestoneAlerts = true;
  bool _communityAlerts = true;
  String _timezone = 'Asia/Bahrain';
  String _currency = 'BHD';

  static const _timezones = [
    'Asia/Bahrain',
    'Asia/Dubai',
    'Asia/Riyadh',
    'Europe/London',
    'America/New_York',
    'America/Los_Angeles',
    'UTC',
  ];

  static const _currencies = ['BHD', 'USD', 'EUR', 'GBP', 'SAR'];

  Future<void> _savePreferences() async {
    try {
      final dio = ref.read(dioProvider);
      await dio.patch('/users/me', data: {
        'timezone': _timezone,
        'currency': _currency,
      });
      await dio.patch('/users/me/notifications', data: {
        'streakAlerts': _streakAlerts,
        'weeklyReport': _weeklyReport,
        'milestoneAlerts': _milestoneAlerts,
        'communityAlerts': _communityAlerts,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save settings'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgSecondary,
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _savePreferences,
            child: Text('Save',
                style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: ListView(
        children: [
          _SectionHeader('Notifications'),
          _ToggleTile(
            title: 'Streak reminders',
            subtitle: 'Daily alerts before your streak resets',
            value: _streakAlerts,
            onChanged: (v) => setState(() => _streakAlerts = v),
          ),
          _ToggleTile(
            title: 'Milestone alerts',
            subtitle: 'Celebrate hitting streak milestones',
            value: _milestoneAlerts,
            onChanged: (v) => setState(() => _milestoneAlerts = v),
          ),
          _ToggleTile(
            title: 'Weekly digest',
            subtitle: 'Sunday summary of your week',
            value: _weeklyReport,
            onChanged: (v) => setState(() => _weeklyReport = v),
          ),
          _ToggleTile(
            title: 'Community likes',
            subtitle: 'When someone likes your post',
            value: _communityAlerts,
            onChanged: (v) => setState(() => _communityAlerts = v),
          ),

          _SectionHeader('Preferences'),
          _DropdownTile(
            title: 'Timezone',
            value: _timezone,
            items: _timezones,
            onChanged: (v) => setState(() => _timezone = v!),
          ),
          _DropdownTile(
            title: 'Currency',
            value: _currency,
            items: _currencies,
            onChanged: (v) => setState(() => _currency = v!),
          ),

          _SectionHeader('Account'),
          ListTile(
            tileColor: AppColors.bgSecondary,
            title: const Text('Change password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showChangePassword(context),
          ),
          const Divider(height: 1),
          ListTile(
            tileColor: AppColors.bgSecondary,
            title: Text('Delete account',
                style: TextStyle(color: AppColors.red)),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.red),
            onTap: () => context.push('/delete-account'),
          ),

          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'habbitFix v1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textQuaternary,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change password',
                style: Theme.of(ctx).textTheme.headlineMedium),
            const SizedBox(height: 24),
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final dio = ref.read(dioProvider);
                    await dio.post('/auth/change-password', data: {
                      'currentPassword': currentCtrl.text,
                      'newPassword': newCtrl.text,
                    });
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password changed')),
                      );
                    }
                  } catch (_) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: const Text('Incorrect current password'),
                          backgroundColor: AppColors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Update Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      tileColor: AppColors.bgSecondary,
      title: Text(title),
      subtitle: Text(subtitle,
          style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.orange,
    );
  }
}

class _DropdownTile extends StatelessWidget {
  final String title;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownTile({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: AppColors.bgSecondary,
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        dropdownColor: AppColors.bgTertiary,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
