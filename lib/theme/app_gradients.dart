import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Gradien lembut yang semuanya diturunkan dari ColorScheme, jadi otomatis
/// menyesuaikan light/dark dan tidak ada warna yang di-hardcode di halaman.
class AppGradients {
  const AppGradients._();

  /// Gradien tombol utama: dari sedikit lebih terang ke sedikit lebih gelap
  /// dengan pergeseran rona tipis, jadi tetap satu keluarga warna primer.
  static LinearGradient primary(ColorScheme scheme) {
    final hsl = HSLColor.fromColor(scheme.primary);
    Color shade(double lightness, double hue) => hsl
        .withLightness((hsl.lightness + lightness).clamp(0.0, 1.0))
        .withHue((hsl.hue + hue) % 360)
        .toColor();

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [shade(0.05, -8), shade(-0.07, 12)],
    );
  }

  /// Latar halaman: permukaan menuju lavender sangat tipis di bagian bawah.
  static LinearGradient background(ColorScheme scheme) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        scheme.surface,
        Color.lerp(scheme.surface, scheme.primaryContainer, 0.4)!,
      ],
    );
  }

  /// Permukaan kartu berlapis (kartu menuju rona primer container).
  static LinearGradient surface(ColorScheme scheme) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        scheme.card,
        Color.lerp(scheme.card, scheme.primaryContainer, 0.55)!,
      ],
    );
  }
}
