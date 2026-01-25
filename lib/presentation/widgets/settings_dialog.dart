import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

import 'advanced_color_picker.dart';

class SettingsDialog extends ConsumerWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentColorInt = ref.watch(themeColorProvider);
    final currentColor = Color(currentColorInt);
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Theme Settings'),
      content: SizedBox(
        width: 320, // Un poco más ancho para los sliders
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Accent Color',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Custom Color Picker
              AdvancedColorPicker(
                currentColor: currentColor,
                onColorChanged: (newColor) {
                  // Actualizar en tiempo real para efecto WOW
                  ref
                      .read(themeColorProvider.notifier)
                      .setColor(newColor.value);
                },
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              const Text(
                'App Info',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Xolo API Client v0.8.1 (Premium)',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
