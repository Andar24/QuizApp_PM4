import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Lencana streak: jumlah jawaban benar beruntun, mis. "x3".
/// Muncul dengan animasi membesar dan angkanya "membal" tiap bertambah.
class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final accent = context.quizColors.accent;

    return Semantics(
      label: '$streak jawaban benar beruntun',
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        // key = streak -> animasi diulang setiap streak bertambah.
        key: ValueKey<int>(streak),
        tween: Tween<double>(begin: 0.8, end: 1),
        duration: AppMotion.normal,
        curve: Curves.elasticOut,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.18),
            borderRadius: AppRadius.pillAll,
            border: Border.all(color: accent.withValues(alpha: 0.7)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_fire_department_rounded, size: 18, color: accent),
                const SizedBox(width: AppSpacing.xs / 2),
                Text(
                  'x$streak',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
