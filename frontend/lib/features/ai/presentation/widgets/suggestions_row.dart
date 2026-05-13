import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/ai_repository.dart';

class SuggestionsRow extends ConsumerWidget {
  final Function(String) onSuggestion;

  const SuggestionsRow({super.key, required this.onSuggestion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(aiSuggestionsProvider);

    return suggestionsAsync.when(
      data: (suggestions) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _SuggestionChip(
                label: s,
                onTap: () => onSuggestion(s),
              ),
            )).toList(),
          ),
        ),
      ),
      loading: () => const SizedBox(height: 48),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.purple.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.purple,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
