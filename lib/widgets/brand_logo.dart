import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_spacing.dart';
import '../utils/app_assets.dart';

/// Logo aplikasi: lambang SVG + tulisan "QuizKu" dengan font brand (Pacifico).
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 44, this.showWordmark = true});

  /// Tinggi lambang (px logis). Tulisan mengikuti proporsinya.
  final double size;

  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final mark = SvgPicture.asset(
      AppAssets.logo,
      width: size,
      height: size,
      excludeFromSemantics: true,
    );
    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: AppSpacing.md),
        // Flexible + FittedBox: wordmark mengecil, tidak pernah overflow.
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'QuizKu',
              style: textTheme.displayMedium?.copyWith(
                fontSize: size * 0.95,
                height: 1.25,
                color: scheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
