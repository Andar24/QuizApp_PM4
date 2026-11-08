import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ikon SVG kecil dari aset. Ukuran default mengikuti IconTheme sekitarnya,
/// sama seperti widget `Icon`. Jika [color] diisi, ikon diwarnai satu warna.
class SvgIcon extends StatelessWidget {
  const SvgIcon(this.asset, {super.key, this.size, this.color});

  final String asset;
  final double? size;

  /// null = pakai warna asli SVG.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconSize = size ?? IconTheme.of(context).size ?? 24;

    return SvgPicture.asset(
      asset,
      width: iconSize,
      height: iconSize,
      // Ikon hanya dekorasi, pembaca layar tidak perlu membacanya.
      excludeFromSemantics: true,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
