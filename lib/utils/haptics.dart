import 'dart:async';

import 'package:flutter/services.dart';

/// Getaran ringan sebagai umpan balik. Hanya terasa di perangkat yang
/// mendukungnya (ponsel); di web/desktop/test tidak berpengaruh dan error
/// platform diabaikan agar tidak pernah mengganggu alur kuis.
class Haptics {
  const Haptics._();

  /// Jawaban benar.
  static void correct() => _run(HapticFeedback.lightImpact);

  /// Jawaban salah atau waktu habis.
  static void wrong() => _run(HapticFeedback.heavyImpact);

  /// Hint diperoleh atau dipakai.
  static void reward() => _run(HapticFeedback.mediumImpact);

  static void _run(Future<void> Function() action) {
    unawaited(_safely(action));
  }

  static Future<void> _safely(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Sengaja diabaikan: getaran hanya pelengkap.
    }
  }
}
