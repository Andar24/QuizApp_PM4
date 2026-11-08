import 'package:flutter/widgets.dart';

/// Satu-satunya tempat aturan responsive/adaptive, supaya semua halaman
/// konsisten dan mudah dijelaskan.
///
/// Ringkasannya:
/// * Ponsel portrait & tablet portrait -> 1 kolom, lebar konten dibatasi.
/// * Landscape (ponsel/tablet) & web lebar -> 2 kolom.
/// * Layar lebar -> teks sedikit diperbesar agar nyaman dibaca.
class Responsive {
  const Responsive._();

  /// Lebar minimum (px logis) agar layout dua kolom dipakai.
  static const double twoColumnMinWidth = 720;

  /// Lebar maksimum konten satu kolom / dua kolom (dipusatkan di layar).
  static const double singleColumnMaxWidth = 640;
  static const double twoColumnMaxWidth = 1000;

  /// Dua kolom dipakai jika layar cukup lebar DAN lebih lebar daripada tinggi.
  /// Tablet portrait (820x1180) tetap satu kolom karena dua kolom akan sempit.
  ///
  /// Memakai ukuran WINDOW (MediaQuery.size), bukan ukuran area body, agar
  /// layout tidak berpindah-pindah saat keyboard muncul.
  static bool useTwoColumns(Size screenSize) {
    return screenSize.width >= twoColumnMinWidth &&
        screenSize.width > screenSize.height * 1.1;
  }

  /// Padding horizontal halaman: 5% lebar, dibatasi 16 - 32.
  static double pagePadding(double width) => (width * 0.05).clamp(16.0, 32.0);

  /// Padding di dalam kartu: 5% lebar layar, dibatasi 16 - 28.
  static double cardPadding(double width) => (width * 0.05).clamp(16.0, 28.0);

  /// Faktor pembesaran teks berdasarkan lebar layar (tablet & web).
  static double textScaleFor(double width) {
    if (width >= 1200) return 1.2;
    if (width >= 840) return 1.1;
    return 1.0;
  }
}
