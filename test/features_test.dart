import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:quizapp/data/dummy_questions.dart';
import 'package:quizapp/providers/quiz_provider.dart';
import 'package:quizapp/screens/quiz_screen.dart';
import 'package:quizapp/screens/result_screen.dart';
import 'package:quizapp/widgets/answer_option.dart';
import 'package:quizapp/widgets/question_grid.dart';

import 'test_helpers.dart';

/// Menjawab benar [count] soal berturut-turut mulai dari soal saat ini.
void answerCorrect(QuizProvider quiz, int count) {
  for (var i = 0; i < count; i++) {
    quiz.selectAnswer(quiz.currentQuestion.correctIndex);
    quiz.nextQuestion();
  }
}

/// Menjawab salah soal saat ini lalu pindah ke soal berikutnya.
void answerWrong(QuizProvider quiz) {
  quiz.selectAnswer((quiz.currentQuestion.correctIndex + 1) % 4);
  quiz.nextQuestion();
}

Future<void> pumpQuiz(WidgetTester tester, QuizProvider quiz) async {
  await tester.pumpWidget(wrapWithApp(const QuizScreen(), quiz: quiz));
  await tester.pumpAndSettle();
}

void main() {
  group('Reward hint (tiap 5 jawaban benar)', () {
    test('hint didapat setiap 5 jawaban benar', () {
      final quiz = newQuiz();

      answerCorrect(quiz, 4);
      expect(quiz.hintsEarned, 0);
      expect(quiz.hintsAvailable, 0);
      expect(quiz.correctUntilNextHint, 1);

      answerCorrect(quiz, 1);
      expect(quiz.hintsEarned, 1);
      expect(quiz.hintsAvailable, 1);

      answerCorrect(quiz, 5);
      expect(quiz.hintsEarned, 2);
      expect(quiz.hintsAvailable, 2);
    });

    test('jawaban salah tidak dihitung untuk hint', () {
      final quiz = newQuiz();
      answerCorrect(quiz, 3);
      answerWrong(quiz);
      answerWrong(quiz);
      answerCorrect(quiz, 1);

      expect(quiz.score, 4);
      expect(quiz.hintsEarned, 0);
    });

    test('hint mencoret 2 pilihan salah, memakai token, dan tidak bisa 2x', () {
      final quiz = newQuiz();
      answerCorrect(quiz, 5);
      expect(quiz.currentIndex, 5);
      expect(quiz.canUseHint, isTrue);

      expect(quiz.useHint(), isTrue);

      final eliminated = quiz.eliminatedAt(5);
      expect(eliminated.length, QuizProvider.optionsRemovedByHint);
      expect(eliminated.contains(quiz.currentQuestion.correctIndex), isFalse);
      expect(quiz.hintsAvailable, 0);
      expect(quiz.hintsUsed, 1);

      // Sudah tidak ada token dan soal ini sudah memakai hint.
      expect(quiz.useHint(), isFalse);
      expect(quiz.hintsUsed, 1);
    });

    test('tanpa token, hint tidak bisa dipakai', () {
      final quiz = newQuiz();

      expect(quiz.canUseHint, isFalse);
      expect(quiz.useHint(), isFalse);
      expect(quiz.eliminatedAt(0), isEmpty);
    });

    test('pilihan yang dicoret tidak bisa dipilih', () {
      final quiz = newQuiz();
      answerCorrect(quiz, 5);
      quiz.useHint();

      final eliminated = quiz.eliminatedAt(5).first;
      expect(quiz.canSelect(eliminated), isFalse);
      quiz.selectAnswer(eliminated);
      expect(quiz.selectedAnswerAt(5), isNull);

      expect(quiz.canSelect(quiz.currentQuestion.correctIndex), isTrue);
    });

    test('hint tidak bisa dipakai pada soal yang sudah dijawab', () {
      final quiz = newQuiz();
      answerCorrect(quiz, 5);
      quiz.selectAnswer(quiz.currentQuestion.correctIndex);

      expect(quiz.hintsAvailable, 1);
      expect(quiz.canUseHint, isFalse);
      expect(quiz.useHint(), isFalse);
    });
  });

  group('Streak', () {
    test('menghitung benar beruntun dan mencatat streak terbaik', () {
      final quiz = newQuiz();

      answerCorrect(quiz, 2);
      expect(quiz.streak, 2);
      expect(quiz.bestStreak, 2);

      answerWrong(quiz);
      expect(quiz.streak, 0);
      expect(quiz.bestStreak, 2);

      answerCorrect(quiz, 1);
      expect(quiz.streak, 1);
      expect(quiz.bestStreak, 2);
    });
  });

  group('Timer per soal', () {
    test('batas waktu 30 detik per soal', () {
      expect(QuizProvider.secondsPerQuestion, 30);
      expect(newQuiz().secondsLeftAt(0), 30);
    });

    test('tick hanya mengurangi waktu soal yang sedang tampil', () {
      final quiz = newQuiz();
      for (var i = 0; i < 3; i++) {
        quiz.tick();
      }

      expect(quiz.secondsLeftAt(0), 27);
      expect(quiz.secondsLeftAt(1), 30);
    });

    test('waktu habis mengunci soal dan memutus streak', () {
      final quiz = newQuiz();
      answerCorrect(quiz, 2);
      expect(quiz.streak, 2);
      expect(quiz.hasProgress, isTrue);

      for (var i = 0; i < QuizProvider.secondsPerQuestion; i++) {
        quiz.tick();
      }

      expect(quiz.isTimedOutAt(2), isTrue);
      expect(quiz.secondsLeftAt(2), 0);
      expect(quiz.streak, 0);
      expect(quiz.bestStreak, 2);
      expect(quiz.timedOutCount, 1);

      quiz.selectAnswer(0);
      expect(quiz.selectedAnswerAt(2), isNull);
      expect(quiz.answeredCount, 2);
      expect(quiz.unansweredCount, quiz.totalQuestions - 2);
    });

    test('timer berhenti setelah soal dijawab', () {
      final quiz = newQuiz();
      for (var i = 0; i < 5; i++) {
        quiz.tick();
      }
      quiz.selectAnswer(quiz.currentQuestion.correctIndex);
      for (var i = 0; i < 5; i++) {
        quiz.tick();
      }

      expect(quiz.secondsLeftAt(0), 25);
      expect(quiz.isTimedOutAt(0), isFalse);
    });

    test('sisa waktu tiap soal tersimpan saat pindah soal', () {
      final quiz = newQuiz();
      for (var i = 0; i < 5; i++) {
        quiz.tick();
      }
      quiz.nextQuestion();
      for (var i = 0; i < 3; i++) {
        quiz.tick();
      }
      quiz.previousQuestion();

      expect(quiz.secondsLeftAt(0), 25);
      expect(quiz.secondsLeftAt(1), 27);
    });

    test('soal yang waktunya habis dihitung salah di skor', () {
      final quiz = newQuiz();
      for (var i = 0; i < QuizProvider.secondsPerQuestion; i++) {
        quiz.tick();
      }

      expect(quiz.score, 0);
      expect(quiz.isCorrectAt(0), isFalse);
    });
  });

  group('Reset kuis', () {
    test('restartQuiz mereset hint, streak, dan timer', () {
      final quiz = newQuiz();
      answerCorrect(quiz, 5);
      quiz.useHint();
      for (var i = 0; i < QuizProvider.secondsPerQuestion; i++) {
        quiz.tick();
      }

      quiz.restartQuiz();

      expect(quiz.currentIndex, 0);
      expect(quiz.hintsUsed, 0);
      expect(quiz.hintsAvailable, 0);
      expect(quiz.streak, 0);
      expect(quiz.bestStreak, 0);
      expect(quiz.timedOutCount, 0);
      expect(quiz.hasProgress, isFalse);
      for (var i = 0; i < quiz.totalQuestions; i++) {
        expect(quiz.secondsLeftAt(i), QuizProvider.secondsPerQuestion);
        expect(quiz.eliminatedAt(i), isEmpty);
      }
    });
  });

  group('Acak soal dan pilihan', () {
    /// Setiap soal hasil acak harus tetap punya pilihan yang sama dan teks
    /// jawaban benar yang sama dengan soal aslinya.
    void expectConsistent(QuizProvider quiz) {
      expect(
        quiz.questions.map((q) => q.text).toSet(),
        dummyQuestions.map((q) => q.text).toSet(),
      );
      expect(quiz.totalQuestions, dummyQuestions.length);

      for (final shuffled in quiz.questions) {
        final original = dummyQuestions.firstWhere(
          (q) => q.text == shuffled.text,
        );
        expect(shuffled.options.toSet(), original.options.toSet());
        expect(shuffled.options.length, original.options.length);
        expect(shuffled.correctAnswer, original.correctAnswer);
        expect(shuffled.isCorrect(shuffled.correctIndex), isTrue);
      }
    }

    test('tanpa shuffle urutan soal asli dipertahankan', () {
      final quiz = QuizProvider();

      expect(quiz.questions.first.text, dummyQuestions.first.text);
      expect(
        quiz.questions.map((q) => q.text).toList(),
        dummyQuestions.map((q) => q.text).toList(),
      );
    });

    test('Question.shuffled menjaga jawaban benar tetap sama', () {
      for (final original in dummyQuestions) {
        final shuffled = original.shuffled(Random(3));

        expect(shuffled.text, original.text);
        expect(shuffled.options.toSet(), original.options.toSet());
        expect(shuffled.correctAnswer, original.correctAnswer);
      }
    });

    test('shuffle menjaga semua soal dan jawaban benar', () {
      final quiz = QuizProvider(shuffle: true, random: Random(7));
      expectConsistent(quiz);

      // Urutan stabil selama kuis berjalan (tidak berubah saat dibaca ulang).
      final before = quiz.questions.map((q) => q.text).toList();
      quiz.nextQuestion();
      quiz.previousQuestion();
      expect(quiz.questions.map((q) => q.text).toList(), before);
    });

    test('restartQuiz mengacak ulang dan tetap konsisten', () {
      final quiz = QuizProvider(shuffle: true, random: Random(11));
      quiz.restartQuiz();
      expectConsistent(quiz);
    });

    test('skor tetap benar pada soal yang diacak', () {
      final quiz = QuizProvider(shuffle: true, random: Random(5));
      answerCorrect(quiz, quiz.totalQuestions);

      expect(quiz.score, quiz.totalQuestions);
      expect(quiz.wrongCount, 0);
    });
  });

  group('AnswerStatus.eliminated', () {
    test('pilihan yang dicoret hint berstatus eliminated', () {
      final status = AnswerStatus.resolve(
        optionIndex: 1,
        correctIndex: 2,
        selectedIndex: null,
        eliminated: true,
      );

      expect(status, AnswerStatus.eliminated);
    });
  });

  group('QuizScreen: timer', () {
    testWidgets('menampilkan 30 detik lalu menghitung mundur', (tester) async {
      await pumpQuiz(tester, newQuiz());
      expect(find.text('30s'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 3500));
      expect(find.text('27s'), findsOneWidget);
    });

    testWidgets('waktu habis menampilkan banner dan mengunci opsi', (
      tester,
    ) async {
      final quiz = newQuiz();
      await pumpQuiz(tester, quiz);

      await tester.pump(const Duration(seconds: 31));
      await tester.pumpAndSettle();

      expect(quiz.isTimedOutAt(0), isTrue);
      expect(find.text('Waktu habis!'), findsOneWidget);

      await tapText(tester, dummyQuestions.first.options[0]);
      expect(quiz.selectedAnswerAt(0), isNull);
    });
  });

  group('QuizScreen: streak', () {
    testWidgets('lencana streak muncul setelah 2 jawaban benar beruntun', (
      tester,
    ) async {
      await pumpQuiz(tester, newQuiz());
      final first = dummyQuestions[0];
      final second = dummyQuestions[1];

      await tapText(tester, first.options[first.correctIndex]);
      expect(find.text('x2'), findsNothing);

      await tapText(tester, 'Next');
      await tapText(tester, second.options[second.correctIndex]);
      expect(find.text('x2'), findsOneWidget);
    });
  });

  group('QuizScreen: hint', () {
    testWidgets('jawaban benar ke-5 memberi hint baru', (tester) async {
      final quiz = newQuiz();
      answerCorrect(quiz, 4);
      await pumpQuiz(tester, quiz);

      final fifth = dummyQuestions[4];
      await tapText(tester, fifth.options[fifth.correctIndex]);

      expect(quiz.hintsAvailable, 1);
      expect(find.textContaining('Hint baru didapat'), findsOneWidget);
      expect(find.byTooltip('Pakai hint (1)'), findsOneWidget);
    });

    testWidgets('memakai hint mencoret 2 pilihan salah', (tester) async {
      final quiz = newQuiz();
      answerCorrect(quiz, 5);
      await pumpQuiz(tester, quiz);

      await tester.tap(find.byTooltip('Pakai hint (1)'));
      await tester.pumpAndSettle();

      expect(quiz.hintsAvailable, 0);
      final eliminated = tester
          .widgetList<AnswerOption>(find.byType(AnswerOption))
          .where((o) => o.status == AnswerStatus.eliminated);
      expect(eliminated.length, 2);
      expect(find.byTooltip('Pakai hint (0)'), findsOneWidget);
    });

    testWidgets('tanpa hint, tombol menjelaskan cara mendapatkannya', (
      tester,
    ) async {
      final quiz = newQuiz();
      await pumpQuiz(tester, quiz);

      await tester.tap(find.byTooltip('Pakai hint (0)'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Belum ada hint'), findsOneWidget);
      expect(quiz.hintsUsed, 0);
    });
  });

  group('QuizScreen: grid nomor soal', () {
    testWidgets('membuka grid dan melompat ke soal yang dipilih', (
      tester,
    ) async {
      final quiz = newQuiz()
        ..selectAnswer(dummyQuestions.first.correctIndex);
      await pumpQuiz(tester, quiz);

      await tester.tap(find.byTooltip('Daftar soal'));
      await tester.pumpAndSettle();
      expect(find.text('Daftar Soal'), findsOneWidget);
      expect(find.byType(QuestionGrid), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(QuestionGrid),
          matching: find.text('3'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(QuestionGrid), findsNothing);
      expect(quiz.currentIndex, 2);
      expect(find.text('Soal 3/10'), findsOneWidget);
    });

    testWidgets('waktu berhenti selama grid terbuka', (tester) async {
      final quiz = newQuiz();
      await pumpQuiz(tester, quiz);

      await tester.tap(find.byTooltip('Daftar soal'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));

      expect(quiz.secondsLeftAt(0), QuizProvider.secondsPerQuestion);
    });
  });

  group('ResultScreen: statistik tambahan', () {
    testWidgets('menampilkan streak terbaik dan hint dipakai', (tester) async {
      final quiz = newQuiz();
      answerCorrect(quiz, 5);
      quiz.useHint();

      await tester.pumpWidget(wrapWithApp(const ResultScreen(), quiz: quiz));
      await tester.pumpAndSettle();

      expect(find.text('Streak terbaik'), findsOneWidget);
      expect(find.text('Hint dipakai'), findsOneWidget);
    });
  });

  group('Fitur baru tidak overflow', () {
    for (final entry in testScreenSizes.entries) {
      testWidgets(entry.key, (tester) async {
        setScreenSize(tester, entry.value);
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        // Streak 5, 1 hint sudah dipakai (pilihan dicoret), timer berjalan.
        final quiz = newQuiz();
        answerCorrect(quiz, 5);
        quiz.useHint();
        await pumpQuiz(tester, quiz);
        expect(tester.takeException(), isNull);

        // Grid nomor soal juga tidak overflow.
        await tester.tap(find.byTooltip('Daftar soal'));
        await tester.pumpAndSettle();
        expect(find.byType(QuestionGrid), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
