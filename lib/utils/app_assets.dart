/// Daftar path aset di satu tempat agar tidak ada salah ketik dan mudah dicek.
/// Semua aset dibuat sendiri (SVG), lihat bagian Credit di README.
class AppAssets {
  const AppAssets._();

  // Ikon (assets/icons/)
  static const String logo = 'assets/icons/logo.svg';
  static const String star = 'assets/icons/star.svg';
  static const String lightbulb = 'assets/icons/lightbulb.svg';
  static const String target = 'assets/icons/target.svg';
  static const String clipboard = 'assets/icons/clipboard.svg';
  static const String timer = 'assets/icons/timer.svg';

  // Ilustrasi (assets/illustrations/)
  static const String heroQuiz = 'assets/illustrations/hero_quiz.svg';
  static const String resultChampion =
      'assets/illustrations/result_champion.svg';
  static const String resultGood = 'assets/illustrations/result_good.svg';
  static const String resultKeepGoing =
      'assets/illustrations/result_keep_going.svg';
  static const String confetti = 'assets/illustrations/confetti.svg';

  /// Semua aset, dipakai test untuk memastikan file ada dan valid.
  static const List<String> all = [
    logo,
    star,
    lightbulb,
    target,
    clipboard,
    timer,
    heroQuiz,
    resultChampion,
    resultGood,
    resultKeepGoing,
    confetti,
  ];
}
