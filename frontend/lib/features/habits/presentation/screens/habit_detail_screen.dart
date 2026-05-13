import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../habits/data/habits_repository.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final String habitId;
  const HabitDetailScreen({super.key, required this.habitId});

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  Map<String, dynamic>? _habit;
  List<dynamic> _checkins = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final dio = ref.read(dioProvider);
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 60));
      final fmt = (DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      final results = await Future.wait([
        dio.get('/habits/${widget.habitId}'),
        dio.get('/checkins',
            queryParameters: {
              'habitId': widget.habitId,
              'from': fmt(from),
              'to': fmt(now),
            }),
      ]);

      if (mounted) {
        setState(() {
          _habit = results[0].data is Map ? results[0].data as Map<String, dynamic> : null;
          final raw = results[1].data;
          _checkins = (raw is Map && raw['checkins'] is List)
              ? raw['checkins'] as List
              : [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Failed to load habit'; _loading = false; });
    }
  }

  Future<void> _checkIn() async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/checkins', data: {'habitId': widget.habitId});
      ref.invalidate(habitsProvider);
      _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Check-in failed'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(backgroundColor: AppColors.bgSecondary),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _habit == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.bgSecondary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(child: Text(_error ?? 'Habit not found')),
      );
    }

    final name = _habit!['name'] as String? ?? '';
    final emoji = _habit!['emoji'] as String? ?? '🎯';
    final type = _habit!['type'] as String? ?? '';
    final streaks = _habit!['streaks'];
    final streak = (streaks is List && streaks.isNotEmpty)
        ? streaks.first as Map<String, dynamic>
        : <String, dynamic>{};
    final currentStreak = streak['currentStreak'] as int? ?? 0;
    final longestStreak = streak['longestStreak'] as int? ?? 0;

    // Build 60-day calendar data
    final checkinDates = <String>{};
    for (final c in _checkins) {
      if (c is Map && c['date'] != null) {
        final d = c['date'].toString().substring(0, 10);
        checkinDates.add(d);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgSecondary,
        title: Text('$emoji  $name'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/habits/edit', extra: _habit),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Streak stats row
          Row(
            children: [
              _StatCard(label: 'Current streak', value: '$currentStreak days'),
              const SizedBox(width: 12),
              _StatCard(label: 'Longest streak', value: '$longestStreak days'),
              const SizedBox(width: 12),
              _StatCard(label: 'Check-ins', value: '${_checkins.length}'),
            ],
          ),

          const SizedBox(height: 28),

          // Type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: type == 'QUIT' ? AppColors.red.withValues(alpha: 0.15) : AppColors.greenLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              type == 'QUIT' ? '🚫 Quit habit' : '✅ Build habit',
              style: TextStyle(
                color: type == 'QUIT' ? AppColors.red : AppColors.green,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 28),
          Text('Last 60 days',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          // 60-day dot grid
          _CalendarGrid(checkinDates: checkinDates),

          const SizedBox(height: 32),

          // Check-in button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _checkIn,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Check In Today'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.orange,
                    )),
            const SizedBox(height: 4),
            Text(label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final Set<String> checkinDates;
  const _CalendarGrid({required this.checkinDates});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(60, (i) => now.subtract(Duration(days: 59 - i)));

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: days.map((day) {
        final key =
            '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        final done = checkinDates.contains(key);
        return Tooltip(
          message: key,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: done ? AppColors.green : AppColors.bgQuaternary,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        );
      }).toList(),
    );
  }
}
