import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_spacing.dart';
import 'custom_button.dart';

/// Kartu form nama di Home. Stateless: controller dan form key dimiliki oleh
/// HomeScreen (yang men-dispose-nya), kartu ini hanya menampilkan.
class NameFormCard extends StatelessWidget {
  const NameFormCard({
    super.key,
    required this.formKey,
    required this.controller,
    required this.validator,
    required this.onStart,
    required this.onRestart,
    required this.hasProgress,
    required this.answered,
    required this.total,
  });

  /// Batas panjang nama.
  static const int maxNameLength = 30;

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;

  /// Tombol utama / tombol "Done" di keyboard.
  final VoidCallback onStart;

  /// "Mulai dari Awal" (hanya tampil jika [hasProgress]).
  final VoidCallback onRestart;

  final bool hasProgress;
  final int answered;
  final int total;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl - AppSpacing.xs),
        child: Form(
          key: formKey,
          // Error tampil setelah pengguna mulai mengetik / menekan tombol.
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Siapa namamu?',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Masukkan nama untuk memulai kuis. Skor akhir akan '
                'ditampilkan atas namamu.',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: controller,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                inputFormatters: [
                  LengthLimitingTextInputFormatter(maxNameLength),
                ],
                decoration: const InputDecoration(
                  labelText: 'Nama lengkap',
                  hintText: 'Contoh: Budi Santoso',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: validator,
                onFieldSubmitted: (_) => onStart(),
              ),
              const SizedBox(height: AppSpacing.xl - AppSpacing.xs),
              if (hasProgress) ...[
                Text(
                  'Kuis sebelumnya belum selesai ($answered/$total terjawab).',
                  style: textTheme.bodySmall?.copyWith(color: scheme.primary),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              CustomButton(
                label: hasProgress ? 'Lanjutkan Kuis' : 'Mulai Kuis',
                icon: Icons.play_arrow_rounded,
                onPressed: onStart,
              ),
              if (hasProgress) ...[
                const SizedBox(height: AppSpacing.md),
                CustomButton(
                  label: 'Mulai dari Awal',
                  icon: Icons.restart_alt_rounded,
                  variant: CustomButtonVariant.secondary,
                  onPressed: onRestart,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
