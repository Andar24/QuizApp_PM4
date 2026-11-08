import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/quiz_provider.dart';
import '../theme/app_spacing.dart';
import '../utils/page_transitions.dart';
import '../utils/responsive.dart';
import '../widgets/decorative_background.dart';
import '../widgets/home_hero.dart';
import '../widgets/name_form_card.dart';
import '../widgets/theme_toggle_button.dart';
import 'quiz_screen.dart';

/// Halaman 1: input nama + tombol mulai.
///
/// StatefulWidget karena memegang TextEditingController dan FormKey
/// (state lokal yang harus di-dispose). Sedangkan data yang harus
/// bertahan (nama & progres) disimpan di QuizProvider.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // Isi ulang nama dari provider, jadi tidak hilang saat kembali ke Home.
    _nameController = TextEditingController(
      text: context.read<QuizProvider>().userName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Validasi nama: tidak boleh kosong / hanya spasi.
  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Nama tidak boleh kosong';
    if (name.length < 2) return 'Nama minimal 2 karakter';
    return null;
  }

  /// Simpan nama ke provider lalu pindah ke halaman kuis.
  /// [fresh] = true -> paksa mulai dari awal (abaikan progres lama).
  void _startQuiz({bool fresh = false}) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final quiz = context.read<QuizProvider>();
    final name = _nameController.text.trim();
    // Nama berbeda berarti pengguna baru, jadi progres lama tidak dilanjutkan.
    final isNewUser = name != quiz.userName;

    quiz.setUserName(name);
    // Tanpa progres berarti kuis baru: mulai dari awal (dan soal diacak ulang).
    if (fresh || isNewUser || !quiz.hasProgress) quiz.restartQuiz();

    FocusScope.of(context).unfocus();
    Navigator.of(context).push(fadeSlideRoute(const QuizScreen()));
  }

  @override
  Widget build(BuildContext context) {
    // select: hanya rebuild bila nilai yang dipilih berubah.
    final answered = context.select<QuizProvider, int>((q) => q.answeredCount);
    final total = context.select<QuizProvider, int>((q) => q.totalQuestions);
    // Progres dianggap ada selama ada jawaban atau soal yang waktunya habis.
    // Setelah submit, progres di-reset, jadi kuis yang sudah selesai tidak
    // ditawari "Lanjutkan".
    final hasProgress = context.select<QuizProvider, bool>(
      (q) => q.hasProgress,
    );

    return DecorativeBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(actions: const [ThemeToggleButton()]),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Aturan responsive terpusat di Responsive (utils/responsive.dart).
              final isWide = Responsive.useTwoColumns(
                MediaQuery.sizeOf(context),
              );
              final horizontalPadding = Responsive.pagePadding(
                constraints.maxWidth,
              );

              final hero = HomeHero(total: total, isWide: isWide);
              final form = NameFormCard(
                formKey: _formKey,
                controller: _nameController,
                validator: _validateName,
                onStart: _startQuiz,
                onRestart: () => _startQuiz(fresh: true),
                hasProgress: hasProgress,
                answered: answered,
                total: total,
              );

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: AppSpacing.lg,
                ),
                // minHeight = tinggi layar, supaya konten tetap di tengah
                // namun bisa di-scroll saat layar pendek (landscape/keyboard).
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: math.max(
                      0,
                      constraints.maxHeight - AppSpacing.xxl,
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWide
                            ? Responsive.twoColumnMaxWidth
                            : Responsive.singleColumnMaxWidth,
                      ),
                      child: isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(child: hero),
                                SizedBox(width: horizontalPadding),
                                Expanded(child: form),
                              ],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                hero,
                                const SizedBox(height: AppSpacing.xl),
                                form,
                              ],
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
