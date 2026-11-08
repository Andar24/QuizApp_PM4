import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:quizapp/data/dummy_questions.dart';
import 'package:quizapp/main.dart';
import 'package:quizapp/providers/quiz_provider.dart';
import 'package:quizapp/screens/home_screen.dart';
import 'package:quizapp/screens/quiz_screen.dart';
import 'package:quizapp/screens/result_screen.dart';
import 'package:quizapp/utils/app_assets.dart';
import 'package:quizapp/utils/page_transitions.dart';
import 'package:quizapp/utils/score_feedback.dart';
import 'package:quizapp/widgets/answer_summary_tile.dart';

import 'test_helpers.dart';

/// Quiz dengan [correct] jawaban benar, sisanya salah. Soal terakhir
/// dikosongkan jika [leaveLastEmpty] true.
QuizProvider buildQuiz({int correct = 7, bool leaveLastEmpty = false}) {
  final quiz = QuizProvider()..setUserName('Budi');
  final count = leaveLastEmpty ? quiz.totalQuestions - 1 : quiz.totalQuestions;
  for (var i = 0; i < count; i++) {
    quiz.goToQuestion(i);
    final right = quiz.currentQuestion.correctIndex;
    quiz.selectAnswer(i < correct ? right : (right + 1) % 4);
  }
  return quiz;
}

/// Menampilkan Home lalu mendorong ResultScreen di atasnya.
Future<void> pumpResultOnTopOfHome(
    WidgetTester tester,
    QuizProvider quiz,
    ) async {
  await tester.pumpWidget(wrapWithApp(const HomeScreen(), quiz: quiz));
  Navigator.of(tester.element(find.byType(HomeScreen)))
      .push(fadeSlideRoute(const ResultScreen()));
  await tester.pumpAndSettle();
}

