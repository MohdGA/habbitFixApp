import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/habits_repository.dart';

class HabitCard extends StatefulWidget {
  final Habit habit;
  final Function(String habitId) onCheckin;

  const HabitCard({super.key, required this.habit, required this.onCheckin});

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  bool _isChecked = false;
  bool _showXp = false;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.habit.checkedToday;
  }

  Future<void> _handleCheckin() async {
    if (_isChecked) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _isChecked = true;
      _showXp = true;
    });

    widget.onCheckin(widget.habit.id);

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _showXp = false);
  }

  Color get _typeColor {
    switch (widget.habit.type) {
      case 'QUIT':
        return AppColors.red;
      case 'REDUCE':
        return AppColors.yellow;
      case 'BUILD':
        return AppColors.green;
      default:
        return AppColors.orange;
    }
  }

  String get _typeLabel {
    switch (widget.habit.type) {
      case 'QUIT':
        return 'Quit';
      case 'REDUCE':
        return 'Reduce';
      case 'BUILD':
        return 'Build';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _handleCheckin,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isChecked
                  ? AppColors.green.withValues(alpha: 0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isChecked ? AppColors.green.withValues(alpha: 0.4) : AppColors.border,
                width: _isChecked ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                // Emoji
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      widget.habit.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.habit.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: _isChecked ? TextDecoration.lineThrough : null,
                          color: _isChecked ? AppColors.textMuted : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _typeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _typeLabel,
                              style: TextStyle(
                                color: _typeColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (widget.habit.currentStreak > 0) ...[
                            const Icon(Icons.local_fire_department_rounded, color: AppColors.orange, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              '${widget.habit.currentStreak}d',
                              style: const TextStyle(
                                color: AppColors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _isChecked ? AppColors.green : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isChecked ? AppColors.green : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: _isChecked
                      ? const Icon(Icons.check_rounded, color: Colors.black, size: 16)
                      : null,
                ),
              ],
            ),
          ),
        ),

          // Edit button (top-right, always visible)
        Positioned(
          top: 8,
          right: 48,
          child: GestureDetector(
            onTap: () => context.push('/habits/edit', extra: widget.habit),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_outlined,
                  color: AppColors.textMuted, size: 14),
            ),
          ),
        ),

        // XP Float animation
        if (_showXp)
          Positioned(
            right: 16,
            top: 0,
            child: Text(
              '+10 XP',
              style: TextStyle(
                color: AppColors.purple,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                shadows: [Shadow(color: AppColors.purple.withValues(alpha: 0.5), blurRadius: 8)],
              ),
            )
                .animate()
                .moveY(begin: 0, end: -40, duration: 1200.ms, curve: Curves.easeOut)
                .fadeOut(delay: 800.ms, duration: 400.ms),
          ),
      ],
    );
  }
}
