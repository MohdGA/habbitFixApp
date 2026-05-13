import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/habits_repository.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();

  String _selectedType = 'QUIT';
  String _selectedEmoji = '🎯';
  bool _isLoading = false;
  String? _error;

  final _types = [
    ('QUIT', '🚫', 'Quit', 'Stop doing this completely', AppColors.red),
    ('REDUCE', '📉', 'Reduce', 'Do less of this each day', AppColors.yellow),
    ('BUILD', '💪', 'Build', 'Do more of this each day', AppColors.green),
  ];

  final _emojis = ['🎯', '🚬', '🍺', '☕', '🍕', '📱', '🎮', '💊', '🏋️', '📚', '🧘', '💤'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _costCtrl.dispose();
    _targetCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(habitsRepositoryProvider).createHabit({
        'name': _nameCtrl.text.trim(),
        'emoji': _selectedEmoji,
        'type': _selectedType,
        // omit optional fields entirely when empty — Zod .optional() rejects explicit null
        if (_costCtrl.text.isNotEmpty && double.tryParse(_costCtrl.text) != null)
          'costPerUnit': double.parse(_costCtrl.text),
        if (_targetCtrl.text.isNotEmpty && double.tryParse(_targetCtrl.text) != null)
          'targetAmount': double.parse(_targetCtrl.text),
        if (_unitCtrl.text.isNotEmpty) 'unit': _unitCtrl.text.trim(),
      });

      ref.invalidate(habitsProvider);
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('New Habit')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Habit type selector
              Text('What type?', style: Theme.of(context).textTheme.headlineSmall)
                  .animate().fadeIn(),
              const SizedBox(height: 12),
              Row(
                children: _types.map((t) {
                  final isSelected = _selectedType == t.$1;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = t.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? t.$5.withValues(alpha: 0.15) : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? t.$5 : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(t.$2, style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 4),
                            Text(
                              t.$3,
                              style: TextStyle(
                                color: isSelected ? t.$5 : AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ).animate(delay: 100.ms).fadeIn(),

              const SizedBox(height: 28),

              // Habit name
              Text('Habit name', style: Theme.of(context).textTheme.headlineSmall)
                  .animate(delay: 150.ms).fadeIn(),
              const SizedBox(height: 12),
              AppTextField(
                controller: _nameCtrl,
                label: 'e.g. No cigarettes, Less alcohol',
                validator: (v) => (v != null && v.isNotEmpty) ? null : 'Enter a name',
              ).animate(delay: 200.ms).fadeIn(),

              const SizedBox(height: 24),

              // Emoji picker
              Text('Choose emoji', style: Theme.of(context).textTheme.headlineSmall)
                  .animate(delay: 250.ms).fadeIn(),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _emojis.map((e) => GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = e),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _selectedEmoji == e ? AppColors.orange.withValues(alpha: 0.2) : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedEmoji == e ? AppColors.orange : AppColors.border,
                      ),
                    ),
                    child: Center(child: Text(e, style: const TextStyle(fontSize: 24))),
                  ),
                )).toList(),
              ).animate(delay: 300.ms).fadeIn(),

              // Optional fields for REDUCE type
              if (_selectedType == 'REDUCE') ...[
                const SizedBox(height: 24),
                Text('Tracking (optional)', style: Theme.of(context).textTheme.headlineSmall)
                    .animate().fadeIn(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _targetCtrl,
                        label: 'Daily target',
                        hint: 'e.g. 5',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _unitCtrl,
                        label: 'Unit',
                        hint: 'e.g. cigarettes',
                      ),
                    ),
                  ],
                ).animate().fadeIn(),
              ],

              // Cost tracking
              const SizedBox(height: 24),
              Text('Cost per unit (optional)', style: Theme.of(context).textTheme.headlineSmall)
                  .animate(delay: 350.ms).fadeIn(),
              const SizedBox(height: 8),
              const Text(
                'Set this to track money saved automatically',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _costCtrl,
                label: 'Cost (\$)',
                hint: 'e.g. 0.50',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ).animate(delay: 400.ms).fadeIn(),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: AppColors.red)),
              ],

              const SizedBox(height: 32),

              AppButton(
                label: 'Create Habit',
                onPressed: _submit,
                isLoading: _isLoading,
              ).animate(delay: 450.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
