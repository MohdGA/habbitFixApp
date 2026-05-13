import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/theme/app_theme.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _passwordController = TextEditingController();
  bool _confirmed = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (!_confirmed) return;
    if (_passwordController.text.isEmpty) {
      setState(() => _error = 'Enter your password to confirm');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text('Delete account?'),
        content: const Text(
          'This is permanent. All your habits, streaks, and savings data will be deleted. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Forever', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() { _loading = true; _error = null; });
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/users/me', data: {'password': _passwordController.text});

      // Clear all local data
      await ref.read(secureStorageProvider).clearAll();

      if (mounted) context.go('/onboarding');
    } catch (e) {
      setState(() {
        _error = 'Incorrect password or request failed. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Delete Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Warning card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This action is permanent and cannot be reversed.',
                        style: TextStyle(color: AppColors.red, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              Text('What will be deleted:',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),

              ...[
                'All habits and check-in history',
                'All streak data and freeze tokens',
                'All savings goals and progress',
                'All XP, levels, and badges',
                'All community posts and comments',
                'Your account and profile',
              ].map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Icon(Icons.close, color: AppColors.red, size: 16),
                      const SizedBox(width: 10),
                      Text(item,
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Checkbox confirmation
              CheckboxListTile(
                value: _confirmed,
                onChanged: (v) => setState(() => _confirmed = v ?? false),
                activeColor: AppColors.red,
                title: const Text(
                  'I understand this is permanent and cannot be undone',
                  style: TextStyle(fontSize: 14),
                ),
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 16),

              // Password field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm with your password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: TextStyle(color: AppColors.red, fontSize: 13)),
              ],

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _confirmed ? AppColors.red : AppColors.bgTertiary,
                  ),
                  onPressed: (_confirmed && !_loading) ? _delete : null,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Delete My Account',
                          style: TextStyle(color: Colors.white)),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
