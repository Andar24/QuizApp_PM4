import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/question.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_spacing.dart';
import '../utils/page_transitions.dart';
import '../utils/responsive.dart';
import '../utils/score_feedback.dart';
import '../widgets/answer_summary_tile.dart';
import '../widgets/custom_button.dart';
import '../widgets/decorative_background.dart';
import '../widgets/result_bonus_row.dart';
import '../widgets/result_stats_row.dart';
import '../widgets/score_card.dart';
import '../widgets/theme_toggle_button.dart';
import 'quiz_screen.dart';

/// Halaman 3: skor akhir, pesan sesuai skor, ringkasan benar/salah,
/// dan tombol ulangi kuis.
///
/// Data hasil di-"foto" (snapshot) dari [QuizProvider] sekali saat halaman
/// dibuka. Dengan begitu tampilan tidak berkedip jadi skor 0 ketika kuis
/// direset saat animasi pindah halaman masih berjalan.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final String _userName;
  late final int _score;
  late final List<Question> _questions;
  late final List<int?> _answers;
  late final int _bestStreak;
  late final int _hintsUsed;

  @override
  void initState() {
    super.initState();
    final quiz = context.read<QuizProvider>();
    _userName = quiz.userName;
    _score = quiz.score;
    _questions = List.of(quiz.questions);
    _answers = List.of(quiz.answers);
    _bestStreak = quiz.bestStreak;
    _hintsUsed = quiz.hintsUsed;
  }

  int get _total => _questions.length;
  int get _answeredCount => _answers.where((a) => a != null).length;
  int get _wrongCount => _answeredCount - _score;
  int get _unansweredCount => _total - _answeredCount;
  int get _percent => (_score * 100 / _total).round();

  /// Ulangi kuis: reset progres (nama tetap) lalu buka halaman kuis lagi.
  void _retryQuiz() {
    context.read<QuizProvider>().restartQuiz();
    Navigator.of(context).pushReplacement(fadeSlideRoute(const QuizScreen()));
  }

  /// Kembali ke Home. Progres direset supaya Home tidak menawarkan
  /// "Lanjutkan" untuk kuis yang sudah selesai.
  void _backToHome() {
    context.read<QuizProvider>().restartQuiz();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // PopScope: tombol back sistem diarahkan ke _backToHome().
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToHome();
      },
      child: DecorativeBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Hasil Kuis'),
            automaticallyImplyLeading: false,
            actions: const [ThemeToggleButton()],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = Responsive.useTwoColumns(
                  MediaQuery.sizeOf(context),
                );
                final padding = Responsive.pagePadding(constraints.maxWidth);

                if (isWide) {
                  // Dua kolom: skor & tombol di kiri, ringkasan di kanan.
                  // Masing-masing kolom punya scroll sendiri.
                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: Responsive.twoColumnMaxWidth,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(padding),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: _scrollPadding,
                                child: _buildScoreSection(context),
                              ),
                            ),
                            SizedBox(width: padding),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: _scrollPadding,
                                child: _buildSummarySection(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.all(padding),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: Responsive.singleColumnMaxWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildScoreSection(context),
                          const SizedBox(height: AppSpacing.xl),
                          _buildSummarySection(context),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Ruang di sekitar konten agar bayangan kartu tidak terpotong area scroll.
  static const _scrollPadding = EdgeInsets.all(AppSpacing.sm);

  /// Kartu skor, statistik, dan tombol aksi.
  Widget _buildScoreSection(BuildContext context) {
    final feedback = ScoreFeedback.fromPercent(_percent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScoreCard(
          userName: _userName,
          score: _score,
          total: _total,
          message: feedback.message,
          illustrationAsset: feedback.illustrationAsset,
        ),
        const SizedBox(height: AppSpacing.lg),
        ResultStatsRow(
          correct: _score,
          wrong: _wrongCount,
          unanswered: _unansweredCount,
        ),
        const SizedBox(height: AppSpacing.md),
        ResultBonusRow(bestStreak: _bestStreak, hintsUsed: _hintsUsed),
        const SizedBox(height: AppSpacing.xl - AppSpacing.xs),
        CustomButton(
          label: 'Ulangi Kuis',
          icon: Icons.replay_rounded,
          onPressed: _retryQuiz,
        ),
        const SizedBox(height: AppSpacing.md),
        CustomButton(
          label: 'Kembali ke Beranda',
          icon: Icons.home_rounded,
          variant: CustomButtonVariant.secondary,
          onPressed: _backToHome,
        ),
      ],
    );
  }

  /// Daftar ringkasan jawaban benar/salah untuk setiap soal.
  Widget _buildSummarySection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Ringkasan Jawaban',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < _questions.length; i++) ...[
          _buildTile(i),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  Widget _buildTile(int index) {
    final question = _questions[index];
    final selected = _answers[index];

    return AnswerSummaryTile(
      number: index + 1,
      question: question.text,
      isCorrect: selected != null && question.isCorrect(selected),
      selectedAnswer: selected == null ? null : question.options[selected],
      correctAnswer: question.correctAnswer,
      explanation: question.explanation,
    );
  }
}
