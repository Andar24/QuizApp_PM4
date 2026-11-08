import 'package:flutter/material.dart';

import '../utils/app_assets.dart';
import 'svg_icon.dart';

/// Tombol hint di AppBar: ikon bohlam dengan lencana jumlah hint yang
/// tersedia. Ikon diredupkan saat tidak ada hint, tetapi tetap bisa ditekan
/// agar pengguna mendapat penjelasan cara memperolehnya.
class HintButton extends StatelessWidget {
  const HintButton({super.key, required this.available, required this.onPressed});

  /// Jumlah hint yang masih bisa dipakai.
  final int available;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Pakai hint ($available)',
      onPressed: onPressed,
      icon: Badge(
        isLabelVisible: available > 0,
        label: Text('$available'),
        child: Opacity(
          opacity: available > 0 ? 1 : 0.45,
          child: const SvgIcon(AppAssets.lightbulb, size: 26),
        ),
      ),
    );
  }
}
