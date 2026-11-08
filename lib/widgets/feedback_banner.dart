import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../utils/app_assets.dart';
import 'svg_icon.dart';

/// Banner feedback setelah menjawab: hijau jika benar, merah jika salah,
/// lengkap dengan jawaban yang benar dan penjelasan singkat (ikon bohlam).
class FeedbackBanner extends StatelessWidget {
  const FeedbackBanner({
    super.key,
    required this.isCorrect,
    required this.correctAnswer,
    this.explanation,
    this.timedOut = false,
  });

  final bool isCorrect;
  final String correctAnswer;
  final String? explanation;

  /// true jika waktu soal habis sebelum dijawab (dihitung salah).
  final bool timedOut;

  @override
  Widget build(BuildContext context) {
    final quiz = context.quizColors;
    final textTheme = Theme.of(context).textTheme;

    final accent = isCorrect ? quiz.correct : quiz.wrong;
    final background = isCorrect ? quiz.correctContainer : quiz.wrongContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg - 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: accent.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect
                ? Icons.check_circle_rounded
                : (timedOut ? Icons.timer_off_rounded : Icons.info_rounded),
            color: accent,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timedOut
                      ? 'Waktu habis!'
                      : (isCorrect ? 'Jawaban benar!' : 'Jawaban kurang tepat'),
                  style: textTheme.titleSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!isCorrect) ...[
                  const SizedBox(height: AppSpacing.xs / 2),
                  Text(
                    'Jawaban yang benar: $correctAnswer',
                    style: textTheme.bodySmall,
                  ),
                ],
                if (explanation != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SvgIcon(AppAssets.lightbulb, size: 18),
                      const SizedBox(width: AppSpacing.sm - 2),
                      Expanded(
                        child: Text(
                          explanation!,
                          style: textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
