import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/quiz_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/adaptive_text_scale.dart';

void main() {
  runApp(const QuizApp());
}

/// Root aplikasi. Provider diletakkan DI ATAS MaterialApp supaya state
/// (tema dan progres kuis) tetap hidup walau layar dirotasi
/// atau berpindah halaman.
class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Progres kuis: nama, indeks soal, jawaban, skor, timer, hint, streak.
        // shuffle: urutan soal dan pilihan diacak setiap kuis dimulai.
        ChangeNotifierProvider(create: (_) => QuizProvider(shuffle: true)),
      ],
      // Consumer hanya membangun ulang MaterialApp saat tema berubah.
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'QuizKu',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            // Teks diperbesar otomatis di layar lebar (tablet/web).
            builder: (context, child) => AdaptiveTextScale(child: child!),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
