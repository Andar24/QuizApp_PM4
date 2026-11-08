import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import 'stat_tile.dart';

/// Tiga kotak statistik hasil kuis: Benar, Salah, dan Tidak dijawab.
class ResultStatsRow extends StatelessWidget {
  const ResultStatsRow({
    super.key,
    required this.correct,
    required this.wrong,
    required this.unanswered,
  });

  final int correct;
  final int wrong;
  final int unanswered;

  @override
  Widget build(BuildContext context) {
    final quizColors = context.quizColors;
    final scheme = Theme.of(context).colorScheme;

    // IntrinsicHeight: ketiga kotak statistik sama tinggi.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StatTile(
              icon: Icons.check_circle_outline_rounded,
              value: correct,
              label: 'Benar',
              color: quizColors.correct,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: StatTile(
              icon: Icons.highlight_off_rounded,
              value: wrong,
              label: 'Salah',
              color: quizColors.wrong,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: StatTile(
              icon: Icons.remove_circle_outline_rounded,
              value: unanswered,
              label: 'Tidak dijawab',
              color: scheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
