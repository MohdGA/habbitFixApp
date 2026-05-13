import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/habits_repository.dart';
import '../widgets/habit_card.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

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
            const SliverAppBar(title: Text('My Habits'), pinned: true),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: habitsAsync.when(
                data: (data) => SliverList(
                  delegate: SliverChildListDelegate([
                    if (data.habits.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Column(
                            children: [
                              const Text('🎯', style: TextStyle(fontSize: 64)),
                              const SizedBox(height: 16),
                              Text('No habits yet', style: Theme.of(context).textTheme.headlineMedium),
                              const SizedBox(height: 8),
                              const Text(
                                'Tap + to add your first habit',
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...data.habits.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Dismissible(
                          key: ValueKey(e.value.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppColors.red.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete_outline_rounded,
                                    color: AppColors.red, size: 26),
                                SizedBox(height: 4),
                                Text('Delete',
                                    style: TextStyle(
                                        color: AppColors.red,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          confirmDismiss: (_) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                title: const Text('Delete Habit?'),
                                content: Text(
                                  'Delete "${e.value.name}"? This will also remove all check-in history and cannot be undone.',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Cancel',
                                        style: TextStyle(
                                            color: AppColors.textMuted)),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('Delete',
                                        style:
                                            TextStyle(color: AppColors.red)),
                                  ),
                                ],
                              ),
                            ) ??
                                false;
                          },
                          onDismissed: (_) => ref
                              .read(habitsNotifierProvider.notifier)
                              .deleteHabit(e.value.id),
                          child: HabitCard(
                            habit: e.value,
                            onCheckin: (id) => ref
                                .read(habitsNotifierProvider.notifier)
                                .checkin(id),
                          ).animate(
                              delay: Duration(
                                      milliseconds: e.key * 60))
                              .fadeIn()
                              .slideX(begin: 0.1),
                        ),
                      )),
                    const SizedBox(height: 100),
                  ]),
                ),
                loading: () => SliverFillRemaining(
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.red))),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/habits/add'),
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Habit', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
