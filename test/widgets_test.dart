import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quizapp/data/dummy_questions.dart';
import 'package:quizapp/widgets/answer_option.dart';
import 'package:quizapp/widgets/answer_summary_tile.dart';
import 'package:quizapp/utils/app_assets.dart';
import 'package:quizapp/widgets/app_illustration.dart';
import 'package:quizapp/widgets/brand_logo.dart';
import 'package:quizapp/widgets/custom_button.dart';
import 'package:quizapp/widgets/decorative_background.dart';
import 'package:quizapp/widgets/feedback_banner.dart';
import 'package:quizapp/widgets/home_hero.dart';
import 'package:quizapp/widgets/info_chip.dart';
import 'package:quizapp/widgets/progress_header.dart';
import 'package:quizapp/widgets/question_card.dart';
import 'package:quizapp/widgets/result_stats_row.dart';
import 'package:quizapp/widgets/score_card.dart';
import 'package:quizapp/widgets/star_rating.dart';
import 'package:quizapp/widgets/svg_badge.dart';
import 'package:quizapp/widgets/svg_icon.dart';

import 'test_helpers.dart';

void main() {
  group('AnswerStatus.resolve', () {
    AnswerStatus status(int option, int? selected) => AnswerStatus.resolve(
      optionIndex: option,
      correctIndex: 2,
      selectedIndex: selected,
    );

    test('idle jika belum ada jawaban', () {
      expect(status(1, null), AnswerStatus.idle);
    });

    test('correct / wrong / revealed', () {
      // Pengguna memilih yang benar.
      expect(status(2, 2), AnswerStatus.correct);
      expect(status(0, 2), AnswerStatus.idle);

      // Pengguna memilih yang salah: pilihannya merah, yang benar ditunjukkan.
      expect(status(0, 0), AnswerStatus.wrong);
      expect(status(2, 0), AnswerStatus.revealed);
      expect(status(1, 0), AnswerStatus.idle);
    });
  });

  group('Reusable widgets tidak overflow', () {
    final question = dummyQuestions.first;

    for (final entry in testScreenSizes.entries) {
      testWidgets(entry.key, (tester) async {
        setScreenSize(tester, entry.value);
        // Simulasi font sistem diperbesar.
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await tester.pumpWidget(
          wrapWithApp(
            DecorativeBackground(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const BrandLogo(),
                      const HomeHero(total: 10),
                      const SvgBadge(asset: AppAssets.lightbulb),
                      const AppIllustration(asset: AppAssets.resultGood),
                      const Wrap(
                        children: [
                          InfoChip(
                            leading: SvgIcon(AppAssets.timer),
                            label: 'Tanpa waktu',
                          ),
                        ],
                      ),
                      const StarRating(filled: 2),
                      const ResultStatsRow(correct: 7, wrong: 2, unanswered: 1),
                      FeedbackBanner(
                        isCorrect: false,
                        correctAnswer: question.correctAnswer,
                        explanation: question.explanation,
                      ),
                      const ProgressHeader(current: 3, total: 10, answered: 2),
                      QuestionCard(number: 1, text: question.text),
                      for (var i = 0; i < 4; i++)
                        AnswerOption(
                          label: 'ABCD'[i],
                          text: question.options[i],
                          status: AnswerStatus.values[i],
                          onTap: () {},
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              label: 'Previous',
                              icon: Icons.arrow_back_rounded,
                              variant: CustomButtonVariant.secondary,
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              label: 'Next',
                              icon: Icons.arrow_forward_rounded,
                              iconAtEnd: true,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      AnswerSummaryTile(
                        number: 1,
                        question: question.text,
                        isCorrect: false,
                        correctAnswer: question.correctAnswer,
                        explanation: question.explanation,
                      ),
                      const ScoreCard(
                        userName: 'Nama Yang Sangat Panjang Sekali Untuk Uji',
                        score: 8,
                        total: 10,
                        message: 'Luar biasa! Pemahamanmu sangat baik.',
                        illustrationAsset: AppAssets.resultChampion,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
