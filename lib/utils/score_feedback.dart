import 'app_assets.dart';

/// Pesan dan ilustrasi yang ditampilkan di halaman hasil, sesuai persentase
/// skor. Ada 5 tingkat pesan dan 3 ilustrasi (juara / bagus / semangat lagi).
class ScoreFeedback {
  const ScoreFeedback({required this.message, required this.illustrationAsset});

  final String message;
  final String illustrationAsset;

  /// Menentukan umpan balik dari persentase skor (0 - 100).
  factory ScoreFeedback.fromPercent(int percent) {
    if (percent >= 100) {
      return const ScoreFeedback(
        message: 'Sempurna! Kamu menguasai semua materi.',
        illustrationAsset: AppAssets.resultChampion,
      );
    }
    if (percent >= 80) {
      return const ScoreFeedback(
        message: 'Luar biasa! Pemahamanmu sangat baik.',
        illustrationAsset: AppAssets.resultChampion,
      );
    }
    if (percent >= 60) {
      return const ScoreFeedback(
        message: 'Bagus! Sedikit lagi menuju sempurna.',
        illustrationAsset: AppAssets.resultGood,
      );
    }
    if (percent >= 40) {
      return const ScoreFeedback(
        message: 'Lumayan. Pelajari lagi materinya, ya!',
        illustrationAsset: AppAssets.resultKeepGoing,
      );
    }
    return const ScoreFeedback(
      message: 'Jangan menyerah! Ulangi kuis dan coba lagi.',
      illustrationAsset: AppAssets.resultKeepGoing,
    );
  }
}
