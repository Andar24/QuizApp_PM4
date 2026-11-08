import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../theme/app_spacing.dart';

/// Tombol ganti tema light/dark. Dipakai di AppBar semua halaman.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    // select: hanya rebuild saat nilai isDark berubah.
    final isDark = context.select<ThemeProvider, bool>((p) => p.isDark);

    return IconButton(
      tooltip: isDark ? 'Mode terang' : 'Mode gelap',
      onPressed: context.read<ThemeProvider>().toggleTheme,
      icon: AnimatedSwitcher(
        duration: AppMotion.normal,
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey<bool>(isDark),
        ),
      ),
    );
  }
}
