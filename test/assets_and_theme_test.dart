import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quizapp/theme/app_theme.dart';
import 'package:quizapp/utils/app_assets.dart';
import 'package:quizapp/widgets/score_card.dart';
import 'package:quizapp/widgets/star_rating.dart';
import 'package:quizapp/widgets/svg_icon.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Aset SVG buatan sendiri', () {
    test('minimal 6 aset baru dan tidak ada duplikat path', () {
      expect(AppAssets.all.length, greaterThanOrEqualTo(6));
      expect(AppAssets.all.toSet().length, AppAssets.all.length);
    });

    for (final path in AppAssets.all) {
      test('$path terdaftar, berupa SVG, dan bisa dibaca', () async {
        // Gagal jika file tidak ada atau belum didaftarkan di pubspec.yaml.
        final content = await rootBundle.loadString(path);
        expect(content, contains('<svg'));
        expect(content, contains('viewBox'));
        // Aset harus buatan sendiri: tidak boleh memuat gambar bitmap.
        expect(content, isNot(contains('<image')));
        expect(content, isNot(contains('data:image')));
      });
    }

    testWidgets('semua SVG berhasil di-render tanpa error', (tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  for (final path in AppAssets.all)
                    SizedBox(
                      width: 80,
                      height: 60,
                      child: SvgPicture.asset(path),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('Font kustom', () {
    test('Poppins untuk isi, Pacifico untuk judul display', () {
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        expect(theme.textTheme.bodyMedium?.fontFamily, 'Poppins');
        expect(theme.textTheme.titleMedium?.fontFamily, 'Poppins');
        expect(theme.textTheme.displayMedium?.fontFamily, 'Pacifico');
        expect(theme.textTheme.displaySmall?.fontFamily, 'Pacifico');
      }
    });
  });

  group('Tema light & dark', () {
    test('warna aksen dan benar/salah tersedia di kedua mode', () {
      for (final colors in [QuizColors.light, QuizColors.dark]) {
        expect(colors.accent, isNot(colors.correct));
        expect(colors.wrong, isNot(colors.correct));
      }
      expect(AppTheme.light.extension<QuizColors>(), isNotNull);
      expect(AppTheme.dark.extension<QuizColors>(), isNotNull);
    });

    test('kontras teks judul (primer) terhadap latar cukup di kedua mode', () {
      // Teks display berwarna primer di atas permukaan; minimal 3:1 untuk
      // teks besar (standar WCAG AA untuk large text).
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        final scheme = theme.colorScheme;
        expect(_contrast(scheme.primary, scheme.surface), greaterThan(3));
        expect(_contrast(scheme.onSurface, scheme.surface), greaterThan(7));
        expect(_contrast(scheme.onPrimary, scheme.primary), greaterThan(4.5));
      }
    });
  });

  group('ScoreCard & StarRating', () {
    test('jumlah bintang menurut persentase', () {
      expect(ScoreCard.starsFor(1.0), 3);
      expect(ScoreCard.starsFor(0.8), 3);
      expect(ScoreCard.starsFor(0.79), 2);
      expect(ScoreCard.starsFor(0.5), 2);
      expect(ScoreCard.starsFor(0.49), 1);
      expect(ScoreCard.starsFor(0.1), 1);
      expect(ScoreCard.starsFor(0), 0);
    });

    testWidgets('StarRating menampilkan 3 ikon dan label semantik', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithApp(const Scaffold(body: StarRating(filled: 2))),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SvgIcon), findsNWidgets(3));
      expect(find.bySemanticsLabel('2 dari 3 bintang'), findsOneWidget);
    });

    testWidgets('angka skor naik hingga nilai akhir', (tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          const Scaffold(
            body: SingleChildScrollView(
              child: ScoreCard(
                userName: 'Budi',
                score: 8,
                total: 10,
                message: 'Luar biasa!',
                illustrationAsset: AppAssets.resultChampion,
              ),
            ),
          ),
        ),
      );
      // Awal animasi: belum mencapai skor akhir.
      expect(find.text('8/10'), findsNothing);
      await tester.pumpAndSettle();
      expect(find.text('8/10'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
    });
  });
}

/// Rasio kontras WCAG antara dua warna.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}
