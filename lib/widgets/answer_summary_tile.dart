import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Satu baris ringkasan di halaman hasil: soal, jawaban pengguna,
/// jawaban benar, dan status benar/salah.
class AnswerSummaryTile extends StatelessWidget {
  const AnswerSummaryTile({
    super.key,
    required this.number,
    required this.question,
    required this.isCorrect,
    required this.correctAnswer,
    this.selectedAnswer,
    this.explanation,
  });

  final int number;
  final String question;
  final bool isCorrect;
  final String correctAnswer;

  /// null = soal tidak dijawab.
  final String? selectedAnswer;

  final String? explanation;

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
            isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: accent,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number. $question',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _AnswerLine(
                  label: 'Jawabanmu',
                  value: selectedAnswer ?? 'Tidak dijawab',
                  color: accent,
                ),
                if (!isCorrect) ...[
                  const SizedBox(height: AppSpacing.xs / 2),
                  _AnswerLine(
                    label: 'Jawaban benar',
                    value: correctAnswer,
                    color: quiz.correct,
                  ),
                ],
                if (explanation != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    explanation!,
                    style: textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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

class _AnswerLine extends StatelessWidget {
  const _AnswerLine({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
