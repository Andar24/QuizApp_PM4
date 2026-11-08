import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../utils/app_assets.dart';
import 'svg_icon.dart';

/// Deretan bintang penilaian. Bintang terisi muncul bergantian dengan efek
/// membesar; bintang kosong berwarna abu lembut dari tema.
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.filled,
    this.total = 3,
    this.starSize = 32,
  });

  /// Jumlah bintang yang terisi (0..[total]).
  final int filled;
  final int total;
  final double starSize;

  @override
  Widget build(BuildContext context) {
    final emptyColor = Theme.of(context).colorScheme.outlineVariant
        .withValues(alpha: 0.7);

    return Semantics(
      label: '$filled dari $total bintang',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < total; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: i < filled
                  ? TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      // Bintang ke-n muncul sedikit lebih lambat.
                      duration: Duration(milliseconds: 350 + i * 150),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) =>
                          Transform.scale(scale: value, child: child),
                      child: SvgIcon(AppAssets.star, size: starSize),
                    )
                  : SvgIcon(AppAssets.star, size: starSize, color: emptyColor),
            ),
        ],
      ),
    );
  }
}
