import 'package:flutter_test/flutter_test.dart';

import 'package:quizapp/data/dummy_questions.dart';
import 'package:quizapp/providers/quiz_provider.dart';

void main() {
  group('dummyQuestions', () {
    test('minimal 10 soal, masing-masing 4 pilihan dan 1 jawaban valid', () {
      expect(dummyQuestions.length, greaterThanOrEqualTo(10));
      for (final q in dummyQuestions) {
        expect(q.options.length, 4, reason: q.text);
        expect(q.correctIndex, inInclusiveRange(0, 3), reason: q.text);
        expect(q.options.toSet().length, 4, reason: 'pilihan harus unik');
      }
    });
  });

  group('QuizProvider', () {
    late QuizProvider provider;

    setUp(() => provider = QuizProvider());

    test('state awal', () {
      expect(provider.userName, '');
      expect(provider.currentIndex, 0);
      expect(provider.score, 0);
      expect(provider.answeredCount, 0);
      expect(provider.isFirstQuestion, isTrue);
    });

    test('setUserName membuang spasi di tepi', () {
      provider.setUserName('  Budi  ');
      expect(provider.userName, 'Budi');
    });

    test('jawaban benar menambah skor, salah tidak', () {
      final correct = provider.currentQuestion.correctIndex;
      provider.selectAnswer(correct);
      expect(provider.score, 1);

      provider.nextQuestion();
      final wrong = (provider.currentQuestion.correctIndex + 1) % 4;
      provider.selectAnswer(wrong);
      expect(provider.score, 1);
      expect(provider.wrongCount, 1);
      expect(provider.answeredCount, 2);
    });

    test('jawaban terkunci setelah dipilih', () {
      final correct = provider.currentQuestion.correctIndex;
      provider.selectAnswer(correct);
      provider.selectAnswer((correct + 1) % 4);
      expect(provider.selectedAnswerAt(0), correct);
    });

    test('jawaban tersimpan saat pindah soal', () {
      provider.selectAnswer(2);
      provider.nextQuestion();
      provider.previousQuestion();
      expect(provider.selectedAnswerAt(0), 2);
    });

    test('navigasi tidak melewati batas', () {
      provider.previousQuestion();
      expect(provider.currentIndex, 0);

      for (var i = 0; i < provider.totalQuestions + 5; i++) {
        provider.nextQuestion();
      }
      expect(provider.currentIndex, provider.totalQuestions - 1);
      expect(provider.isLastQuestion, isTrue);
    });

    test('progress mengikuti indeks soal', () {
      expect(provider.progress, 1 / provider.totalQuestions);
      provider.goToQuestion(provider.totalQuestions - 1);
      expect(provider.progress, 1.0);
    });

    test('semua benar menghasilkan skor penuh', () {
      for (var i = 0; i < provider.totalQuestions; i++) {
        provider.goToQuestion(i);
        provider.selectAnswer(provider.currentQuestion.correctIndex);
      }
      expect(provider.isAllAnswered, isTrue);
      expect(provider.score, provider.totalQuestions);
      expect(provider.scorePercent, 100);
    });

    test('restartQuiz reset progres tapi nama tetap', () {
      provider.setUserName('Sari');
      provider.selectAnswer(0);
      provider.nextQuestion();

      provider.restartQuiz();

      expect(provider.userName, 'Sari');
      expect(provider.currentIndex, 0);
      expect(provider.answeredCount, 0);
      expect(provider.score, 0);
    });

    test('resetAll juga menghapus nama', () {
      provider.setUserName('Sari');
      provider.selectAnswer(0);
      provider.resetAll();
      expect(provider.userName, '');
      expect(provider.answeredCount, 0);
    });

    test('notifyListeners dipanggil saat state berubah', () {
      var calls = 0;
      provider.addListener(() => calls++);
      provider.setUserName('A');
      provider.selectAnswer(0);
      provider.nextQuestion();
      expect(calls, 3);
    });
  });
}
