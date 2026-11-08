import 'package:flutter/material.dart';

/// Route dengan animasi halus: halaman baru memudar masuk sambil sedikit
/// bergeser dari kanan. Dipakai untuk semua perpindahan halaman.
///
/// Contoh: `Navigator.of(context).push(fadeSlideRoute(const QuizScreen()))`
Route<T> fadeSlideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // drive(): menerapkan kurva tanpa perlu membuat/dispose controller.
      final eased = animation.drive(CurveTween(curve: Curves.easeOutCubic));
      final slide = eased.drive(
        Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero),
      );

      return FadeTransition(
        opacity: eased,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
