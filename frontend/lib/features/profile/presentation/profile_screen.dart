import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  final [userRes, statsRes, badgesRes] = await Future.wait([
    dio.get('/users/me'),
    dio.get('/stats'),
    dio.get('/stats/badges'),
  ]);

  return {
    'user': userRes.data['user'],
    'stats': statsRes.data['stats'],
    'badges': badgesRes.data['badges'],
  };
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        color: AppColors.orange,
        backgroundColor: AppColors.surface,
        onRefresh: () => ref.refresh(profileProvider.future),
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(title: Text('Profile'), pinned: true),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  profileAsync.when(
                    data: (data) {
                      final user = data['user'] as Map<String, dynamic>? ?? {};
                      final stats = data['stats'] as Map<String, dynamic>? ?? {};
                      final badges = (data['badges'] as List<dynamic>?) ?? [];

                      return Column(
                        children: [
                          _ProfileHeader(user: user, stats: stats)
                              .animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
                          const SizedBox(height: 20),
                          _XpCard(stats: stats)
                              .animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),
                          const SizedBox(height: 20),
                          _StatsGrid(stats: stats)
                              .animate(delay: 150.ms).fadeIn(),
                          const SizedBox(height: 20),
                          if (badges.isNotEmpty) ...[
                            _BadgesSection(badges: badges)
                                .animate(delay: 200.ms).fadeIn(),
                            const SizedBox(height: 20),
                          ],
                          _SettingsSection()
                              .animate(delay: 250.ms).fadeIn(),
                          const SizedBox(height: 24),
                          _LogoutButton(),
                          const SizedBox(height: 80),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Center(
                      child: Text('Error loading profile: $e',
                          style: const TextStyle(color: AppColors.red)),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> stats;

  const _ProfileHeader({required this.user, required this.stats});

  @override
  Widget build(BuildContext context) {
    final displayName = user['displayName'] as String? ?? 'User';
    final username = user['username'] as String? ?? '';
    final memberSince = user['createdAt'] as String?;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppColors.xpGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 2),
                Text('@$username',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
                if (memberSince != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Member since ${DateTime.parse(memberSince).year}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── XP Card ──────────────────────────────────────────────────────────────────

class _XpCard extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _XpCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final level = stats['level'] as int? ?? 1;
    final totalXp = stats['totalXp'] as int? ?? 0;
    final nextLevelXp = stats['nextLevelXp'] as int? ?? 100;
    final xpProgress = (stats['xpProgress'] as num?)?.toDouble() ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0A2D), Color(0xFF0F0015)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text('Level $level',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: AppColors.purple)),
              const Spacer(),
              Text('$totalXp XP total',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: xpProgress,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.purple),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$totalXp / $nextLevelXp XP to Level ${level + 1}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Grid ───────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('🔥', '${stats['longestStreak'] ?? 0}d', 'Best Streak'),
      ('✅', '${stats['totalCheckins'] ?? 0}', 'Check-ins'),
      ('❄️', '${stats['totalFreezeUsed'] ?? 0}', 'Freezes Used'),
      (
        '💰',
        '\$${(stats['totalMoneySaved'] as num?)?.toStringAsFixed(0) ?? '0'}',
        'Saved'
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 140, // fixed px height — no overflow regardless of density
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.$1, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 2),
              Text(
                item.$2,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orange,
                ),
              ),
              Text(
                item.$3,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Badges Section ───────────────────────────────────────────────────────────

class _BadgesSection extends StatelessWidget {
  final List<dynamic> badges;
  const _BadgesSection({required this.badges});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Badges (${badges.length})',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: badges.map((b) {
              final badge =
                  (b as Map<String, dynamic>)['badge'] as Map<String, dynamic>? ??
                      {};
              return Container(
                margin: const EdgeInsets.only(right: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text(badge['emoji'] as String? ?? '🏅',
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 4),
                    Text(
                      badge['name'] as String? ?? '',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Settings Section ─────────────────────────────────────────────────────────

class _SettingsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _SettingsItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () => _showNotificationsSheet(context),
          ),
          _Divider(),
          _SettingsItem(
            icon: Icons.lock_outline_rounded,
            label: 'Change Password',
            onTap: () {
              final dio = ref.read(dioProvider);
              _showChangePasswordSheet(context, dio);
            },
          ),
          _Divider(),
          _SettingsItem(
            icon: Icons.info_outline_rounded,
            label: 'About habbitFix',
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _NotificationsSheet(),
    );
  }

  void _showChangePasswordSheet(BuildContext context, Dio dio) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ChangePasswordSheet(dio: dio),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🔥', style: TextStyle(fontSize: 28)),
            SizedBox(width: 10),
            Text('habbitFix'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            SizedBox(height: 12),
            Text(
              'habbitFix helps you quit bad habits, build good ones, and track your progress with streaks, savings, and AI coaching.',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              'Built with ❤️ to help you become your best self.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close',
                style: TextStyle(color: AppColors.orange)),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      trailing:
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
        height: 1, color: AppColors.border, indent: 16, endIndent: 16);
  }
}

// ─── Notifications Sheet ──────────────────────────────────────────────────────

class _NotificationsSheet extends ConsumerStatefulWidget {
  const _NotificationsSheet();

  @override
  ConsumerState<_NotificationsSheet> createState() =>
      _NotificationsSheetState();
}

class _NotificationsSheetState extends ConsumerState<_NotificationsSheet> {
  bool _streakAlerts = true;
  bool _milestoneAlerts = true;
  bool _weeklyReport = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    try {
      final resp = await ref.read(dioProvider).get('/users/me');
      final prefs =
          resp.data['user']['notificationPrefs'] as Map<String, dynamic>? ??
              {};
      if (mounted) {
        setState(() {
          _streakAlerts = prefs['streakAlerts'] as bool? ?? true;
          _milestoneAlerts = prefs['milestoneAlerts'] as bool? ?? true;
          _weeklyReport = prefs['weeklyReport'] as bool? ?? false;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(dioProvider).patch('/users/me/notifications', data: {
        'streakAlerts': _streakAlerts,
        'milestoneAlerts': _milestoneAlerts,
        'weeklyReport': _weeklyReport,
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text('Notifications',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          const Text(
            'Choose which reminders you want to receive.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 24),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _NotifToggleRow(
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.orange,
                    title: 'Daily streak reminders',
                    subtitle: "Don't break your streak",
                    value: _streakAlerts,
                    onChanged: (v) {
                      setState(() => _streakAlerts = v);
                      _save();
                    },
                  ),
                  const Divider(
                      height: 1, color: AppColors.border, indent: 16),
                  _NotifToggleRow(
                    icon: Icons.emoji_events_rounded,
                    color: AppColors.yellow,
                    title: 'Milestone achievements',
                    subtitle: 'Celebrate your progress',
                    value: _milestoneAlerts,
                    onChanged: (v) {
                      setState(() => _milestoneAlerts = v);
                      _save();
                    },
                  ),
                  const Divider(
                      height: 1, color: AppColors.border, indent: 16),
                  _NotifToggleRow(
                    icon: Icons.bar_chart_rounded,
                    color: AppColors.purple,
                    title: 'Weekly progress report',
                    subtitle: 'Your week in review every Sunday',
                    value: _weeklyReport,
                    onChanged: (v) {
                      setState(() => _weeklyReport = v);
                      _save();
                    },
                  ),
                ],
              ),
            ),
          if (_saving) ...[
            const SizedBox(height: 12),
            const Center(
              child: Text('Saving…',
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotifToggleRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifToggleRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.orange,
          ),
        ],
      ),
    );
  }
}

// ─── Change Password Sheet ────────────────────────────────────────────────────

class _ChangePasswordSheet extends StatefulWidget {
  final Dio dio;
  const _ChangePasswordSheet({required this.dio});

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;
  bool _success = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentCtrl.text;
    final newPass = _newCtrl.text;
    final confirm = _confirmCtrl.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'All fields are required');
      return;
    }
    if (newPass.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters');
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(newPass) ||
        !RegExp(r'[0-9]').hasMatch(newPass)) {
      setState(() =>
          _error = 'Password needs an uppercase letter and a number');
      return;
    }
    if (newPass != confirm) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.dio.post('/auth/change-password', data: {
        'currentPassword': current,
        'newPassword': newPass,
      });

      if (!mounted) return;
      setState(() {
        _success = true;
        _loading = false;
      });
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) Navigator.pop(context);
    } on DioException catch (e) {
      if (!mounted) return;
      final code = e.response?.statusCode;
      setState(() {
        _loading = false;
        _error = (code == 401 || code == 403 || code == 400)
            ? 'Current password is incorrect'
            : 'Failed to change password. Please try again.';
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'An unexpected error occurred';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text('Change Password',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          const Text(
            'Must be 8+ characters with an uppercase letter and a number.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 24),

          if (_success) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      color: AppColors.green, size: 20),
                  SizedBox(width: 10),
                  Text('Password changed successfully!',
                      style: TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ] else ...[
            AppTextField(
              controller: _currentCtrl,
              label: 'Current password',
              obscureText: _obscureCurrent,
              textInputAction: TextInputAction.next,
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscureCurrent = !_obscureCurrent),
                icon: Icon(
                  _obscureCurrent
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _newCtrl,
              label: 'New password',
              obscureText: _obscureNew,
              textInputAction: TextInputAction.next,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
                icon: Icon(
                  _obscureNew
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _confirmCtrl,
              label: 'Confirm new password',
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.red, size: 15),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(_error!,
                        style: const TextStyle(
                            color: AppColors.red, fontSize: 13)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            AppButton(
              label: 'Change Password',
              onPressed: _submit,
              isLoading: _loading,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Logout Button ────────────────────────────────────────────────────────────

class _LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () async {
        await ref.read(authNotifierProvider.notifier).logout();
        if (context.mounted) context.go('/login');
      },
      icon: const Icon(Icons.logout_rounded, color: AppColors.red, size: 18),
      label: const Text('Sign Out',
          style:
              TextStyle(color: AppColors.red, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        side: BorderSide(color: AppColors.red.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
