import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quizapp/data/dummy_questions.dart';
import 'package:quizapp/providers/quiz_provider.dart';
import 'package:quizapp/screens/home_screen.dart';
import 'package:quizapp/screens/quiz_screen.dart';
import 'package:quizapp/screens/result_screen.dart';
import 'package:quizapp/utils/responsive.dart';
import 'package:quizapp/widgets/answer_option.dart';
import 'package:quizapp/widgets/feedback_banner.dart';
import 'package:quizapp/widgets/progress_header.dart';
import 'package:quizapp/widgets/question_card.dart';
import 'package:quizapp/widgets/score_card.dart';

import 'test_helpers.dart';

void main() {
  group('Responsive (unit)', () {
    test('useTwoColumns', () {
      // Ponsel portrait & tablet portrait -> satu kolom.
      expect(Responsive.useTwoColumns(const Size(400, 800)), isFalse);
      expect(Responsive.useTwoColumns(const Size(820, 1180)), isFalse);
      // Landscape & web lebar -> dua kolom.
      expect(Responsive.useTwoColumns(const Size(800, 360)), isTrue);
      expect(Responsive.useTwoColumns(const Size(1180, 820)), isTrue);
      expect(Responsive.useTwoColumns(const Size(1400, 900)), isTrue);
      // Landscape tapi terlalu sempit.
      expect(Responsive.useTwoColumns(const Size(640, 300)), isFalse);
    });

    test('padding dibatasi', () {
      expect(Responsive.pagePadding(100), 16);
      expect(Responsive.pagePadding(5000), 32);
      expect(Responsive.cardPadding(5000), 28);
    });

    test('skala teks naik di layar lebar', () {
      expect(Responsive.textScaleFor(400), 1.0);
      expect(Responsive.textScaleFor(900), 1.1);
      expect(Responsive.textScaleFor(1400), 1.2);
    });
  });

  group('Skala teks adaptif', () {
    Future<double> measuredScale(WidgetTester tester, Size size) async {
      setScreenSize(tester, size);
      late double scale;
      await tester.pumpWidget(
        wrapWithApp(
          Builder(
            builder: (context) {
              scale = MediaQuery.textScalerOf(context).scale(10);
              return const SizedBox();
            },
          ),
        ),
      );
      return scale;
    }

    testWidgets('ponsel 1.0x, tablet 1.1x, web 1.2x', (tester) async {
      expect(await measuredScale(tester, const Size(400, 800)), 10);
      expect(
        await measuredScale(tester, const Size(900, 600)),
        closeTo(11, 0.001),
      );
      expect(
        await measuredScale(tester, const Size(1400, 900)),
        closeTo(12, 0.001),
      );
    });

    testWidgets('dikalikan dengan skala font sistem pengguna', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      expect(
        await measuredScale(tester, const Size(1400, 900)),
        closeTo(18, 0.001),
      );
    });
  });

  group('Layout QuizScreen', () {
    Future<void> pumpAt(WidgetTester tester, Size size) async {
      setScreenSize(tester, size);
      await tester.pumpWidget(wrapWithApp(const QuizScreen(), quiz: newQuiz()));
      await tester.pumpAndSettle();
    }

    testWidgets('tablet portrait: soal di atas, opsi di bawah (1 kolom)', (
      tester,
    ) async {
      await pumpAt(tester, const Size(820, 1180));

      final card = tester.getRect(find.byType(QuestionCard));
      final option = tester.getRect(find.byType(AnswerOption).first);
      expect(option.top, greaterThanOrEqualTo(card.bottom));
    });

    for (final size in const [Size(1180, 820), Size(800, 360)]) {
      testWidgets('landscape $size: soal di kiri, opsi di kanan (2 kolom)', (
        tester,
      ) async {
        await pumpAt(tester, size);

        final card = tester.getRect(find.byType(QuestionCard));
        final option = tester.getRect(find.byType(AnswerOption).first);
        expect(option.left, greaterThanOrEqualTo(card.right));
      });
    }

    testWidgets('web lebar: konten dibatasi max width dan dipusatkan', (
      tester,
    ) async {
      await pumpAt(tester, const Size(2560, 1080));

      final header = tester.getRect(find.byType(ProgressHeader));
      expect(header.width, lessThanOrEqualTo(Responsive.twoColumnMaxWidth));
      // Dipusatkan secara horizontal.
      expect(header.center.dx, closeTo(2560 / 2, 1));
    });

    testWidgets('layout tidak berpindah saat keyboard muncul di Home', (
      tester,
    ) async {
      setScreenSize(tester, const Size(820, 1180));
      await tester.pumpWidget(wrapWithApp(const HomeScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      // Simulasi keyboard menutupi sebagian layar (hanya viewInsets).
      tester.view.viewInsets = const FakeViewPadding(bottom: 500);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      // Jika layout berpindah, field akan dibangun ulang dan kehilangan
      // fokus (keyboard menutup). Fokus yang bertahan = layout stabil.
      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.focusNode.hasFocus, isTrue);
      expect(tester.takeException(), isNull);
    });
  });

  group('Layout ResultScreen', () {
    testWidgets('tablet portrait 1 kolom, landscape 2 kolom', (tester) async {
      QuizProvider quiz() => newQuiz()..selectAnswer(0);

      setScreenSize(tester, const Size(820, 1180));
      await tester.pumpWidget(wrapWithApp(const ResultScreen(), quiz: quiz()));
      await tester.pumpAndSettle();
      final portraitCard = tester.getRect(find.byType(ScoreCard));
      // Satu kolom: kartu skor dipusatkan dan dibatasi 640.
      expect(portraitCard.width, lessThanOrEqualTo(640));
      expect(portraitCard.center.dx, closeTo(410, 1));

      tester.view.physicalSize = const Size(1400, 900);
      await tester.pumpAndSettle();
      final landscapeCard = tester.getRect(find.byType(ScoreCard));
      // Dua kolom: kartu skor di separuh kiri.
      expect(landscapeCard.right, lessThan(700));
    });
  });

  group('Pintasan keyboard di QuizScreen', () {
    final first = dummyQuestions.first;

    testWidgets('tombol A-D / 1-4 memilih jawaban', (tester) async {
      final quiz = newQuiz();
      await tester.pumpWidget(wrapWithApp(const QuizScreen(), quiz: quiz));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.pumpAndSettle();

      expect(quiz.selectedAnswerAt(0), 2);
      expect(find.byType(FeedbackBanner), findsOneWidget);

      // Pilihan terkunci, tombol lain tidak mengubahnya.
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      await tester.pumpAndSettle();
      expect(quiz.selectedAnswerAt(0), 2);
    });

    testWidgets('angka 1-4 memilih jawaban pada soal berikutnya', (
      tester,
    ) async {
      final quiz = newQuiz();
      await tester.pumpWidget(wrapWithApp(const QuizScreen(), quiz: quiz));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
      await tester.pumpAndSettle();

      expect(quiz.currentIndex, 1);
      expect(quiz.selectedAnswerAt(1), 3);
    });

    testWidgets('panah kanan/kiri pindah soal dan tidak melewati batas', (
      tester,
    ) async {
      final quiz = newQuiz();
      await tester.pumpWidget(wrapWithApp(const QuizScreen(), quiz: quiz));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(quiz.currentIndex, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(quiz.currentIndex, 1);
      expect(find.text(dummyQuestions[1].text), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(quiz.currentIndex, 0);
      expect(find.text(first.text), findsOneWidget);

      quiz.goToQuestion(9);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(quiz.currentIndex, 9);
    });
  });
}
