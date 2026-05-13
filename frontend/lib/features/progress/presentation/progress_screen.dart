import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';

// ─── Heatmap providers ────────────────────────────────────────────────────────

final heatmapProvider = FutureProvider<Map<String, int>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/checkins/heatmap');
  final raw = response.data['heatmap'] as Map<String, dynamic>;
  return raw.map((k, v) => MapEntry(k, v as int));
});

/// Fetches health milestones, dynamically computing daysSince from the
/// earliest habit startDate so the timeline is accurate for this user.
final healthMilestonesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(dioProvider);

  // Get earliest habit start date to compute real daysSince
  int daysSince = 1;
  try {
    final habitsResp = await dio.get('/habits');
    final habits = (habitsResp.data['habits'] as List<dynamic>?) ?? [];
    DateTime? earliest;
    for (final h in habits) {
      final raw = (h as Map<String, dynamic>)['startDate'] as String?;
      if (raw == null) continue;
      final dt = DateTime.tryParse(raw);
      if (dt != null && (earliest == null || dt.isBefore(earliest))) {
        earliest = dt;
      }
    }
    if (earliest != null) {
      daysSince = DateTime.now().difference(earliest).inDays;
      if (daysSince < 1) daysSince = 1;
    }
  } catch (_) {
    // Fall back to 1 day if habits can't be fetched
  }

  final response = await dio.get('/health-milestones?type=general&daysSince=$daysSince');
  final list = response.data['milestones'] as List<dynamic>;
  return list.cast<Map<String, dynamic>>();
});

// ─── Screen ───────────────────────────────────────────────────────────────────

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Progress'),
            pinned: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Heatmap
                _SectionHeader(title: 'Year in Check-ins'),
                const SizedBox(height: 12),
                _HeatmapCard().animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),
                const SizedBox(height: 24),

                // Health timeline
                _SectionHeader(title: 'Health Recovery Timeline'),
                const SizedBox(height: 12),
                _HealthTimeline().animate(delay: 200.ms).fadeIn(),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.headlineSmall);
  }
}

class _HeatmapCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heatmapAsync = ref.watch(heatmapProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: heatmapAsync.when(
        data: (data) => _HeatmapGrid(data: data),
        loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
        error: (_, __) => const Text('Could not load heatmap', style: TextStyle(color: AppColors.textMuted)),
      ),
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  final Map<String, int> data;
  const _HeatmapGrid({required this.data});

  Color _cellColor(int count) {
    if (count == 0) return AppColors.surfaceElevated;
    if (count == 1) return AppColors.green.withValues(alpha: 0.3);
    if (count == 2) return AppColors.green.withValues(alpha: 0.5);
    if (count == 3) return AppColors.green.withValues(alpha: 0.7);
    return AppColors.green;
  }

  @override
  Widget build(BuildContext context) {
    final weeks = <List<DateTime>>[];
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 371));

    DateTime current = start;
    while (current.weekday != DateTime.sunday) {
      current = current.subtract(const Duration(days: 1));
    }

    for (int w = 0; w < 53; w++) {
      final week = <DateTime>[];
      for (int d = 0; d < 7; d++) {
        week.add(current.add(Duration(days: w * 7 + d)));
      }
      weeks.add(week);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: weeks.map((week) => Column(
          children: week.map((day) {
            final key = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
            final count = data[key] ?? 0;
            final isFuture = day.isAfter(today);

            return Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: isFuture ? Colors.transparent : _cellColor(count),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }).toList(),
        )).toList(),
      ),
    );
  }
}

class _HealthTimeline extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestonesAsync = ref.watch(healthMilestonesProvider);

    return milestonesAsync.when(
      data: (milestones) => Column(
        children: milestones.asMap().entries.map((e) {
          final m = e.value;
          final reached = m['reached'] as bool? ?? false;
          final isCurrent = m['isCurrent'] as bool? ?? false;
          final daysUntil = m['daysUntil'] as int? ?? 0;

          return _MilestoneItem(
            emoji: m['emoji'] as String? ?? '⭐',
            title: m['title'] as String? ?? '',
            description: m['description'] as String? ?? '',
            reached: reached,
            isCurrent: isCurrent,
            daysUntil: daysUntil,
            isLast: e.key == milestones.length - 1,
          ).animate(delay: Duration(milliseconds: e.key * 80)).fadeIn().slideX(begin: -0.1);
        }).toList(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Could not load milestones', style: TextStyle(color: AppColors.textMuted)),
    );
  }
}

class _MilestoneItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final bool reached;
  final bool isCurrent;
  final int daysUntil;
  final bool isLast;

  const _MilestoneItem({
    required this.emoji,
    required this.title,
    required this.description,
    required this.reached,
    required this.isCurrent,
    required this.daysUntil,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: reached
                      ? (isCurrent ? AppColors.orange : AppColors.green)
                      : AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: reached
                        ? (isCurrent ? AppColors.orange : AppColors.green)
                        : AppColors.border,
                    width: isCurrent ? 2.5 : 1.5,
                  ),
                  boxShadow: isCurrent
                      ? [BoxShadow(color: AppColors.orange.withValues(alpha: 0.4), blurRadius: 12, spreadRadius: 2)]
                      : null,
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: reached ? AppColors.green.withValues(alpha: 0.4) : AppColors.border,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: reached ? AppColors.textPrimary : AppColors.textMuted,
                          ),
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'YOU ARE HERE',
                            style: TextStyle(
                              color: AppColors.orange,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      if (!reached && daysUntil > 0)
                        Text(
                          'in $daysUntil days',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: reached ? AppColors.textSecondary : AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
