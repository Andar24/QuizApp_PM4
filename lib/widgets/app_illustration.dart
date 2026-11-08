import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_spacing.dart';

/// Ilustrasi SVG berukuran dinamis dengan animasi masuk (fade + naik halus).
///
/// Lebar = [widthFactor] x lebar tersedia, dibatasi [maxWidth] dan tinggi
/// maksimum [maxHeight] (agar tidak memakan layar saat landscape).
class AppIllustration extends StatelessWidget {
  const AppIllustration({
    super.key,
    required this.asset,
    this.aspectRatio = 4 / 3,
    this.widthFactor = 0.8,
    this.maxWidth = 360,
    this.maxHeight = 240,
    this.animate = true,
    this.semanticLabel,
  });

  final String asset;

  /// Lebar : tinggi dari file SVG (viewBox).
  final double aspectRatio;

  final double widthFactor;
  final double maxWidth;
  final double maxHeight;

  /// false = tampil langsung tanpa animasi masuk.
  final bool animate;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final width = math.min(
          math.min(available * widthFactor, maxWidth),
          maxHeight * aspectRatio,
        );

        final picture = SizedBox(
          width: width,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: SvgPicture.asset(
              asset,
              fit: BoxFit.contain,
              semanticsLabel: semanticLabel,
              excludeFromSemantics: semanticLabel == null,
            ),
          ),
        );

        if (!animate) return picture;

        // Micro-animation: muncul perlahan sambil naik sedikit.
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: AppMotion.slow,
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: FractionalTranslation(
              translation: Offset(0, (1 - value) * 0.08),
              child: child,
            ),
          ),
          child: picture,
        );
      },
    );
  }
}
