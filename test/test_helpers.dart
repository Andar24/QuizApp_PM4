import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:quizapp/providers/quiz_provider.dart';
import 'package:quizapp/providers/theme_provider.dart';
import 'package:quizapp/theme/app_theme.dart';
import 'package:quizapp/widgets/adaptive_text_scale.dart';

/// Membungkus [home] dengan provider + tema seperti di aplikasi asli.
Widget wrapWithApp(Widget home, {QuizProvider? quiz}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider<QuizProvider>.value(value: quiz ?? QuizProvider()),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      builder: (context, child) => AdaptiveTextScale(child: child!),
      home: home,
    ),
  );
}

/// QuizProvider baru dengan nama pengguna 'Budi'.
QuizProvider newQuiz() => QuizProvider()..setUserName('Budi');

/// Scroll [text] ke area terlihat lalu tap (aman di layar kecil).
Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Ukuran layar yang dipakai untuk tes overflow.
const testScreenSizes = <String, Size>{
  'ponsel portrait': Size(320, 568),
  'ponsel landscape': Size(800, 360),
  'ponsel kecil landscape': Size(568, 320),
  'tablet portrait': Size(820, 1180),
  'tablet landscape': Size(1180, 820),
  'web': Size(1400, 900),
  'web ultrawide': Size(2560, 1080),
  'web jendela sempit': Size(500, 1000),
};

/// Mengatur ukuran layar test (1 piksel logis = 1 piksel fisik).
void setScreenSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
