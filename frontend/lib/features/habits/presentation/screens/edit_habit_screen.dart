import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/habits_repository.dart';

class EditHabitScreen extends ConsumerStatefulWidget {
  final Habit habit;
  const EditHabitScreen({super.key, required this.habit});

  @override
  ConsumerState<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends ConsumerState<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _unitCtrl;

  late String _selectedEmoji;
  bool _isLoading = false;
  String? _error;

  final _emojis = [
    '🎯', '🚬', '🍺', '☕', '🍕', '📱', '🎮', '💊',
    '🏋️', '📚', '🧘', '💤',
  ];

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _nameCtrl = TextEditingController(text: h.name);
    _costCtrl = TextEditingController(
        text: h.costPerUnit != null ? h.costPerUnit.toString() : '');
    _targetCtrl = TextEditingController(
        text: h.targetAmount != null ? h.targetAmount.toString() : '');
    _unitCtrl = TextEditingController(text: h.unit ?? '');
    _selectedEmoji = h.emoji;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _costCtrl.dispose();
    _targetCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'emoji': _selectedEmoji,
        // Omit optional fields entirely when empty (Zod rejects explicit null)
        if (_costCtrl.text.isNotEmpty &&
            double.tryParse(_costCtrl.text) != null)
          'costPerUnit': double.parse(_costCtrl.text),
        if (_targetCtrl.text.isNotEmpty &&
            double.tryParse(_targetCtrl.text) != null)
          'targetAmount': double.parse(_targetCtrl.text),
        if (_unitCtrl.text.isNotEmpty) 'unit': _unitCtrl.text.trim(),
      };

      await ref
          .read(habitsNotifierProvider.notifier)
          .updateHabit(widget.habit.id, data);

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
      appBar: AppBar(title: const Text('Edit Habit')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type badge (read-only)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _typeColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  widget.habit.type,
                  style: TextStyle(
                      color: _typeColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 4),
              const Text(
                'Habit type cannot be changed after creation.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ).animate().fadeIn(),

              const SizedBox(height: 24),

              // Habit name
              Text('Habit name',
                      style: Theme.of(context).textTheme.headlineSmall)
                  .animate(delay: 50.ms)
                  .fadeIn(),
              const SizedBox(height: 12),
              AppTextField(
                controller: _nameCtrl,
                label: 'e.g. No cigarettes',
                validator: (v) =>
                    (v != null && v.isNotEmpty) ? null : 'Enter a name',
              ).animate(delay: 100.ms).fadeIn(),

              const SizedBox(height: 24),

              // Emoji picker
              Text('Choose emoji',
                      style: Theme.of(context).textTheme.headlineSmall)
                  .animate(delay: 150.ms)
                  .fadeIn(),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _emojis
                    .map((e) => GestureDetector(
                          onTap: () => setState(() => _selectedEmoji = e),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _selectedEmoji == e
                                  ? AppColors.orange.withValues(alpha: 0.2)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedEmoji == e
                                    ? AppColors.orange
                                    : AppColors.border,
                              ),
                            ),
                            child: Center(
                                child: Text(e,
                                    style: const TextStyle(fontSize: 24))),
                          ),
                        ))
                    .toList(),
              ).animate(delay: 200.ms).fadeIn(),

              // Optional fields for REDUCE type
              if (widget.habit.type == 'REDUCE') ...[
                const SizedBox(height: 24),
                Text('Tracking (optional)',
                        style: Theme.of(context).textTheme.headlineSmall)
                    .animate(delay: 250.ms)
                    .fadeIn(),
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
                ).animate(delay: 300.ms).fadeIn(),
              ],

              // Cost tracking
              const SizedBox(height: 24),
              Text('Cost per unit (optional)',
                      style: Theme.of(context).textTheme.headlineSmall)
                  .animate(delay: 300.ms)
                  .fadeIn(),
              const SizedBox(height: 8),
              const Text(
                'Used to track money saved automatically.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _costCtrl,
                label: 'Cost (\$)',
                hint: 'e.g. 0.50',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ).animate(delay: 350.ms).fadeIn(),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!,
                    style: const TextStyle(color: AppColors.red)),
              ],

              const SizedBox(height: 32),

              AppButton(
                label: 'Save Changes',
                onPressed: _submit,
                isLoading: _isLoading,
              )
                  .animate(delay: 400.ms)
                  .slideY(begin: 0.2, duration: 400.ms)
                  .fadeIn(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
