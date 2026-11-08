import 'package:flutter/material.dart';

/// Menyimpan ThemeMode (light/dark) di state management.
/// Karena provider ini berada di atas MaterialApp, pilihan tema tidak hilang
/// saat layar dirotasi maupun saat pindah halaman.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  /// Dipanggil oleh tombol toggle di UI.
  void toggleTheme() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
