import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/security_service.dart';
import '../providers/theme_provider.dart';
import '../providers/incognito_provider.dart';
import '../providers/database_providers.dart';
import '../widgets/advanced_color_picker.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _lockDelay = 30;

  @override
  void initState() {
    super.initState();
    _loadDelay();
  }

  Future<void> _loadDelay() async {
    try {
      final service = ref.read(biometricServiceProvider);
      final delay = await service.getLockDelay();
      if (mounted) {
        setState(() {
          _lockDelay = delay;
        });
      }
    } catch (e) {
      debugPrint("Error loading delay: $e");
    }
  }

  Future<void> _setDelay(int seconds) async {
    final service = ref.read(biometricServiceProvider);
    await service.setLockDelay(seconds);
    setState(() {
      _lockDelay = seconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Watch providers safely
    final isIncognito = ref.watch(isIncognitoProvider);
    final biometricAsync = ref.watch(biometricEnabledProvider);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildAppearanceCard(context, ref),

          const SizedBox(height: 24),
          _buildSectionTitle(context, 'SECURITY & PRIVACY'),
          const SizedBox(height: 8),

          // Security Group
          _buildSettingsGroup(context, [
            // Biometric
            biometricAsync.when(
              data: (enabled) => SwitchListTile.adaptive(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                title: const Text(
                  'Biometric Lock',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Require FaceID/Fingerprint to open',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fingerprint, color: Colors.blue),
                ),
                value: enabled,
                onChanged: (val) async {
                  final service = ref.read(biometricServiceProvider);
                  if (val) {
                    final authenticated = await service.authenticate(
                      reason: 'Verify to enable lock',
                    );
                    if (!authenticated) return;
                  }
                  await service.setBiometricEnabled(val);
                  ref.invalidate(biometricEnabledProvider);
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => ListTile(
                title: Text("Auth Error: $e"),
                leading: const Icon(Icons.error, color: Colors.red),
              ),
            ),

            const Divider(height: 1, indent: 64),

            // Lock Delay
            ListTile(
              title: const Text(
                'Auto-Lock Delay',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _getDelayLabel(_lockDelay),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.timer_outlined, color: Colors.orange),
              ),
              trailing: PopupMenuButton<int>(
                initialValue: _lockDelay,
                onSelected: _setDelay,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 0, child: Text('Immediately')),
                  const PopupMenuItem(
                    value: 30,
                    child: Text('After 30 seconds'),
                  ),
                  const PopupMenuItem(value: 60, child: Text('After 1 minute')),
                  const PopupMenuItem(
                    value: 300,
                    child: Text('After 5 minutes'),
                  ),
                ],
                child: Chip(
                  label: Text(_getDelayLabelShort(_lockDelay)),
                  backgroundColor: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  side: BorderSide.none,
                ),
              ),
            ),

            const Divider(height: 1, indent: 64),

            // Incognito
            SwitchListTile.adaptive(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              title: const Text(
                'Incognito Mode',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Do not save history',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.visibility_off, color: Colors.purple),
              ),
              value: isIncognito,
              onChanged: (val) {
                ref.read(isIncognitoProvider.notifier).set(val);
              },
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionTitle(context, 'DATA & STORAGE'),
          const SizedBox(height: 8),

          _buildSettingsGroup(context, [
            ListTile(
              title: const Text(
                'Clear History',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline, color: Colors.red),
              ),
              onTap: () => _clearHistory(context, ref),
            ),
          ]),

          // Panic Button (Standalone)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error.withValues(alpha: 0.1),
                foregroundColor: colorScheme.error,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _showPanicDialog(context, ref),
              icon: const Icon(Icons.warning_amber_rounded),
              label: const Text(
                'EMERGENCY WIPE (PANIC BUTTON)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const Center(
            child: Text(
              'Xolo API Client v0.9.5',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Group container for IOS-style settings
  Widget _buildSettingsGroup(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildAppearanceCard(BuildContext context, WidgetRef ref) {
    try {
      final currentColorInt = ref.watch(themeColorProvider);
      final currentColor = Color(currentColorInt);

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              currentColor.withValues(alpha: 0.2),
              currentColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: currentColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.palette_outlined),
                SizedBox(width: 8),
                Text(
                  "App Theme",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AdvancedColorPicker(
              currentColor: currentColor,
              onColorChanged: (newColor) {
                ref.read(themeColorProvider.notifier).setColor(newColor.value);
              },
            ),
          ],
        ),
      );
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.red.withValues(alpha: 0.1),
        child: Text(
          "Theme Widget Error: $e",
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
  }

  String _getDelayLabel(int seconds) {
    if (seconds == 0) return 'Immediately';
    if (seconds < 60) return '$seconds seconds';
    return '${seconds ~/ 60} minute(s)';
  }

  String _getDelayLabelShort(int seconds) {
    if (seconds == 0) return 'Now';
    if (seconds < 60) return '${seconds}s';
    return '${seconds ~/ 60}m';
  }

  void _showPanicDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ EMERGENCY WIPE'),
        content: const Text(
          'This will permanently delete ALL history, secure keys, and local data.\n\nThe app will close immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _performPanicProtocol(context, ref),
            child: const Text('DELETE EVERYTHING'),
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
      await ref.read(securityServiceProvider).clearAll();
      final db = ref.read(databaseProvider);
      await db.delete(db.historyEntries).go();
      SystemNavigator.pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _clearHistory(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to delete all request history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(databaseProvider);
      await db.delete(db.historyEntries).go();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('History cleared')));
      }
    }
  }
}
