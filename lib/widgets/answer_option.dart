import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Status tampilan satu opsi jawaban.
enum AnswerStatus {
  /// Belum dipilih (atau bukan jawaban penting).
  idle,

  /// Dipilih pengguna dan benar (hijau).
  correct,

  /// Dipilih pengguna tetapi salah (merah).
  wrong,

  /// Jawaban benar yang ditunjukkan setelah pengguna salah memilih
  /// (atau saat waktu soal habis).
  revealed,

  /// Pilihan salah yang dicoret oleh hint (tidak bisa dipilih).
  /// Sengaja diletakkan paling akhir agar urutan nilai enum lain tidak berubah.
  eliminated;

  /// Menentukan status opsi [optionIndex] dari jawaban pengguna.
  /// Dipakai agar logika warna tidak ditulis ulang di setiap halaman.
  static AnswerStatus resolve({
    required int optionIndex,
    required int correctIndex,
    required int? selectedIndex,
    bool eliminated = false,
  }) {
    if (eliminated) return AnswerStatus.eliminated;
    if (selectedIndex == null) return AnswerStatus.idle;
    if (optionIndex == selectedIndex) {
      return optionIndex == correctIndex
          ? AnswerStatus.correct
          : AnswerStatus.wrong;
    }
    if (optionIndex == correctIndex) return AnswerStatus.revealed;
    return AnswerStatus.idle;
  }
}

/// Satu baris pilihan jawaban (A/B/C/D) dengan feedback warna benar/salah.
///
/// Stateless: tampilannya sepenuhnya ditentukan oleh [status] dari provider.
/// Perubahan warna dan bayangan dianimasikan lewat AnimatedContainer.
class AnswerOption extends StatelessWidget {
  const AnswerOption({
    super.key,
    required this.label,
    required this.text,
    required this.status,
    this.onTap,
  });

  /// Huruf pilihan, mis. "A".
  final String label;

  final String text;

  final AnswerStatus status;

  /// null = tidak bisa ditekan (soal sudah dijawab).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final quiz = context.quizColors;
    final textTheme = Theme.of(context).textTheme;

    // Warna ditentukan berdasarkan status; semuanya dari tema (light/dark).
    final (
      background,
      border,
      labelBackground,
      labelForeground,
      icon,
    ) = switch (status) {
      AnswerStatus.idle => (
        scheme.card,
        scheme.outlineVariant,
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        null,
      ),
      AnswerStatus.correct => (
        quiz.correctContainer,
        quiz.correct,
        quiz.correct,
        quiz.onCorrect,
        Icons.check_circle_rounded,
      ),
      AnswerStatus.wrong => (
        quiz.wrongContainer,
        quiz.wrong,
        quiz.wrong,
        quiz.onWrong,
        Icons.cancel_rounded,
      ),
      AnswerStatus.revealed => (
        quiz.correctContainer,
        quiz.correct,
        quiz.correct,
        quiz.onCorrect,
        Icons.check_circle_outline_rounded,
      ),
      AnswerStatus.eliminated => (
        scheme.card,
        scheme.outlineVariant,
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
        Icons.block_rounded,
      ),
    };

    final isEliminated = status == AnswerStatus.eliminated;
    final iconColor = switch (status) {
      AnswerStatus.wrong => quiz.wrong,
      AnswerStatus.eliminated => scheme.onSurfaceVariant,
      _ => quiz.correct,
    };

    // Opsi lain diredupkan setelah soal terjawab.
    final dimmed = onTap == null && status == AnswerStatus.idle;
    // Bayangan tipis hanya pada opsi yang masih bisa dipilih.
    final raised = status == AnswerStatus.idle && !dimmed;

    // Ukuran lingkaran huruf mengikuti skala font sistem agar tidak overflow.
    final labelSize = MediaQuery.textScalerOf(context).scale(34);

    return AnimatedOpacity(
      duration: AppMotion.normal,
      opacity: isEliminated ? 0.45 : (dimmed ? 0.6 : 1),
      child: AnimatedContainer(
        duration: AppMotion.normal,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: raised ? 0.10 : 0),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: isEliminated ? null : onTap,
            borderRadius: AppRadius.mdAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg - 2,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: AppMotion.normal,
                    width: labelSize,
                    height: labelSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: labelBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      label,
                      style: textTheme.titleSmall?.copyWith(
                        color: labelForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Expanded: teks panjang membungkus ke baris baru.
                  Expanded(
                    child: Text(
                      text,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        // Pilihan yang dicoret hint diberi garis tengah.
                        decoration: isEliminated
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Ruang ikon selalu dicadangkan agar teks tidak "melompat".
                  AnimatedOpacity(
                    duration: AppMotion.normal,
                    opacity: icon == null ? 0 : 1,
                    child: Icon(
                      icon ?? Icons.check_circle_rounded,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
