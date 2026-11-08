import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../utils/app_assets.dart';
import 'svg_icon.dart';

/// Label sisa waktu menjawab, mis. "27s". Berubah merah saat waktu hampir
/// habis dan abu-abu saat soal sudah dijawab / waktunya habis.
class TimerChip extends StatelessWidget {
  const TimerChip({
    super.key,
    required this.secondsLeft,
    this.running = true,
    this.warningAt = 10,
  });

  /// Sisa detik.
  final int secondsLeft;

  /// false = timer berhenti (soal sudah dijawab atau waktu habis).
  final bool running;

  /// Sisa detik di bawah/sama dengan nilai ini memunculkan warna peringatan.
  final int warningAt;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final quiz = context.quizColors;

    final isWarning = running && secondsLeft <= warningAt;
    final color = !running
        ? scheme.onSurfaceVariant
        : (isWarning ? quiz.wrong : scheme.primary);

    return Semantics(
      label: 'Sisa waktu $secondsLeft detik',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: AppMotion.normal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: AppRadius.pillAll,
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SvgIcon(AppAssets.timer, size: 16),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${secondsLeft}s',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                // Angka dengan lebar sama agar teks tidak "bergoyang".
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
