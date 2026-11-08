import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Dialog konfirmasi dua tombol yang bisa dipakai ulang.
/// Mengembalikan `true` jika pengguna menekan tombol konfirmasi,
/// `false` jika membatalkan atau menutup dialog.
///
/// [icon] bebas berupa widget (mis. `SvgBadge`) agar dialog tampak hidup.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  Widget? icon,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        icon: icon,
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        // scrollable: dialog tetap aman di layar pendek (landscape).
        scrollable: true,
        actionsAlignment: MainAxisAlignment.center,
        actionsOverflowAlignment: OverflowBarAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
