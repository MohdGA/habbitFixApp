import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/secure_storage.dart';
import '../../../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final storage = ref.read(secureStorageProvider);
    final hasTokens = await storage.hasTokens();
    final isFirstLaunch = await storage.isFirstLaunch();

    if (!mounted) return;

    if (hasTokens) {
      context.go('/home');
    } else if (isFirstLaunch) {
      await storage.markLaunched();
      context.go('/onboarding');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: AppColors.streakGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withValues(alpha: 0.4),
                    blurRadius: 32,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🔥', style: TextStyle(fontSize: 48)),
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            Text(
              'habbitFix',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppColors.orange,
                letterSpacing: -1,
              ),
            )
                .animate(delay: 300.ms)
                .slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOut)
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 8),

            Text(
              'Fix your habits. Every day.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
                .animate(delay: 500.ms)
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 64),

            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.orange.withValues(alpha: 0.6),
              ),
            )
                .animate(delay: 800.ms)
                .fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
