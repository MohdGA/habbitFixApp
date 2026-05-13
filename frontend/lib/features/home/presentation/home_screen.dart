import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../habits/presentation/widgets/habit_card.dart';
import '../../habits/data/habits_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        color: AppColors.orange,
        backgroundColor: AppColors.surface,
        onRefresh: () => ref.refresh(habitsProvider.future),
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              backgroundColor: AppColors.bg,
              expandedHeight: 120,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$_greeting 👋',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      habitsAsync.when(
                        data: (data) => Text(
                          'You\'re on day ${data.bestStreak}!',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                colors: [AppColors.orange, Color(0xFFFF6B00)],
                              ).createShader(const Rect.fromLTWH(0, 0, 200, 40)),
                          ),
                        ),
                        loading: () => const Text(
                          'Loading...',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 20),
                        ),
                        error: (_, __) => Text(
                          'Keep going! 💪',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: habitsAsync.when(
                    data: (data) => _XpBadge(level: data.level, xp: data.totalXp),
                    loading: () => const SizedBox(width: 48, height: 48),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Plant hero card
                  habitsAsync.when(
                    data: (data) => _PlantHeroCard(
                      streak: data.bestStreak,
                      freezeCount: data.freezeTokens,
                    ),
                    loading: () => _CardShimmer(height: 200),
                    error: (_, __) => const SizedBox.shrink(),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

                  const SizedBox(height: 16),

                  // Savings card
                  habitsAsync.when(
                    data: (data) => data.totalSaved > 0
                        ? _SavingsCard(totalSaved: data.totalSaved, goal: data.savingsGoalAmount)
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // Today's habits
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Today\'s Habits', style: Theme.of(context).textTheme.headlineSmall),
                      Text(
                        DateFormat('MMM d').format(DateTime.now()),
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ).animate(delay: 150.ms).fadeIn(),

                  const SizedBox(height: 12),

                  habitsAsync.when(
                    data: (data) => data.habits.isEmpty
                        ? _EmptyHabitsCard()
                        : Column(
                            children: data.habits
                                .asMap()
                                .entries
                                .map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: HabitCard(
                                    habit: e.value,
                                    onCheckin: (habitId) {
                                      ref.read(habitsNotifierProvider.notifier).checkin(habitId);
                                    },
                                  ).animate(delay: Duration(milliseconds: 200 + e.key * 60)).fadeIn().slideX(begin: 0.1),
                                ))
                                .toList(),
                          ),
                    loading: () => Column(
                      children: List.generate(
                        3,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _CardShimmer(height: 80),
                        ),
                      ),
                    ),
                    error: (e, _) => Center(
                      child: Text('Error: $e', style: const TextStyle(color: AppColors.red)),
                    ),
                  ),

                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _XpBadge extends StatelessWidget {
  final int level;
  final int xp;

  const _XpBadge({required this.level, required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: AppColors.xpGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: AppColors.purple.withValues(alpha: 0.4), blurRadius: 12, spreadRadius: 2),
        ],
      ),
      child: Center(
        child: Text(
          'L$level',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _PlantHeroCard extends StatelessWidget {
  final int streak;
  final int freezeCount;

  const _PlantHeroCard({required this.streak, required this.freezeCount});

  String get _plantEmoji {
    if (streak < 3) return '🌱';
    if (streak < 7) return '🌿';
    if (streak < 14) return '🪴';
    if (streak < 30) return '🌳';
    if (streak < 100) return '🎋';
    return '🌲';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2D1A), Color(0xFF0F1A0F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          // Plant visual
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department_rounded, color: AppColors.orange, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '$streak day streak',
                            style: const TextStyle(
                              color: AppColors.orange,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Your plant\nis thriving!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.green,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  streak == 0
                      ? 'Start today to grow'
                      : 'Keep going to reach day ${_nextMilestone(streak)}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 16),
                // Freeze tokens
                Row(
                  children: [
                    const Text('❄️', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      '$freezeCount freeze token${freezeCount != 1 ? 's' : ''}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Plant emoji
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                _plantEmoji,
                style: const TextStyle(fontSize: 72),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .moveY(begin: 0, end: -6, duration: 2000.ms, curve: Curves.easeInOut),
            ),
          ),
        ],
      ),
    );
  }

  int _nextMilestone(int streak) {
    final milestones = [1, 3, 7, 14, 21, 30, 60, 90, 100, 180, 365];
    return milestones.firstWhere((m) => m > streak, orElse: () => streak + 365);
  }
}

class _SavingsCard extends StatelessWidget {
  final double totalSaved;
  final double? goal;

  const _SavingsCard({required this.totalSaved, this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = goal != null ? (totalSaved / goal!).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C1A0A), Color(0xFF120E00)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.yellow.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💰', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Money Saved',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.yellow,
                ),
              ),
              const Spacer(),
              Text(
                '\$${totalSaved.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.yellow,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          if (goal != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.yellow),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(progress * 100).toInt()}% of \$${goal!.toStringAsFixed(0)} goal',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyHabitsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Text('🎯', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'No habits yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the Habits tab to add your first habit and start your journey.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _CardShimmer extends StatelessWidget {
  final double height;
  const _CardShimmer({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 1000.ms, color: AppColors.border.withValues(alpha: 0.5));
  }
}
