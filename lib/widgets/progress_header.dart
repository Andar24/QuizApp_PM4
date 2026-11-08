import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../utils/app_assets.dart';
import 'streak_badge.dart';
import 'svg_icon.dart';
import 'timer_chip.dart';

/// Header kuis: ikon target, teks "Soal 3/10", jumlah terjawab, dan
/// progress bar animasi.
class ProgressHeader extends StatelessWidget {
  const ProgressHeader({
    super.key,
    required this.current,
    required this.total,
    required this.answered,
    this.secondsLeft,
    this.timerRunning = true,
    this.streak = 0,
  });

  /// Nomor soal saat ini (mulai dari 1).
  final int current;

  final int total;

  /// Jumlah soal yang sudah dijawab.
  final int answered;

  /// Sisa waktu soal ini (detik). null = chip timer tidak ditampilkan.
  final int? secondsLeft;

  /// false = timer berhenti (soal sudah dijawab atau waktu habis).
  final bool timerRunning;

  /// Jawaban benar beruntun; lencana tampil jika >= [minStreakToShow].
  final int streak;

  static const int minStreakToShow = 2;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const SvgIcon(AppAssets.target, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Soal $current/$total',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$answered terjawab',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // Baris bawah: chip timer, progress bar (mengisi sisa lebar), streak.
        Row(
          children: [
            if (secondsLeft != null) ...[
              TimerChip(secondsLeft: secondsLeft!, running: timerRunning),
              const SizedBox(width: AppSpacing.md),
            ],
            // TweenAnimationBuilder: bar bergerak halus saat nilai berubah.
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: current / total),
                duration: AppMotion.slow,
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return ClipRRect(
                    borderRadius: AppRadius.pillAll,
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 10,
                      backgroundColor: scheme.primaryContainer.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  );
                },
              ),
            ),
            if (streak >= minStreakToShow) ...[
              const SizedBox(width: AppSpacing.md),
              StreakBadge(streak: streak),
            ],
          ],
        ),
      ],
    );
  }
}
