import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import 'stat_tile.dart';

/// Dua kotak statistik tambahan di halaman hasil: streak terbaik dan
/// jumlah hint yang dipakai.
class ResultBonusRow extends StatelessWidget {
  const ResultBonusRow({
    super.key,
    required this.bestStreak,
    required this.hintsUsed,
  });

  final int bestStreak;
  final int hintsUsed;

  @override
  Widget build(BuildContext context) {
    final quizColors = context.quizColors;
    final scheme = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StatTile(
              icon: Icons.local_fire_department_rounded,
              value: bestStreak,
              label: 'Streak terbaik',
              color: quizColors.accent,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: StatTile(
              icon: Icons.lightbulb_outline_rounded,
              value: hintsUsed,
              label: 'Hint dipakai',
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
