import 'package:flutter/material.dart';

import 'app_spacing.dart';

/// Warna khusus kuis yang ikut berubah saat light/dark:
/// benar (hijau), salah (merah), dan satu aksen hangat (amber) untuk
/// dekorasi. Dipakai lewat `context.quizColors`.
@immutable
class QuizColors extends ThemeExtension<QuizColors> {
  const QuizColors({
    required this.correct,
    required this.onCorrect,
    required this.correctContainer,
    required this.wrong,
    required this.onWrong,
    required this.wrongContainer,
    required this.accent,
  });

  final Color correct;
  final Color onCorrect;
  final Color correctContainer;
  final Color wrong;
  final Color onWrong;
  final Color wrongContainer;

  /// Aksen hangat (amber) - satu-satunya warna dekoratif selain ungu primer.
  final Color accent;

  static const light = QuizColors(
    correct: Color(0xFF2E9E5B),
    onCorrect: Colors.white,
    correctContainer: Color(0xFFDDF6E7),
    wrong: Color(0xFFD64545),
    onWrong: Colors.white,
    wrongContainer: Color(0xFFFCE1E1),
    accent: Color(0xFFF4A93B),
  );

  static const dark = QuizColors(
    correct: Color(0xFF5FD38D),
    onCorrect: Color(0xFF062B16),
    correctContainer: Color(0xFF16382A),
    wrong: Color(0xFFFF8A8A),
    onWrong: Color(0xFF3A0808),
    wrongContainer: Color(0xFF412020),
    accent: Color(0xFFFFD27A),
  );

  @override
  QuizColors copyWith({
    Color? correct,
    Color? onCorrect,
    Color? correctContainer,
    Color? wrong,
    Color? onWrong,
    Color? wrongContainer,
    Color? accent,
  }) {
    return QuizColors(
      correct: correct ?? this.correct,
      onCorrect: onCorrect ?? this.onCorrect,
      correctContainer: correctContainer ?? this.correctContainer,
      wrong: wrong ?? this.wrong,
      onWrong: onWrong ?? this.onWrong,
      wrongContainer: wrongContainer ?? this.wrongContainer,
      accent: accent ?? this.accent,
    );
  }

  @override
  QuizColors lerp(ThemeExtension<QuizColors>? other, double t) {
    if (other is! QuizColors) return this;
    return QuizColors(
      correct: Color.lerp(correct, other.correct, t)!,
      onCorrect: Color.lerp(onCorrect, other.onCorrect, t)!,
      correctContainer: Color.lerp(
        correctContainer,
        other.correctContainer,
        t,
      )!,
      wrong: Color.lerp(wrong, other.wrong, t)!,
      onWrong: Color.lerp(onWrong, other.onWrong, t)!,
      wrongContainer: Color.lerp(wrongContainer, other.wrongContainer, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}

/// Akses cepat: `context.quizColors.correct`
extension QuizColorsContext on BuildContext {
  QuizColors get quizColors => Theme.of(this).extension<QuizColors>()!;
}

/// Warna permukaan "terangkat" (kartu, opsi jawaban, input) yang lebih terang
/// dari latar di mode terang dan sedikit lebih terang dari latar di mode gelap.
extension AppColorScheme on ColorScheme {
  Color get card => brightness == Brightness.light
      ? surfaceContainerLowest
      : surfaceContainerHigh;
}

/// Kumpulan tema aplikasi. Semua widget memakai Theme.of(context),
/// jadi font dan warna konsisten di seluruh halaman.
class AppTheme {
  const AppTheme._();

  /// Font isi (didaftarkan di pubspec.yaml).
  static const String fontFamily = 'Poppins';

  /// Font judul/brand (hanya untuk teks besar, bukan paragraf).
  static const String displayFontFamily = 'Pacifico';

  /// Warna dasar; seluruh palet dibangkitkan dari sini oleh Material 3.
  static const Color _seedColor = Color(0xFF5B4BDB);

  /// Latar halaman dengan sedikit rona lavender agar lembut di mata.
  static const Color _lightSurface = Color(0xFFF8F6FF);
  static const Color _darkSurface = Color(0xFF15131F);

  static ThemeData get light => _build(Brightness.light, QuizColors.light);

  static ThemeData get dark => _build(Brightness.dark, QuizColors.dark);

  static ThemeData _build(Brightness brightness, QuizColors quizColors) {
    final isLight = brightness == Brightness.light;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: brightness,
        ).copyWith(
          // Mode terang memakai ungu brand apa adanya (palet M3 meredamnya),
          // supaya senada dengan logo. Mode gelap tetap memakai nada lavender.
          primary: isLight ? _seedColor : null,
          surface: isLight ? _lightSurface : _darkSurface,
        );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      // Font isi diterapkan sekali di sini untuk seluruh teks aplikasi.
      fontFamily: fontFamily,
      scaffoldBackgroundColor: scheme.surface,
      extensions: <ThemeExtension<dynamic>>[quizColors],
    );

    // Gaya display memakai font brand (Pacifico hanya punya satu bobot).
    TextStyle? display(TextStyle? style) => style?.copyWith(
      fontFamily: displayFontFamily,
      fontWeight: FontWeight.w400,
    );
    final text = base.textTheme;

    return base.copyWith(
      textTheme: text.copyWith(
        displayMedium: display(text.displayMedium),
        displaySmall: display(text.displaySmall),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: scheme.onSurface,
        ),
      ),
      // Kartu: permukaan terangkat + bayangan tipis berona primer.
      cardTheme: CardThemeData(
        elevation: 2,
        margin: EdgeInsets.zero,
        color: scheme.card,
        shadowColor: scheme.primary.withValues(alpha: 0.16),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl - AppSpacing.xs,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          side: BorderSide(color: scheme.outline),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),
    );
  }
}