void main() {
  group('ScoreFeedback.fromPercent', () {
    test('pesan berbeda untuk tiap rentang skor', () {
      final messages = {
        for (final p in [100, 90, 70, 50, 10])
          ScoreFeedback.fromPercent(p).message,
      };
      expect(messages.length, 5);
    });

    test('3 ilustrasi: juara / bagus / semangat lagi', () {
      String image(int p) => ScoreFeedback.fromPercent(p).illustrationAsset;
      expect(image(100), AppAssets.resultChampion);
      expect(image(80), AppAssets.resultChampion);
      expect(image(79), AppAssets.resultGood);
      expect(image(60), AppAssets.resultGood);
      expect(image(59), AppAssets.resultKeepGoing);
      expect(image(0), AppAssets.resultKeepGoing);
    });
  });

  group('ResultScreen', () {
    testWidgets('menampilkan nama, skor, pesan, dan statistik', (tester) async {
      setScreenSize(tester, const Size(400, 900));
      await tester.pumpWidget(
        wrapWithApp(const ResultScreen(), quiz: buildQuiz(correct: 7)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Budi'), findsOneWidget);
      expect(find.text('7/10'), findsOneWidget);
      expect(find.text('70%'), findsOneWidget);
      expect(find.text(ScoreFeedback.fromPercent(70).message), findsOneWidget);
      expect(find.text('Benar'), findsOneWidget);
      expect(find.text('Salah'), findsOneWidget);
    });

    testWidgets('ringkasan memuat 10 soal dengan status benar/salah', (
        tester,
        ) async {
      await tester.pumpWidget(
        wrapWithApp(const ResultScreen(), quiz: buildQuiz(correct: 7)),
      );
      await tester.pumpAndSettle();

      final tiles = tester
          .widgetList<AnswerSummaryTile>(
        find.byType(AnswerSummaryTile, skipOffstage: false),
      )
          .toList();
      expect(tiles.length, dummyQuestions.length);
      expect(tiles.where((t) => t.isCorrect).length, 7);
      expect(tiles.where((t) => !t.isCorrect).length, 3);
    });

    testWidgets('soal tidak dijawab ditandai', (tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          const ResultScreen(),
          quiz: buildQuiz(correct: 9, leaveLastEmpty: true),
        ),
      );
      await tester.pumpAndSettle();

      final tiles = tester.widgetList<AnswerSummaryTile>(
        find.byType(AnswerSummaryTile, skipOffstage: false),
      );
      expect(tiles.last.selectedAnswer, isNull);
      expect(tiles.last.isCorrect, isFalse);
    });

    testWidgets('Ulangi Kuis mereset progres (nama tetap) dan buka kuis', (
        tester,
        ) async {
      final quiz = buildQuiz(correct: 7);
      await tester.pumpWidget(wrapWithApp(const ResultScreen(), quiz: quiz));
      await tester.pumpAndSettle();

      await tapText(tester, 'Ulangi Kuis');

      expect(find.byType(QuizScreen), findsOneWidget);
      expect(find.byType(ResultScreen), findsNothing);
      expect(find.text('Soal 1/10'), findsOneWidget);
      expect(quiz.userName, 'Budi');
      expect(quiz.answeredCount, 0);
      expect(quiz.score, 0);
    });

    testWidgets('Kembali ke Beranda mereset progres dan nama terisi', (
        tester,
        ) async {
      final quiz = buildQuiz(correct: 7);
      await pumpResultOnTopOfHome(tester, quiz);

      await tapText(tester, 'Kembali ke Beranda');

      expect(find.byType(ResultScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(quiz.answeredCount, 0);
      // Tidak ada tawaran "Lanjutkan" untuk kuis yang sudah selesai.
      expect(find.text('Mulai Kuis'), findsOneWidget);
      expect(find.text('Lanjutkan Kuis'), findsNothing);
    });

    testWidgets('tombol back sistem sama dengan Kembali ke Beranda', (
        tester,
        ) async {
      final quiz = buildQuiz(correct: 7);
      await pumpResultOnTopOfHome(tester, quiz);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(quiz.answeredCount, 0);
    });

    testWidgets('skor tidak berubah selama animasi setelah reset', (
        tester,
        ) async {
      final quiz = buildQuiz(correct: 7);
      await tester.pumpWidget(wrapWithApp(const ResultScreen(), quiz: quiz));
      await tester.pumpAndSettle();

      final retry = find.text('Ulangi Kuis');
      await tester.ensureVisible(retry);
      await tester.pumpAndSettle();
      await tester.tap(retry);
      // Pertengahan animasi: Result masih tampil dengan skor lama.
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('7/10'), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });

  group('Alur lengkap Home -> Kuis -> Hasil -> Ulangi', () {
    testWidgets('semua jawaban benar menghasilkan skor penuh', (tester) async {
      setScreenSize(tester, const Size(400, 900));
      await tester.pumpWidget(const QuizApp());

      await tester.enterText(find.byType(TextFormField), 'Siti');
      await tapText(tester, 'Mulai Kuis');

      // QuizApp memakai shuffle: urutan soal dan pilihan diacak, jadi jawaban
      // benar harus dibaca dari soal yang SEDANG tampil (bukan dummyQuestions[i]).
      QuizProvider quizOf() => Provider.of<QuizProvider>(
        tester.element(find.byType(QuizScreen)),
        listen: false,
      );

      for (var i = 0; i < dummyQuestions.length; i++) {
        await tapText(tester, quizOf().currentQuestion.correctAnswer);

        // SnackBar "Hint baru didapat" (jawaban benar ke-5 dan ke-10) menutupi
        // tombol Next/Selesai, jadi ditutup dulu sebelum menekan tombol.
        ScaffoldMessenger.of(
          tester.element(find.byType(QuizScreen)),
        ).hideCurrentSnackBar();
        await tester.pumpAndSettle();

        await tapText(
          tester,
          i == dummyQuestions.length - 1 ? 'Selesai' : 'Next',
        );
      }

      // Dialog konfirmasi muncul sebelum submit.
      await tapText(tester, 'Ya, selesai');

      expect(find.byType(ResultScreen), findsOneWidget);
      expect(find.text('Siti'), findsOneWidget);
      expect(find.text('10/10'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);

      await tapText(tester, 'Ulangi Kuis');
      expect(find.text('Soal 1/10'), findsOneWidget);
      expect(find.text('0 terjawab'), findsOneWidget);
    });
  });

  group('ResultScreen tidak overflow', () {
    for (final entry in testScreenSizes.entries) {
      testWidgets(entry.key, (tester) async {
        setScreenSize(tester, entry.value);
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        final quiz = buildQuiz(correct: 5, leaveLastEmpty: true)
          ..setUserName('Nama Yang Sangat Panjang Sekali Untuk Menguji Layout');
        await tester.pumpWidget(wrapWithApp(const ResultScreen(), quiz: quiz));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });
}