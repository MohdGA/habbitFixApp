import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';

part 'habits_repository.g.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

class Habit {
  final String id;
  final String name;
  final String emoji;
  final String type; // QUIT, REDUCE, BUILD
  final String frequency;
  final int currentStreak;
  final int longestStreak;
  final bool checkedToday;
  final double? costPerUnit;
  final String? unit;
  final double? targetAmount;
  final String color;
  final String? startDate;

  const Habit({
    required this.id,
    required this.name,
    required this.emoji,
    required this.type,
    required this.frequency,
    required this.currentStreak,
    required this.longestStreak,
    required this.checkedToday,
    this.costPerUnit,
    this.unit,
    this.targetAmount,
    required this.color,
    this.startDate,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    // 'streaks' is a Streak[] relation (list) — grab first element if it exists
    final streaksList = (json['streaks'] as List<dynamic>?) ?? [];
    final streaks = streaksList.isNotEmpty
        ? streaksList.first as Map<String, dynamic>
        : null;
    final checkins = (json['checkins'] as List<dynamic>?) ?? [];
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String? ?? '🎯',
      type: json['type'] as String,
      frequency: json['frequency'] as String? ?? 'DAILY',
      currentStreak: streaks?['currentStreak'] as int? ?? 0,
      longestStreak: streaks?['longestStreak'] as int? ?? 0,
      checkedToday: checkins.isNotEmpty,
      costPerUnit: (json['costPerUnit'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      targetAmount: (json['targetAmount'] as num?)?.toDouble(),
      color: json['color'] as String? ?? '#FF9F0A',
      startDate: json['startDate'] as String?,
    );
  }
}

class HabitsData {
  final List<Habit> habits;
  final int bestStreak;
  final int freezeTokens;
  final double totalSaved;
  final double? savingsGoalAmount;
  final int level;
  final int totalXp;

  const HabitsData({
    required this.habits,
    required this.bestStreak,
    required this.freezeTokens,
    required this.totalSaved,
    this.savingsGoalAmount,
    required this.level,
    required this.totalXp,
  });
}

// ─── Repository ───────────────────────────────────────────────────────────────

class HabitsRepository {
  final Dio _dio;
  HabitsRepository(this._dio);

  Future<HabitsData> getHabitsAndStats() async {
    final results = await Future.wait([
      _dio.get('/habits'),
      _dio.get('/streaks/freeze-tokens'),
      _dio.get('/stats'),
      _dio.get('/savings'),
    ]);

    final habitsRaw = (results[0].data['habits'] as List<dynamic>)
        .map((h) => Habit.fromJson(h as Map<String, dynamic>))
        .toList();

    final freezeCount = results[1].data['count'] as int? ?? 0;
    final stats = results[2].data['stats'] as Map<String, dynamic>?;
    final savingsData = results[3].data as Map<String, dynamic>;

    final bestStreak = habitsRaw.fold<int>(
      0,
      (max, h) => h.currentStreak > max ? h.currentStreak : max,
    );

    // Sum all savings goal amounts for the overall progress bar
    final savingsGoals =
        (savingsData['goals'] as List<dynamic>?) ?? [];
    final totalGoalAmount = savingsGoals.fold<double>(
      0,
      (sum, g) =>
          sum +
          (((g as Map<String, dynamic>)['goalAmount'] as num?)?.toDouble() ??
              0),
    );

    return HabitsData(
      habits: habitsRaw,
      bestStreak: bestStreak,
      freezeTokens: freezeCount,
      totalSaved: (savingsData['totalSaved'] as num?)?.toDouble() ?? 0,
      savingsGoalAmount: totalGoalAmount > 0 ? totalGoalAmount : null,
      level: stats?['level'] as int? ?? 1,
      totalXp: stats?['totalXp'] as int? ?? 0,
    );
  }

  Future<Map<String, dynamic>> checkin(String habitId, {bool success = true}) async {
    final response = await _dio.post('/checkins', data: {
      'habitId': habitId,
      'success': success,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createHabit(Map<String, dynamic> data) async {
    final response = await _dio.post('/habits', data: data);
    return response.data['habit'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateHabit(
      String habitId, Map<String, dynamic> data) async {
    final response = await _dio.patch('/habits/$habitId', data: data);
    return response.data['habit'] as Map<String, dynamic>;
  }

  Future<void> deleteHabit(String habitId) async {
    await _dio.delete('/habits/$habitId');
  }
}

@riverpod
HabitsRepository habitsRepository(HabitsRepositoryRef ref) {
  return HabitsRepository(ref.watch(dioProvider));
}

@riverpod
Future<HabitsData> habits(HabitsRef ref) {
  return ref.watch(habitsRepositoryProvider).getHabitsAndStats();
}

@riverpod
class HabitsNotifier extends _$HabitsNotifier {
  @override
  Future<void> build() async {}

  Future<Map<String, dynamic>> checkin(String habitId, {bool success = true}) async {
    final result = await ref.read(habitsRepositoryProvider).checkin(habitId, success: success);
    ref.invalidate(habitsProvider);
    return result;
  }

  Future<void> updateHabit(String habitId, Map<String, dynamic> data) async {
    await ref.read(habitsRepositoryProvider).updateHabit(habitId, data);
    ref.invalidate(habitsProvider);
  }

  Future<void> deleteHabit(String habitId) async {
    await ref.read(habitsRepositoryProvider).deleteHabit(habitId);
    ref.invalidate(habitsProvider);
  }
}
