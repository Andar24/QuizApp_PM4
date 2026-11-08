import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ikon SVG di dalam lingkaran berlatar warna tema.
///
/// Ukuran DINAMIS: [widthFactor] x lebar yang tersedia (LayoutBuilder),
/// dibatasi [maxSize] agar tidak terlalu besar di tablet/web.
///
/// Untuk tempat yang menghitung ukuran intrinsik (mis. ikon di AlertDialog),
/// LayoutBuilder tidak boleh dipakai: isi [size] secara eksplisit
/// (hitung dari MediaQuery agar tetap dinamis).
class SvgBadge extends StatelessWidget {
  const SvgBadge({
    super.key,
    required this.asset,
    this.widthFactor = 0.3,
    this.maxSize = 140,
    this.size,
    this.semanticLabel,
  });

  final String asset;

  /// Ukuran tetap (opsional). Jika diisi, [widthFactor] dan [maxSize] diabaikan.
  final double? size;

  /// Proporsi terhadap lebar yang tersedia (0.0 - 1.0).
  final double widthFactor;

  /// Batas ukuran maksimum.
  final double maxSize;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (size != null) return _buildBadge(context, size!);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Jika lebar tak terbatas, fallback ke lebar layar.
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        return _buildBadge(context, math.min(available * widthFactor, maxSize));
      },
    );
  }

  Widget _buildBadge(BuildContext context, double badgeSize) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: badgeSize,
      // AspectRatio menjaga bentuk tetap lingkaran sempurna.
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(badgeSize * 0.2),
            child: SvgPicture.asset(
              asset,
              fit: BoxFit.contain,
              semanticsLabel: semanticLabel,
              excludeFromSemantics: semanticLabel == null,
            ),
          ),
        ),
      ),
    );
  }
}
