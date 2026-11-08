import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../utils/app_assets.dart';
import '../utils/responsive.dart';
import 'svg_icon.dart';

/// Kartu yang menampilkan nomor dan teks pertanyaan.
class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key, required this.number, required this.text});

  /// Nomor soal (mulai dari 1).
  final int number;

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Padding dinamis mengikuti lebar layar.
    final padding = Responsive.cardPadding(MediaQuery.sizeOf(context).width);

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge nomor soal dengan ikon lembar soal.
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: AppRadius.pillAll,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SvgIcon(AppAssets.clipboard, size: 16),
                      const SizedBox(width: AppSpacing.sm - 2),
                      Flexible(
                        child: Text(
                          'Pertanyaan $number',
                          style: textTheme.labelMedium?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg - 2),
              Text(
                text,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
