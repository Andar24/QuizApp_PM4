import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Status satu nomor soal pada grid.
enum QuestionDotStatus { unanswered, correct, wrong, timedOut }

/// Grid nomor soal (1..n) berwarna sesuai status; ketuk untuk lompat soal.
///
/// Stateless: data status dikirim dari luar, jadi widget ini bisa dipakai
/// ulang (mis. di bottom sheet) tanpa tahu tentang provider.
class QuestionGrid extends StatelessWidget {
  const QuestionGrid({
    super.key,
    required this.statuses,
    required this.currentIndex,
    required this.onSelect,
  });

  final List<QuestionDotStatus> statuses;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    // Ukuran mengikuti skala font sistem agar angka tidak terpotong.
    final size = MediaQuery.textScalerOf(context).scale(44);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (var i = 0; i < statuses.length; i++)
              _QuestionDot(
                number: i + 1,
                size: size,
                status: statuses[i],
                isCurrent: i == currentIndex,
                onTap: () => onSelect(i),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const _Legend(),
      ],
    );
  }
}

/// Warna latar dan warna garis untuk satu status.
(Color, Color) _colorsFor(BuildContext context, QuestionDotStatus status) {
  final scheme = Theme.of(context).colorScheme;
  final quiz = context.quizColors;

  return switch (status) {
    QuestionDotStatus.correct => (quiz.correctContainer, quiz.correct),
    QuestionDotStatus.wrong => (quiz.wrongContainer, quiz.wrong),
    QuestionDotStatus.timedOut => (
      scheme.surfaceContainerHighest,
      scheme.outline,
    ),
    QuestionDotStatus.unanswered => (scheme.card, scheme.outlineVariant),
  };
}

String _label(QuestionDotStatus status) => switch (status) {
  QuestionDotStatus.correct => 'benar',
  QuestionDotStatus.wrong => 'salah',
  QuestionDotStatus.timedOut => 'waktu habis',
  QuestionDotStatus.unanswered => 'belum dijawab',
};

class _QuestionDot extends StatelessWidget {
  const _QuestionDot({
    required this.number,
    required this.size,
    required this.status,
    required this.isCurrent,
    required this.onTap,
  });

  final int number;
  final double size;
  final QuestionDotStatus status;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, border) = _colorsFor(context, status);

    return Semantics(
      button: true,
      selected: isCurrent,
      label: 'Soal $number, ${_label(status)}',
      excludeSemantics: true,
      child: Material(
        color: background,
        shape: CircleBorder(
          side: BorderSide(
            // Soal yang sedang tampil diberi garis tebal berwarna primer.
            color: isCurrent ? scheme.primary : border,
            width: isCurrent ? 3 : 1.5,
          ),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Text(
                '$number',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      children: [
        for (final status in QuestionDotStatus.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSpacing.lg,
                height: AppSpacing.lg,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _colorsFor(context, status).$1,
                  border: Border.all(
                    color: _colorsFor(context, status).$2,
                    width: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _legendText(status),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
      ],
    );
  }

  static String _legendText(QuestionDotStatus status) => switch (status) {
    QuestionDotStatus.correct => 'Benar',
    QuestionDotStatus.wrong => 'Salah',
    QuestionDotStatus.timedOut => 'Waktu habis',
    QuestionDotStatus.unanswered => 'Belum',
  };
}

/// Menampilkan grid nomor soal dalam bottom sheet. Mengembalikan indeks soal
/// yang dipilih (0-based), atau null jika sheet ditutup tanpa memilih.
Future<int?> showQuestionGridSheet(
  BuildContext context, {
  required List<QuestionDotStatus> statuses,
  required int currentIndex,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final textTheme = Theme.of(sheetContext).textTheme;

      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Daftar Soal',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Ketuk nomor untuk melompat ke soal tersebut.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              QuestionGrid(
                statuses: statuses,
                currentIndex: currentIndex,
                onSelect: (index) => Navigator.of(sheetContext).pop(index),
              ),
            ],
          ),
        ),
      );
    },
  );
}
