import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/dummy_questions.dart';
import '../models/question.dart';

/// Menyimpan seluruh progres kuis: nama, indeks soal, jawaban per soal, skor,
/// timer per soal, streak, dan hint.
///
/// Provider ini diletakkan di atas MaterialApp, sehingga state TIDAK hilang
/// saat layar dirotasi (widget dibangun ulang) maupun saat pindah halaman.
class QuizProvider extends ChangeNotifier {
  /// [shuffle] = true -> urutan soal dan pilihan diacak setiap kuis dimulai
  /// (dipakai aplikasi). Default false agar test bersifat deterministik.
  QuizProvider({
    List<Question> questions = dummyQuestions,
    bool shuffle = false,
    Random? random,
  }) : _source = questions,
       _shuffleOnStart = shuffle,
       _random = random ?? Random(),
       _questions = List<Question>.of(questions),
       // null = belum dijawab; selain itu = indeks pilihan yang dipilih.
       _answers = List<int?>.filled(questions.length, null),
       _secondsLeft = List<int>.filled(questions.length, secondsPerQuestion),
       _timedOut = List<bool>.filled(questions.length, false),
       _eliminated = List<Set<int>>.generate(
         questions.length,
         (_) => <int>{},
       ) {
    if (_shuffleOnStart) _reshuffle();
  }

  /// Batas waktu menjawab satu soal (detik).
  static const int secondsPerQuestion = 30;

  /// Setiap kelipatan sekian jawaban benar, pemain mendapat 1 hint.
  static const int correctPerHint = 5;

  /// Jumlah pilihan salah yang dicoret oleh satu hint.
  static const int optionsRemovedByHint = 2;

  final List<Question> _source;
  final bool _shuffleOnStart;
  final Random _random;

  /// Soal yang sedang dipakai (sudah diacak jika [_shuffleOnStart] aktif).
  List<Question> _questions;
  final List<int?> _answers;

  /// Sisa waktu tiap soal. Hanya berkurang saat soalnya sedang tampil.
  final List<int> _secondsLeft;
  final List<bool> _timedOut;

  /// Pilihan yang dicoret oleh hint, per soal.
  final List<Set<int>> _eliminated;

  String _userName = '';
  int _currentIndex = 0;
  int _hintsUsed = 0;
  int _streak = 0;
  int _bestStreak = 0;

  // ---------------------------------------------------------------- Getter

  String get userName => _userName;

  int get currentIndex => _currentIndex;

  /// View read-only agar UI tidak bisa mengubah data langsung.
  List<Question> get questions => UnmodifiableListView(_questions);

  List<int?> get answers => UnmodifiableListView(_answers);

  int get totalQuestions => _questions.length;

  Question get currentQuestion => _questions[_currentIndex];

  bool get isFirstQuestion => _currentIndex == 0;

  bool get isLastQuestion => _currentIndex == _questions.length - 1;

  /// Nilai 0.0 - 1.0 untuk progress bar ("soal 3/10" -> 0.3).
  double get progress => (_currentIndex + 1) / _questions.length;

  /// Jumlah soal yang sudah dijawab.
  int get answeredCount => _answers.where((a) => a != null).length;

  int get unansweredCount => totalQuestions - answeredCount;

  bool get isAllAnswered => unansweredCount == 0;

  /// Jumlah soal yang waktunya habis sebelum dijawab.
  int get timedOutCount => _timedOut.where((t) => t).length;

  /// true jika kuis sudah dimulai (ada jawaban atau waktu soal yang habis),
  /// dipakai Beranda untuk menawarkan "Lanjutkan Kuis".
  bool get hasProgress => answeredCount > 0 || timedOutCount > 0;

  /// Skor = jumlah jawaban benar (dihitung dari [_answers] supaya selalu
  /// sinkron dan tidak mungkin berbeda dengan jawaban yang tersimpan).
  int get score {
    var total = 0;
    for (var i = 0; i < _questions.length; i++) {
      if (isCorrectAt(i)) total++;
    }
    return total;
  }

  /// Jawaban salah = sudah dijawab tetapi tidak benar.
  int get wrongCount => answeredCount - score;

  /// Skor dalam skala 0 - 100.
  int get scorePercent => (score * 100 / totalQuestions).round();

  // ------------------------------------------------------ Hint & streak

  /// Total hint yang sudah diperoleh (1 hint per [correctPerHint] benar).
  int get hintsEarned => score ~/ correctPerHint;

  int get hintsUsed => _hintsUsed;

  /// Hint yang masih bisa dipakai.
  int get hintsAvailable => hintsEarned - _hintsUsed;

  /// Berapa jawaban benar lagi untuk mendapat hint berikutnya.
  int get correctUntilNextHint => correctPerHint - (score % correctPerHint);

  /// Hint hanya bisa dipakai pada soal yang sedang tampil, belum dijawab,
  /// belum habis waktu, dan belum pernah memakai hint.
  bool get canUseHint =>
      hintsAvailable > 0 &&
      !isAnsweredAt(_currentIndex) &&
      !isTimedOutAt(_currentIndex) &&
      _eliminated[_currentIndex].isEmpty;

