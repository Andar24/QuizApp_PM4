import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quizapp/providers/quiz_provider.dart';
import 'package:quizapp/screens/home_screen.dart';
import 'package:quizapp/screens/quiz_screen.dart';

import 'test_helpers.dart';

void main() {
  group('HomeScreen validasi & navigasi', () {
    testWidgets('nama kosong menampilkan error dan tidak pindah', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWithApp(const HomeScreen()));

      await tapText(tester, 'Mulai Kuis');

      expect(find.text('Nama tidak boleh kosong'), findsOneWidget);
      expect(find.byType(QuizScreen), findsNothing);
    });

    testWidgets('nama hanya spasi dianggap kosong', (tester) async {
      await tester.pumpWidget(wrapWithApp(const HomeScreen()));

      await tester.enterText(find.byType(TextFormField), '    ');
      await tapText(tester, 'Mulai Kuis');

      expect(find.text('Nama tidak boleh kosong'), findsOneWidget);
      expect(find.byType(QuizScreen), findsNothing);
    });

    testWidgets('nama 1 huruf ditolak', (tester) async {
      await tester.pumpWidget(wrapWithApp(const HomeScreen()));

      await tester.enterText(find.byType(TextFormField), 'A');
      await tapText(tester, 'Mulai Kuis');

      expect(find.text('Nama minimal 2 karakter'), findsOneWidget);
    });

    testWidgets('nama valid disimpan lalu pindah ke QuizScreen', (
      tester,
    ) async {
      final quiz = QuizProvider();
      await tester.pumpWidget(wrapWithApp(const HomeScreen(), quiz: quiz));

      await tester.enterText(find.byType(TextFormField), '  Budi  ');
      await tapText(tester, 'Mulai Kuis');

      expect(find.byType(QuizScreen), findsOneWidget);
      expect(quiz.userName, 'Budi');
    });
  });

  group('HomeScreen dengan progres tersimpan', () {
    QuizProvider quizWithProgress() {
      return QuizProvider()
        ..setUserName('Sari')
        ..selectAnswer(0);
    }

    testWidgets('nama terisi otomatis dan tombol berubah jadi Lanjutkan', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithApp(const HomeScreen(), quiz: quizWithProgress()),
      );

      expect(find.text('Sari'), findsOneWidget);
      expect(find.text('Lanjutkan Kuis'), findsOneWidget);
      expect(find.text('Mulai dari Awal'), findsOneWidget);
    });

    testWidgets('semua soal terjawab tetapi belum submit tetap bisa dilanjutkan', (
      tester,
    ) async {
      final quiz = QuizProvider()..setUserName('Sari');
      for (var i = 0; i < quiz.totalQuestions; i++) {
        quiz.selectAnswer(0);
        quiz.nextQuestion();
      }
      await tester.pumpWidget(wrapWithApp(const HomeScreen(), quiz: quiz));

      expect(find.text('Lanjutkan Kuis'), findsOneWidget);
    });

    testWidgets('Lanjutkan mempertahankan jawaban', (tester) async {
      final quiz = quizWithProgress();
      await tester.pumpWidget(wrapWithApp(const HomeScreen(), quiz: quiz));

      await tapText(tester, 'Lanjutkan Kuis');

      expect(find.byType(QuizScreen), findsOneWidget);
      expect(quiz.answeredCount, 1);
    });

    testWidgets('Mulai dari Awal mereset jawaban', (tester) async {
      final quiz = quizWithProgress();
      await tester.pumpWidget(wrapWithApp(const HomeScreen(), quiz: quiz));

      await tapText(tester, 'Mulai dari Awal');

      expect(find.byType(QuizScreen), findsOneWidget);
      expect(quiz.answeredCount, 0);
      expect(quiz.userName, 'Sari');
    });

    testWidgets('mengganti nama = pengguna baru, progres direset', (
      tester,
    ) async {
      final quiz = quizWithProgress();
      await tester.pumpWidget(wrapWithApp(const HomeScreen(), quiz: quiz));

      await tester.enterText(find.byType(TextFormField), 'Andi');
      await tapText(tester, 'Lanjutkan Kuis');

      expect(quiz.userName, 'Andi');
      expect(quiz.answeredCount, 0);
    });
  });

  group('HomeScreen tidak overflow', () {
    for (final entry in testScreenSizes.entries) {
      testWidgets(entry.key, (tester) async {
        setScreenSize(tester, entry.value);
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await tester.pumpWidget(
          wrapWithApp(
            const HomeScreen(),
            quiz: QuizProvider()..selectAnswer(0),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
