import 'package:flutter/material.dart';

import '../theme/app_gradients.dart';
import '../theme/app_spacing.dart';

/// Jenis tampilan tombol: utama (gradien) atau sekunder (outline).
enum CustomButtonVariant { primary, secondary }

/// Tombol kustom yang dipakai di semua halaman (Mulai, Next, Previous,
/// Submit, Ulangi). Gaya (warna, radius, font) diambil dari tema,
/// jadi otomatis ikut light/dark mode.
///
/// Lebar tombol mengikuti parent: bungkus dengan `Expanded` di dalam Row,
/// atau taruh di Column dengan `CrossAxisAlignment.stretch`.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconAtEnd = false,
    this.variant = CustomButtonVariant.primary,
  });

  final String label;

  /// Jika null, tombol otomatis nonaktif (tampil abu-abu).
  final VoidCallback? onPressed;

  final IconData? icon;

  /// true -> ikon di kanan teks (cocok untuk tombol "Next").
  final bool iconAtEnd;

  final CustomButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final text = Text(label, textAlign: TextAlign.center);
    final iconAlignment = iconAtEnd ? IconAlignment.end : IconAlignment.start;

    if (variant == CustomButtonVariant.secondary) {
      return icon == null
          ? OutlinedButton(onPressed: onPressed, child: text)
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              iconAlignment: iconAlignment,
              label: text,
            );
    }

    final button = icon == null
        ? FilledButton(onPressed: onPressed, child: text)
        : FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            iconAlignment: iconAlignment,
            label: text,
          );

    // Tombol nonaktif memakai gaya standar tema (tanpa gradien).
    if (onPressed == null) return button;

    final scheme = Theme.of(context).colorScheme;
    final transparentStyle = FilledButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      foregroundColor: scheme.onPrimary,
    );

    // Gradien digambar oleh DecoratedBox; tombol dibuat transparan di atasnya
    // sehingga efek tekan (ripple) tetap berfungsi.
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.primary(scheme),
        borderRadius: AppRadius.mdAll,
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: icon == null
          ? FilledButton(
              style: transparentStyle,
              onPressed: onPressed,
              child: text,
            )
          : FilledButton.icon(
              style: transparentStyle,
              onPressed: onPressed,
              icon: Icon(icon),
              iconAlignment: iconAlignment,
              label: text,
            ),
    );
  }
}
