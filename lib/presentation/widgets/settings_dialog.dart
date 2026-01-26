import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../providers/theme_provider.dart';
import '../providers/incognito_provider.dart';
import '../../core/services/security_service.dart';
import '../providers/database_providers.dart';
import 'advanced_color_picker.dart';
import '../../core/services/biometric_service.dart';

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

              Text(
                'Privacy & Security',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),

              // Biometric Lock
              ref
                  .watch(biometricEnabledProvider)
                  .when(
                    data: (enabled) => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Bloqueo Biométrico'),
                      subtitle: const Text('Solicitar huella/cara al iniciar'),
                      secondary: const Icon(Icons.fingerprint),
                      value: enabled,
                      onChanged: (val) async {
                        final service = ref.read(biometricServiceProvider);

                        if (val) {
                          // If enabling, verify first!
                          final authenticated = await service.authenticate(
                            reason: 'Confirma para activar',
                          );
                          if (!authenticated) return;
                        }

                        await service.setBiometricEnabled(val);
                        ref.invalidate(biometricEnabledProvider);

                        // If disabling, ensure we don't lock immediately if paused?
                        // No, invalidating updates logic in main.dart eventually?
                        // Main.dart reads settings on pause. It doesn't watch the provider?
                        // I need to make main.dart reactive or check on pause.
                      },
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

              // Incognito Mode
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Modo Incógnito'),
                subtitle: const Text('No guardar historial de requests'),
                secondary: const Icon(Icons.visibility_off),
                value: ref.watch(isIncognitoProvider),
                onChanged: (val) {
                  ref.read(isIncognitoProvider.notifier).set(val);
                },
              ),

              const SizedBox(height: 16),

              // Panic Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  ),
                  onPressed: () => _showPanicDialog(context, ref),
                  icon: const Icon(Icons.warning_amber_rounded),
                  label: const Text('PANIC BUTTON'),
                ),
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
                'Xolo API Client v0.9.0 (Secure)',
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

  void _showPanicDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ EMERGENCIA'),
        content: const Text(
          'Esta acción borrará TODOS los datos sensibles (Historial, Credenciales Seguras) y cerrará la aplicación inmediatamente.\n\n¿Estás seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _performPanicProtocol(context, ref),
            child: const Text('BORRAR TODO'),
          ),
        ],
      ),
    );
  }

  Future<void> _performPanicProtocol(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      // 1. Clear Secure Storage
      await ref.read(securityServiceProvider).clearAll();

      // 2. Clear History (DB)
      final db = ref.read(databaseProvider);
      await db.delete(db.historyEntries).go();
      // Optional: Clear Variables? For now just history/tokens.
      // await db.delete(db.envVariables).go();

      // 3. Exit App
      SystemNavigator.pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Panic Failed: $e')));
    }
  }
}
