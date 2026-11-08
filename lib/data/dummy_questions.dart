import '../models/question.dart';

/// Data soal lokal (tanpa database). Tema: dasar Flutter & Dart.
/// Posisi jawaban benar sengaja dibuat bervariasi.
const List<Question> dummyQuestions = [
  Question(
    text:
        'Widget Flutter yang tampilannya tidak berubah setelah dibuat '
        '(tanpa state internal) disebut...',
    options: [
      'StatefulWidget',
      'StatelessWidget',
      'AnimatedWidget',
      'InheritedWidget',
    ],
    correctIndex: 1,
    explanation: 'StatelessWidget tidak menyimpan state yang berubah.',
  ),
  Question(
    text: 'Flutter menggunakan bahasa pemrograman apa?',
    options: ['Kotlin', 'Swift', 'Dart', 'JavaScript'],
    correctIndex: 2,
    explanation: 'Flutter ditulis dan dikembangkan dengan bahasa Dart.',
  ),
  Question(
    text:
        'Method yang dipanggil untuk memperbarui tampilan ketika state '
        'pada StatefulWidget berubah adalah...',
    options: ['setState()', 'build()', 'initState()', 'dispose()'],
    correctIndex: 0,
    explanation: 'setState() menandai state berubah dan memicu build ulang.',
  ),
  Question(
    text: 'Widget yang menyusun anak-anaknya secara vertikal adalah...',
    options: ['Row', 'Stack', 'Expanded', 'Column'],
    correctIndex: 3,
    explanation: 'Column menyusun child dari atas ke bawah.',
  ),
  Question(
    text:
        'File yang digunakan untuk mendaftarkan dependensi, aset, dan '
        'font pada proyek Flutter adalah...',
    options: [
      'main.dart',
      'pubspec.yaml',
      'AndroidManifest.xml',
      'analysis_options.yaml',
    ],
    correctIndex: 1,
    explanation: 'pubspec.yaml berisi konfigurasi paket, aset, dan font.',
  ),
  Question(
    text:
        'Widget yang membuat anaknya mengisi sisa ruang kosong pada '
        'Row atau Column adalah...',
    options: ['Expanded', 'Padding', 'Container', 'SizedBox'],
    correctIndex: 0,
    explanation: 'Expanded membagi sisa ruang utama kepada child-nya.',
  ),
  Question(
    text:
        'Perintah untuk menjalankan aplikasi Flutter di perangkat atau '
        'emulator adalah...',
    options: [
      'flutter build',
      'flutter clean',
      'flutter run',
      'flutter create',
    ],
    correctIndex: 2,
    explanation: 'flutter run membangun dan menjalankan aplikasi.',
  ),
  Question(
    text:
        'Widget yang digunakan untuk menumpuk satu widget di atas '
        'widget lainnya adalah...',
    options: ['Column', 'Stack', 'ListView', 'Table'],
    correctIndex: 1,
    explanation: 'Stack menumpuk child sesuai urutan (yang terakhir di atas).',
  ),
  Question(
    text:
        'Pada package Provider, class yang menyimpan state dan memanggil '
        'notifyListeners() agar UI diperbarui adalah...',
    options: ['FutureBuilder', 'StreamBuilder', 'ValueKey', 'ChangeNotifier'],
    correctIndex: 3,
    explanation: 'ChangeNotifier memberi tahu listener saat data berubah.',
  ),
  Question(
    text: 'MediaQuery pada Flutter berguna untuk...',
    options: [
      'Menyimpan data ke database',
      'Mengatur font aplikasi',
      'Mendapatkan ukuran dan orientasi layar',
      'Berpindah antar halaman',
    ],
    correctIndex: 2,
    explanation:
        'MediaQuery memberi info ukuran, orientasi, dan padding layar.',
  ),
];
