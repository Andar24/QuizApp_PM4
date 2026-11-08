import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quizapp/data/dummy_questions.dart';
import 'package:quizapp/providers/quiz_provider.dart';
import 'package:quizapp/screens/quiz_screen.dart';
import 'package:quizapp/screens/result_screen.dart';
import 'package:quizapp/widgets/answer_option.dart';
import 'package:quizapp/widgets/feedback_banner.dart';

import 'test_helpers.dart';

Future<void> pumpQuiz(WidgetTester tester, QuizProvider quiz) async {
  await tester.pumpWidget(wrapWithApp(const QuizScreen(), quiz: quiz));
  await tester.pumpAndSettle();
}

void main() {
  final first = dummyQuestions.first;

  group('QuizScreen', () {
    testWidgets('menampilkan soal pertama dan progress', (tester) async {
      await pumpQuiz(tester, newQuiz());

      expect(find.text('Soal 1/10'), findsOneWidget);
      expect(find.text(first.text), findsOneWidget);
      expect(find.byType(AnswerOption), findsNWidgets(4));
      expect(find.text('Kuis: Budi'), findsOneWidget);
    });

    testWidgets('memilih jawaban menyimpan ke provider + feedback + terkunci', (
      tester,
    ) async {
      final quiz = newQuiz();
      await pumpQuiz(tester, quiz);

      final wrong = (first.correctIndex + 1) % 4;
      await tapText(tester, first.options[wrong]);

      expect(quiz.selectedAnswerAt(0), wrong);
      expect(quiz.score, 0);
      expect(find.byType(FeedbackBanner), findsOneWidget);
      expect(find.text('Jawaban kurang tepat'), findsOneWidget);

      // Mencoba mengganti jawaban tidak berpengaruh.
      await tapText(tester, first.options[first.correctIndex]);
      expect(quiz.selectedAnswerAt(0), wrong);
    });

    testWidgets('jawaban benar menambah skor', (tester) async {
      final quiz = newQuiz();
      await pumpQuiz(tester, quiz);

      await tapText(tester, first.options[first.correctIndex]);

      expect(quiz.score, 1);
      expect(find.text('Jawaban benar!'), findsOneWidget);
    });

    testWidgets('Next / Previous berpindah soal dan jawaban tetap', (
      tester,
    ) async {
      final quiz = newQuiz();
      await pumpQuiz(tester, quiz);

      // Previous nonaktif di soal pertama.
      final previous = find.widgetWithText(OutlinedButton, 'Previous');
      expect(tester.widget<OutlinedButton>(previous).onPressed, isNull);

      await tapText(tester, first.options[first.correctIndex]);
      await tapText(tester, 'Next');
      expect(find.text('Soal 2/10'), findsOneWidget);
      expect(find.text(dummyQuestions[1].text), findsOneWidget);
      expect(find.byType(FeedbackBanner), findsNothing);

      await tapText(tester, 'Previous');
      expect(find.text('Soal 1/10'), findsOneWidget);
      // Feedback jawaban sebelumnya masih tampil.
      expect(find.byType(FeedbackBanner), findsOneWidget);
      expect(quiz.selectedAnswerAt(0), first.correctIndex);
    });

    testWidgets('soal terakhir menampilkan tombol Selesai', (tester) async {
      final quiz = newQuiz()..goToQuestion(9);
      await pumpQuiz(tester, quiz);

      expect(find.text('Selesai'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });
  });

  group('Dialog konfirmasi submit', () {
    testWidgets('Periksa lagi menutup dialog dan tetap di kuis', (
      tester,
    ) async {
      final quiz = newQuiz()..goToQuestion(9);
      await pumpQuiz(tester, quiz);

      await tapText(tester, 'Selesai');
      expect(find.text('Selesaikan kuis?'), findsOneWidget);
      expect(find.textContaining('10 soal yang belum dijawab'), findsOneWidget);

      await tapText(tester, 'Periksa lagi');
      expect(find.text('Selesaikan kuis?'), findsNothing);
      expect(find.byType(QuizScreen), findsOneWidget);
    });

    testWidgets('Ya, selesai membuka halaman hasil', (tester) async {
      final quiz = newQuiz()..goToQuestion(9);
      await pumpQuiz(tester, quiz);

      await tapText(tester, 'Selesai');
      await tapText(tester, 'Ya, selesai');

      expect(find.byType(ResultScreen), findsOneWidget);
      expect(find.byType(QuizScreen), findsNothing);
    });
  });

  group('Rotasi layar', () {
    testWidgets('progres tidak hilang saat ukuran/orientasi berubah', (
      tester,
    ) async {
      final quiz = newQuiz();
      setScreenSize(tester, const Size(400, 800)); // portrait
      await pumpQuiz(tester, quiz);

      await tapText(tester, first.options[first.correctIndex]);
      await tapText(tester, 'Next');
      await tapText(tester, dummyQuestions[1].options[0]);
      expect(find.text('Soal 2/10'), findsOneWidget);

      // Rotasi ke landscape.
      tester.view.physicalSize = const Size(800, 400);
      await tester.pumpAndSettle();

      expect(find.text('Soal 2/10'), findsOneWidget);
      expect(find.text('2 terjawab'), findsOneWidget);
      expect(find.text(dummyQuestions[1].text), findsOneWidget);
      expect(find.byType(FeedbackBanner), findsOneWidget);
      expect(quiz.answeredCount, 2);
      expect(tester.takeException(), isNull);

      // Kembali ke portrait.
      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpAndSettle();
      expect(find.text('Soal 2/10'), findsOneWidget);
      expect(quiz.answeredCount, 2);
    });
  });

  group('QuizScreen tidak overflow', () {
    for (final entry in testScreenSizes.entries) {
      testWidgets(entry.key, (tester) async {
        setScreenSize(tester, entry.value);
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        // Soal dengan teks terpanjang + sudah dijawab salah (feedback tampil).
        final quiz = newQuiz()
          ..goToQuestion(0)
          ..selectAnswer((first.correctIndex + 1) % 4);
        await pumpQuiz(tester, quiz);
        expect(tester.takeException(), isNull);

        // Dialog juga tidak overflow.
        quiz.goToQuestion(9);
        await tester.pumpAndSettle();
        await tapText(tester, 'Selesai');
        expect(find.text('Selesaikan kuis?'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
