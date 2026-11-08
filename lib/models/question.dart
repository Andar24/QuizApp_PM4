import 'dart:math';

/// Model satu soal pilihan ganda (immutable).
class Question {
  const Question({
    required this.text,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  /// Teks pertanyaan.
  final String text;

  /// Daftar pilihan jawaban (selalu 4 pilihan).
  final List<String> options;

  /// Indeks (0-3) pada [options] yang merupakan jawaban benar.
  final int correctIndex;

  /// Penjelasan singkat, ditampilkan di ringkasan hasil (opsional).
  final String? explanation;

  /// Teks dari jawaban yang benar.
  String get correctAnswer => options[correctIndex];

  /// Cek apakah pilihan dengan indeks [optionIndex] benar.
  bool isCorrect(int optionIndex) => optionIndex == correctIndex;

  /// Salinan soal dengan urutan pilihan diacak. [correctIndex] ikut
  /// disesuaikan, sehingga teks jawaban yang benar tetap sama.
  Question shuffled(Random random) {
    final order = List<int>.generate(options.length, (i) => i)
      ..shuffle(random);

    return Question(
      text: text,
      options: [for (final i in order) options[i]],
      correctIndex: order.indexOf(correctIndex),
      explanation: explanation,
    );
  }
}
