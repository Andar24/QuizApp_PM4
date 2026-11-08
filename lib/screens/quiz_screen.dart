import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/quiz_provider.dart';
import '../theme/app_spacing.dart';
import '../utils/app_assets.dart';
import '../utils/haptics.dart';
import '../utils/page_transitions.dart';
import '../utils/responsive.dart';
import '../widgets/answer_option.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/custom_button.dart';
import '../widgets/decorative_background.dart';
import '../widgets/feedback_banner.dart';
import '../widgets/hint_button.dart';
import '../widgets/progress_header.dart';
import '../widgets/question_card.dart';
import '../widgets/question_grid.dart';
import '../widgets/svg_badge.dart';
import '../widgets/theme_toggle_button.dart';
import 'result_screen.dart';

/// Halaman 2: kuis.
///
/// Semua data (indeks soal, jawaban, skor) dibaca dari [QuizProvider] yang
/// berada di atas MaterialApp, sehingga rotasi layar TIDAK mereset progres.
/// StatefulWidget dipakai untuk arah animasi transisi antar-soal dan untuk
/// memegang Timer 1 detik (timer harus di-cancel saat halaman ditutup).
/// Sisa waktu tiap soal sendiri disimpan di provider.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  /// true = maju (Next), false = mundur (Previous). Menentukan arah geser.
  bool _forward = true;

  /// Detak 1 detik untuk hitung mundur soal yang sedang tampil.
  Timer? _timer;

  /// true saat dialog / bottom sheet terbuka: waktu soal berhenti sementara.
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onTick() {
    if (!mounted || _paused) return;
    final quiz = context.read<QuizProvider>();
    final index = quiz.currentIndex;
    final wasTimedOut = quiz.isTimedOutAt(index);

    quiz.tick();

    // Getar sekali tepat saat waktu soal habis.
    if (!wasTimedOut && quiz.isTimedOutAt(index)) Haptics.wrong();
  }

  void _next() {
    setState(() => _forward = true);
    context.read<QuizProvider>().nextQuestion();
  }

  void _previous() {
    setState(() => _forward = false);
    context.read<QuizProvider>().previousQuestion();
  }

  /// Lompat ke soal [index] (dari grid nomor soal) dengan arah animasi yang
  /// sesuai.
  void _goTo(int index) {
    final quiz = context.read<QuizProvider>();
    setState(() => _forward = index > quiz.currentIndex);
    quiz.goToQuestion(index);
  }

  /// Memilih jawaban: simpan ke provider, getar, dan beri tahu jika hint baru
  /// didapat. Dipakai oleh tap pada opsi maupun pintasan keyboard.
  void _answer(int optionIndex) {
    final quiz = context.read<QuizProvider>();
    if (!quiz.canSelect(optionIndex)) return;

    final hintsBefore = quiz.hintsEarned;
    quiz.selectAnswer(optionIndex);

    if (quiz.isCorrectAt(quiz.currentIndex)) {
      Haptics.correct();
    } else {
      Haptics.wrong();
    }

    if (quiz.hintsEarned > hintsBefore) {
      Haptics.reward();
      _showMessage(
        'Hint baru didapat! Ketuk ikon bohlam di kanan atas untuk memakainya.',
      );
    }
  }

  /// Pakai hint pada soal yang sedang tampil, atau jelaskan kenapa belum bisa.
  void _useHint() {
    final quiz = context.read<QuizProvider>();
    if (quiz.useHint()) {
      Haptics.reward();
      return;
    }
    _showMessage(_hintUnavailableReason(quiz));
  }

  String _hintUnavailableReason(QuizProvider quiz) {
    final index = quiz.currentIndex;
    if (quiz.hintsAvailable <= 0) {
      return 'Belum ada hint. Jawab ${quiz.correctUntilNextHint} soal lagi '
          'dengan benar untuk mendapat 1 hint.';
    }
    if (quiz.isTimedOutAt(index)) return 'Waktu soal ini sudah habis.';
    if (quiz.isAnsweredAt(index)) {
      return 'Soal ini sudah dijawab. Pakai hint sebelum menjawab.';
    }
    return 'Hint sudah dipakai pada soal ini.';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  QuestionDotStatus _dotStatus(QuizProvider quiz, int index) {
    if (quiz.isTimedOutAt(index)) return QuestionDotStatus.timedOut;
    if (!quiz.isAnsweredAt(index)) return QuestionDotStatus.unanswered;
    return quiz.isCorrectAt(index)
        ? QuestionDotStatus.correct
        : QuestionDotStatus.wrong;
  }

  /// Buka grid nomor soal; waktu berhenti selama sheet terbuka.
  Future<void> _openGrid() async {
    final quiz = context.read<QuizProvider>();
    final statuses = [
      for (var i = 0; i < quiz.totalQuestions; i++) _dotStatus(quiz, i),
    ];

    _paused = true;
    final picked = await showQuestionGridSheet(
      context,
      statuses: statuses,
      currentIndex: quiz.currentIndex,
    );
    _paused = false;

    if (picked != null && mounted) _goTo(picked);
  }

  /// Dialog konfirmasi sebelum submit; jika setuju, pindah ke halaman hasil.
  Future<void> _submit() async {
    final quiz = context.read<QuizProvider>();
    final unanswered = quiz.unansweredCount;

    // Waktu soal berhenti selama dialog terbuka.
    _paused = true;
    final confirmed = await showConfirmDialog(
      context,
      // Ukuran dihitung dari lebar layar (dialog tidak boleh memakai
      // LayoutBuilder karena menghitung ukuran intrinsik).
      icon: SvgBadge(
        asset: AppAssets.target,
        size: (MediaQuery.sizeOf(context).width * 0.14).clamp(48.0, 72.0),
      ),
      title: 'Selesaikan kuis?',
      message: unanswered > 0
          ? 'Masih ada $unanswered soal yang belum dijawab. '
                'Soal tersebut dihitung salah.'
          : 'Semua soal sudah dijawab. Kirim jawaban dan lihat skormu?',
      confirmLabel: 'Ya, selesai',
      cancelLabel: 'Periksa lagi',
    );

    _paused = false;

    if (!confirmed || !mounted) return;
    // pushReplacement: tombol back dari hasil tidak kembali ke kuis.
    Navigator.of(context).pushReplacement(fadeSlideRoute(const ResultScreen()));
  }

  /// Pintasan keyboard untuk web/desktop:
  /// panah kiri/kanan = Previous/Next, tombol A-D atau 1-4 = pilih jawaban,
  /// H = pakai hint, G = buka grid nomor soal.
  Map<ShortcutActivator, VoidCallback> _keyboardShortcuts() {
    final quiz = context.read<QuizProvider>();

    void selectOption(int index) => _answer(index);

    return {
      const SingleActivator(LogicalKeyboardKey.keyH): _useHint,
      const SingleActivator(LogicalKeyboardKey.keyG): () => _openGrid(),
      const SingleActivator(LogicalKeyboardKey.arrowRight): () {
        if (!quiz.isLastQuestion) _next();
      },
      const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
        if (!quiz.isFirstQuestion) _previous();
      },
      const SingleActivator(LogicalKeyboardKey.keyA): () => selectOption(0),
      const SingleActivator(LogicalKeyboardKey.keyB): () => selectOption(1),
      const SingleActivator(LogicalKeyboardKey.keyC): () => selectOption(2),
      const SingleActivator(LogicalKeyboardKey.keyD): () => selectOption(3),
      const SingleActivator(LogicalKeyboardKey.digit1): () => selectOption(0),
      const SingleActivator(LogicalKeyboardKey.digit2): () => selectOption(1),
      const SingleActivator(LogicalKeyboardKey.digit3): () => selectOption(2),
      const SingleActivator(LogicalKeyboardKey.digit4): () => selectOption(3),
    };
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();

    return CallbackShortcuts(
      bindings: _keyboardShortcuts(),
      // autofocus: pintasan langsung aktif tanpa perlu klik dulu.
      child: Focus(autofocus: true, child: _buildScaffold(quiz)),
    );
  }

  Widget _buildScaffold(QuizProvider quiz) {
    return DecorativeBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(quiz),
        body: _buildBody(quiz),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(QuizProvider quiz) {
    return AppBar(
      title: Text(
        'Kuis: ${quiz.userName}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        HintButton(available: quiz.hintsAvailable, onPressed: _useHint),
        IconButton(
          tooltip: 'Daftar soal',
          onPressed: _openGrid,
          icon: const Icon(Icons.grid_view_rounded),
        ),
        const ThemeToggleButton(),
      ],
    );
  }

  Widget _buildBody(QuizProvider quiz) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = Responsive.useTwoColumns(MediaQuery.sizeOf(context));
          final horizontalPadding = Responsive.pagePadding(
            constraints.maxWidth,
          );

          return Center(
            child: ConstrainedBox(
              // Batasi lebar konten & pusatkan di layar lebar (tablet/web).
              constraints: BoxConstraints(
                maxWidth: isWide
                    ? Responsive.twoColumnMaxWidth
                    : Responsive.singleColumnMaxWidth,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  AppSpacing.xs,
                  horizontalPadding,
                  AppSpacing.md,
                ),
                child: Column(
                  children: [
                    ProgressHeader(
                      current: quiz.currentIndex + 1,
                      total: quiz.totalQuestions,
                      answered: quiz.answeredCount,
                      secondsLeft: quiz.secondsLeftAt(quiz.currentIndex),
                      timerRunning:
                          !quiz.isAnsweredAt(quiz.currentIndex) &&
                          !quiz.isTimedOutAt(quiz.currentIndex),
                      streak: quiz.streak,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Expanded: area soal mengisi sisa tinggi layar.
                    Expanded(child: _buildAnimatedQuestion(quiz, isWide)),
                    const SizedBox(height: AppSpacing.md),
                    _NavigationBar(
                      isFirst: quiz.isFirstQuestion,
                      isLast: quiz.isLastQuestion,
                      onPrevious: _previous,
                      onNext: _next,
                      onSubmit: _submit,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Animasi transisi antar-soal: geser + fade sesuai arah navigasi.
  Widget _buildAnimatedQuestion(QuizProvider quiz, bool isWide) {
    final index = quiz.currentIndex;

    return AnimatedSwitcher(
      duration: AppMotion.normal,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) =>
          Stack(fit: StackFit.expand, children: [...previous, ?current]),
      transitionBuilder: (child, animation) {
        final isIncoming = child.key == ValueKey<int>(index);
        final dx = _forward ? 0.12 : -0.12;
        // Halaman masuk datang dari sisi arah gerak; halaman keluar
        // pergi ke sisi sebaliknya.
        final begin = Offset(isIncoming ? dx : -dx, 0);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: begin,
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      // key = indeks soal -> AnimatedSwitcher tahu kapan harus beranimasi.
      child: _QuestionPage(
        key: ValueKey<int>(index),
        index: index,
        isWide: isWide,
        onAnswer: _answer,
      ),
    );
  }
}

/// Isi satu soal: kartu pertanyaan, 4 opsi, dan banner feedback.
class _QuestionPage extends StatelessWidget {
  const _QuestionPage({
    super.key,
    required this.index,
    required this.isWide,
    required this.onAnswer,
  });

  final int index;
  final bool isWide;

  /// Dipanggil saat pengguna memilih opsi (indeks pilihan).
  final ValueChanged<int> onAnswer;

  static const _labels = ['A', 'B', 'C', 'D'];

  /// Ruang di sekitar konten agar bayangan kartu/opsi tidak terpotong
  /// oleh area scroll.
  static const _scrollPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.sm,
    vertical: AppSpacing.xs,
  );

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final question = quiz.questions[index];
    final selected = quiz.selectedAnswerAt(index);
    final timedOut = quiz.isTimedOutAt(index);
    final eliminated = quiz.eliminatedAt(index);
    // Halaman yang sedang keluar (animasi) tidak boleh menerima tap.
    final isCurrent = index == quiz.currentIndex;

    final questionCard = QuestionCard(number: index + 1, text: question.text);

    final options = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < question.options.length; i++) ...[
          AnswerOption(
            label: _labels[i],
            text: question.options[i],
            // Waktu habis: jawaban benar ditunjukkan, pilihan lain diredupkan.
            status: timedOut
                ? (i == question.correctIndex
                      ? AnswerStatus.revealed
                      : AnswerStatus.idle)
                : AnswerStatus.resolve(
                    optionIndex: i,
                    correctIndex: question.correctIndex,
                    selectedIndex: selected,
                    eliminated: eliminated.contains(i),
                  ),
            // null = nonaktif; terkunci setelah dipilih, waktu habis, atau
            // pilihan dicoret hint.
            onTap:
                selected == null &&
                    !timedOut &&
                    isCurrent &&
                    !eliminated.contains(i)
                ? () => onAnswer(i)
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );

    // AnimatedSize: banner muncul dengan transisi halus.
    final feedback = AnimatedSize(
      duration: AppMotion.fast,
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: selected == null && !timedOut
          ? const SizedBox(width: double.infinity)
          : FeedbackBanner(
              isCorrect: selected != null && question.isCorrect(selected),
              timedOut: timedOut,
              correctAnswer: question.correctAnswer,
              explanation: question.explanation,
            ),
    );

    if (isWide) {
      // Layar lebar/landscape: soal di kiri, opsi di kanan; masing-masing
      // bisa di-scroll sendiri sehingga tidak pernah overflow.
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: _scrollPadding,
              child: questionCard,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: SingleChildScrollView(
              padding: _scrollPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [options, feedback],
              ),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      padding: _scrollPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          questionCard,
          const SizedBox(height: AppSpacing.lg),
          options,
          feedback,
        ],
      ),
    );
  }
}

/// Tombol Previous / Next (atau Selesai di soal terakhir).
class _NavigationBar extends StatelessWidget {
  const _NavigationBar({
    required this.isFirst,
    required this.isLast,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
  });

  final bool isFirst;
  final bool isLast;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            label: 'Previous',
            icon: Icons.arrow_back_rounded,
            variant: CustomButtonVariant.secondary,
            onPressed: isFirst ? null : onPrevious,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: isLast
              ? CustomButton(
                  label: 'Selesai',
                  icon: Icons.check_rounded,
                  iconAtEnd: true,
                  onPressed: onSubmit,
                )
              : CustomButton(
                  label: 'Next',
                  icon: Icons.arrow_forward_rounded,
                  iconAtEnd: true,
                  onPressed: onNext,
                ),
        ),
      ],
    );
  }
}
