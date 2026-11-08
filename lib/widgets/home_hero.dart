import 'package:flutter/material.dart';

import '../providers/quiz_provider.dart';
import '../theme/app_spacing.dart';
import '../utils/app_assets.dart';
import 'app_illustration.dart';
import 'brand_logo.dart';
import 'info_chip.dart';
import 'svg_icon.dart';

/// Bagian hero di Home: logo, ilustrasi, subjudul, dan info singkat kuis.
///
/// Hierarki: judul brand (Pacifico) -> ilustrasi -> subjudul -> chip info.
class HomeHero extends StatelessWidget {
  const HomeHero({super.key, required this.total, this.isWide = false});

  /// Jumlah soal, ditampilkan pada chip.
  final int total;

  /// true pada layout dua kolom (ilustrasi sedikit lebih lebar).
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    // Ukuran logo mengikuti lebar layar (dibatasi 40 - 56).
    final logoSize = (MediaQuery.sizeOf(context).width * 0.1).clamp(40.0, 56.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandLogo(size: logoSize),
        const SizedBox(height: AppSpacing.lg),
        AppIllustration(
          asset: AppAssets.heroQuiz,
          widthFactor: isWide ? 0.9 : 0.85,
          maxWidth: 380,
          maxHeight: 230,
          semanticLabel: 'Ilustrasi lembar soal kuis',
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Uji pemahamanmu tentang dasar Flutter & Dart',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            InfoChip(
              leading: const SvgIcon(AppAssets.clipboard),
              label: '$total soal',
            ),
            const InfoChip(
              leading: Icon(Icons.checklist_rounded),
              label: '4 pilihan',
            ),
            const InfoChip(
              leading: SvgIcon(AppAssets.timer),
              label: '${QuizProvider.secondsPerQuestion} detik/soal',
            ),
          ],
        ),
      ],
    );
  }
}
