import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_gradients.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../utils/app_assets.dart';
import '../utils/responsive.dart';
import 'app_illustration.dart';
import 'star_rating.dart';

/// Kartu skor akhir: ilustrasi sesuai skor, nama pengguna, cincin skor
/// animasi (angka naik), bintang, dan pesan. Permukaannya bergradien lembut.
class ScoreCard extends StatelessWidget {
  const ScoreCard({
    super.key,
    required this.userName,
    required this.score,
    required this.total,
    required this.message,
    required this.illustrationAsset,
  });

  final String userName;
  final int score;
  final int total;

  /// Pesan sesuai skor (mis. "Luar biasa!").
  final String message;

  /// Ilustrasi sesuai rentang skor (lihat `ScoreFeedback`).
  final String illustrationAsset;

  /// 3 bintang untuk >= 80%, 2 untuk >= 50%, 1 untuk > 0%, selain itu 0.
  static int starsFor(double fraction) {
    if (fraction >= 0.8) return 3;
    if (fraction >= 0.5) return 2;
    if (fraction > 0) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final padding = Responsive.cardPadding(MediaQuery.sizeOf(context).width);
    final fraction = total == 0 ? 0.0 : score / total;

    return SizedBox(
      width: double.infinity,
      child: Card(
        // clipBehavior: konfeti dan gradien terpotong rapi mengikuti sudut kartu.
        clipBehavior: Clip.antiAlias,
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: AppGradients.surface(scheme)),
          child: Stack(
            children: [
              // Konfeti hanya muncul untuk skor tinggi agar terasa spesial.
              if (fraction >= 0.8)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: SvgPicture.asset(
                      AppAssets.confetti,
                      fit: BoxFit.fitWidth,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIllustration(
                      asset: illustrationAsset,
                      widthFactor: 0.7,
                      maxHeight: 170,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Hasil Kuis',
                      style: textTheme.displaySmall?.copyWith(
                        fontSize: 30,
                        color: scheme.primary,
                      ),
                    ),
                    Text(
                      userName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _ScoreRing(score: score, total: total),
                    const SizedBox(height: AppSpacing.lg),
                    StarRating(filled: starsFor(fraction)),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cincin persentase dengan skor di tengahnya. Angka dan busur naik bersama.
class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score, required this.total});

  final int score;
  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final quiz = context.quizColors;
    final textTheme = Theme.of(context).textTheme;

    final fraction = total == 0 ? 0.0 : score / total;
    // Warna cincin: hijau (bagus), primer (cukup), merah (rendah).
    final ringColor = fraction >= 0.7
        ? quiz.correct
        : fraction >= 0.4
        ? scheme.primary
        : quiz.wrong;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth * 0.55, 200.0);

        return SizedBox(
          width: size,
          child: AspectRatio(
            aspectRatio: 1,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: fraction),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                // Angka dihitung dari nilai animasi: naik dari 0 hingga skor.
                final shownScore = (value * total).round();
                final shownPercent = (value * 100).round();

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: value,
                      strokeWidth: size * 0.09,
                      strokeCap: StrokeCap.round,
                      color: ringColor,
                      backgroundColor: scheme.primaryContainer.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(size * 0.2),
                        // FittedBox: teks mengecil otomatis, tidak pernah overflow.
                        child: FittedBox(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$shownScore/$total',
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '$shownPercent%',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
