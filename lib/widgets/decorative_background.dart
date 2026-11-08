import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_gradients.dart';
import '../theme/app_theme.dart';

/// Latar halaman: gradien lembut + dua blob cahaya (ungu dan amber) yang
/// ukurannya mengikuti layar. Ringan (tanpa gambar), warna dari tema.
///
/// Pakai di luar Scaffold: `DecorativeBackground(child: Scaffold(backgroundColor: Colors.transparent, ...))`
class DecorativeBackground extends StatelessWidget {
  const DecorativeBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = context.quizColors.accent;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppGradients.background(scheme),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            // RepaintBoundary: blob tidak digambar ulang saat konten berubah.
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _BlobPainter(primary: scheme.primary, accent: accent),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _BlobPainter extends CustomPainter {
  const _BlobPainter({required this.primary, required this.accent});

  final Color primary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final base = math.min(size.width, size.height);

    void blob(Offset center, double radius, Color color) {
      final paint = Paint()
        ..shader = RadialGradient(colors: [color, color.withValues(alpha: 0)])
            .createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }

    // Posisi dan radius relatif terhadap ukuran layar.
    blob(
      Offset(size.width * 0.92, size.height * 0.04),
      base * 0.75,
      primary.withValues(alpha: 0.15),
    );
    blob(
      Offset(size.width * 0.04, size.height * 0.96),
      base * 0.65,
      accent.withValues(alpha: 0.16),
    );
  }

  @override
  bool shouldRepaint(_BlobPainter old) =>
      old.primary != primary || old.accent != accent;
}
