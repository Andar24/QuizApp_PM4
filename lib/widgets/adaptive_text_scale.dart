import 'package:flutter/widgets.dart';

import '../utils/responsive.dart';

/// Memperbesar teks secara otomatis di layar lebar (tablet/web), dikalikan
/// dengan pengaturan ukuran font sistem milik pengguna.
///
/// Dipasang sekali di `MaterialApp.builder`, jadi berlaku untuk semua halaman
/// dan dialog tanpa mengubah satu per satu.
class AdaptiveTextScale extends StatelessWidget {
  const AdaptiveTextScale({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final factor = Responsive.textScaleFor(mediaQuery.size.width);
    if (factor == 1.0) return child;

    // Skala teks pengguna dipertahankan lalu dikalikan faktor layar.
    final userScale = mediaQuery.textScaler.scale(14) / 14;

    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: TextScaler.linear(userScale * factor),
      ),
      child: child,
    );
  }
}