  /// Jumlah jawaban benar beruntun saat ini.
  int get streak => _streak;

  /// Streak beruntun terbaik pada kuis ini.
  int get bestStreak => _bestStreak;

  // ------------------------------------------------------ Query per soal

  /// Indeks pilihan yang dipilih pada soal [questionIndex] (null jika belum).
  int? selectedAnswerAt(int questionIndex) => _answers[questionIndex];

  bool isAnsweredAt(int questionIndex) => _answers[questionIndex] != null;

  /// true jika soal sudah dijawab dan jawabannya benar.
  bool isCorrectAt(int questionIndex) {
    final selected = _answers[questionIndex];
    return selected != null && _questions[questionIndex].isCorrect(selected);
  }

  /// true jika waktu soal [questionIndex] habis sebelum dijawab.
  bool isTimedOutAt(int questionIndex) => _timedOut[questionIndex];

  /// Sisa detik pada soal [questionIndex].
  int secondsLeftAt(int questionIndex) => _secondsLeft[questionIndex];

  /// Pilihan yang dicoret hint pada soal [questionIndex].
  Set<int> eliminatedAt(int questionIndex) =>
      UnmodifiableSetView(_eliminated[questionIndex]);

  /// true jika pilihan [optionIndex] pada soal yang sedang tampil boleh dipilih.
  bool canSelect(int optionIndex) =>
      optionIndex >= 0 &&
      optionIndex < currentQuestion.options.length &&
      !isAnsweredAt(_currentIndex) &&
      !_timedOut[_currentIndex] &&
      !_eliminated[_currentIndex].contains(optionIndex);

  // ---------------------------------------------------------------- Aksi

  /// Simpan nama pengguna (spasi di awal/akhir dibuang).
  void setUserName(String name) {
    _userName = name.trim();
    notifyListeners();
  }

  /// Pilih jawaban untuk soal yang sedang tampil.
  /// Jawaban dikunci setelah dipilih agar feedback benar/salah konsisten.
  void selectAnswer(int optionIndex) {
    if (!canSelect(optionIndex)) return;

    _answers[_currentIndex] = optionIndex;
    if (currentQuestion.isCorrect(optionIndex)) {
      _streak++;
      if (_streak > _bestStreak) _bestStreak = _streak;
    } else {
      _streak = 0;
    }
    notifyListeners();
  }

  /// Pakai satu hint: [optionsRemovedByHint] pilihan salah dicoret dari soal
  /// yang sedang tampil. Mengembalikan false jika hint tidak bisa dipakai.
  bool useHint() {
    if (!canUseHint) return false;

    final question = currentQuestion;
    final wrongOptions = [
      for (var i = 0; i < question.options.length; i++)
        if (i != question.correctIndex) i,
    ]..shuffle(_random);

    _eliminated[_currentIndex].addAll(wrongOptions.take(optionsRemovedByHint));
    _hintsUsed++;
    notifyListeners();
    return true;
  }

  /// Dipanggil timer UI setiap detik. Hanya soal yang sedang tampil dan belum
  /// dijawab yang waktunya berkurang; saat habis soal terkunci dan streak putus.
  void tick() {
    final index = _currentIndex;
    if (isAnsweredAt(index) || _timedOut[index]) return;

    _secondsLeft[index]--;
    if (_secondsLeft[index] <= 0) {
      _secondsLeft[index] = 0;
      _timedOut[index] = true;
      _streak = 0;
    }
    notifyListeners();
  }

  void nextQuestion() {
    if (isLastQuestion) return;
    _currentIndex++;
    notifyListeners();
  }

  void previousQuestion() {
    if (isFirstQuestion) return;
    _currentIndex--;
    notifyListeners();
  }

  /// Lompat ke soal tertentu (mis. dari grid nomor soal).
  void goToQuestion(int index) {
    if (index < 0 || index >= _questions.length || index == _currentIndex) {
      return;
    }
    _currentIndex = index;
    notifyListeners();
  }

  /// Ulangi kuis: jawaban, timer, hint, dan posisi soal direset (soal diacak
  /// ulang jika shuffle aktif), nama tetap dipertahankan.
  void restartQuiz() {
    _resetProgress();
    notifyListeners();
  }

  /// Reset total (termasuk nama), mis. untuk pengguna baru.
  void resetAll() {
    _userName = '';
    _resetProgress();
    notifyListeners();
  }

  void _resetProgress() {
    _currentIndex = 0;
    _hintsUsed = 0;
    _streak = 0;
    _bestStreak = 0;
    _answers.fillRange(0, _answers.length, null);
    _secondsLeft.fillRange(0, _secondsLeft.length, secondsPerQuestion);
    _timedOut.fillRange(0, _timedOut.length, false);
    for (final set in _eliminated) {
      set.clear();
    }
    if (_shuffleOnStart) _reshuffle();
  }

  /// Acak urutan soal dan urutan pilihan di tiap soal.
  void _reshuffle() {
    _questions = [for (final q in _source) q.shuffled(_random)]
      ..shuffle(_random);
  }
}
