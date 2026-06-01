import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/services/app_logger.dart';
import 'package:xolo/core/services/biometric_service.dart';
import 'package:xolo/core/services/security_profile_service.dart';
import 'package:xolo/core/services/security_service.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/database_providers.dart';
import 'package:xolo/presentation/providers/incognito_provider.dart';
import 'package:xolo/presentation/providers/theme_provider.dart';
import 'package:xolo/presentation/widgets/advanced_color_picker.dart';

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
      AppLogger.error('Error loading delay', e);
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // Watch providers safely
    final isIncognito = ref.watch(isIncognitoProvider);
    final biometricAsync = ref.watch(biometricEnabledProvider);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: XoloSpacing.lg,
          vertical: XoloSpacing.sm,
        ),
        children: [
          _buildAppearanceCard(context, ref, l10n),

          const SizedBox(height: XoloSpacing.xl),
          _buildSectionTitle(context, l10n.securityAndPrivacy),
          const SizedBox(height: XoloSpacing.sm),

          // Security Group
          _buildSettingsGroup(context, [
            _buildSecurityProfileTile(context, ref, l10n),
            const Divider(height: 1, indent: 64),

            // Biometric
            biometricAsync.when(
              data: (enabled) => SwitchListTile.adaptive(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                title: Text(
                  l10n.biometricLock,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  l10n.biometricLockSubtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                      reason: l10n.verifyToEnableLock,
                    );
                    if (!authenticated) return;
                  }
                  await service.setBiometricEnabled(val);
                  ref.invalidate(biometricEnabledProvider);
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => ListTile(
                title: Text(l10n.authError(e.toString())),
                leading: const Icon(Icons.error, color: Colors.red),
              ),
            ),

            const Divider(height: 1, indent: 64),

            // Lock Delay
            ListTile(
              title: Text(
                l10n.autoLockDelay,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _getDelayLabel(l10n, _lockDelay),
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
                  PopupMenuItem(value: 0, child: Text(l10n.immediately)),
                  PopupMenuItem(value: 30, child: Text(l10n.after30Seconds)),
                  PopupMenuItem(value: 60, child: Text(l10n.after1Minute)),
                  PopupMenuItem(value: 300, child: Text(l10n.after5Minutes)),
                ],
                child: Chip(
                  label: Text(_getDelayLabelShort(l10n, _lockDelay)),
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
              title: Text(
                l10n.incognitoMode,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                l10n.incognitoSubtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
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

          const SizedBox(height: XoloSpacing.xl),
          _buildSectionTitle(context, l10n.dataOwnership),
          const SizedBox(height: XoloSpacing.sm),
          _buildDataOwnershipCard(context, l10n),

          const SizedBox(height: XoloSpacing.xl),
          _buildSectionTitle(context, l10n.dataStorage),
          const SizedBox(height: XoloSpacing.sm),

          _buildSettingsGroup(context, [
            ListTile(
              title: Text(
                l10n.clearHistory,
                style: const TextStyle(fontWeight: FontWeight.w600),
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
                shape: RoundedRectangleBorder(borderRadius: XoloRadius.md),
              ),
              onPressed: () => _showPanicDialog(context, ref),
              icon: const Icon(Icons.warning_amber_rounded),
              label: Text(
                l10n.panicButton,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          Center(
            child: Text(
              l10n.appVersion,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildSecurityProfileTile(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final profileAsync = ref.watch(securityProfileProvider);
    return profileAsync.when(
      data: (profile) {
        return ListTile(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          title: Text(
            l10n.securityProfile,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            _profileDescription(l10n, profile),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_outlined, color: Colors.teal),
          ),
          trailing: DropdownButton<SecurityProfile>(
            value: profile,
            underline: const SizedBox.shrink(),
            onChanged: (value) async {
              if (value == null) return;
              final profileService = ref.read(securityProfileServiceProvider);
              await profileService.setProfile(value);
              final policy = profileService.policyFor(value);
              await _setDelay(policy.recommendedLockDelaySeconds);
              ref.invalidate(securityProfileProvider);
              ref.invalidate(securityPolicyProvider);
            },
            items: SecurityProfile.values
                .map(
                  (p) => DropdownMenuItem(
                    value: p,
                    child: Text(_profileLabel(l10n, p)),
                  ),
                )
                .toList(),
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (e, s) => ListTile(
        title: Text(l10n.securityProfileError(e.toString())),
        leading: const Icon(Icons.error, color: Colors.red),
      ),
    );
  }

  String _profileLabel(AppLocalizations l10n, SecurityProfile profile) {
    return switch (profile) {
      SecurityProfile.standard => l10n.profileStandard,
      SecurityProfile.hardened => l10n.profileHardened,
      SecurityProfile.paranoid => l10n.profileParanoid,
    };
  }

  String _profileDescription(AppLocalizations l10n, SecurityProfile profile) {
    return switch (profile) {
      SecurityProfile.standard => l10n.profileStandardDesc,
      SecurityProfile.hardened => l10n.profileHardenedDesc,
      SecurityProfile.paranoid => l10n.profileParanoidDesc,
    };
  }

  Widget _buildDataOwnershipCard(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: XoloRadius.lg,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.yourDataStaysYours,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: XoloSpacing.sm),
          Text(
            l10n.dataOwnershipDescription1,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: XoloSpacing.sm),
          Text(
            l10n.dataOwnershipDescription2,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
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
        borderRadius: XoloRadius.lg,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildAppearanceCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
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
          borderRadius: XoloRadius.xl,
          border: Border.all(
            color: currentColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette_outlined),
                const SizedBox(width: 8),
                Text(
                  l10n.appTheme,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AdvancedColorPicker(
              currentColor: currentColor,
              onColorChanged: (newColor) {
                ref
                    .read(themeColorProvider.notifier)
                    .setColor(newColor.toARGB32());
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
          l10n.themeWidgetError(e.toString()),
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
  }

  String _getDelayLabel(AppLocalizations l10n, int seconds) {
    if (seconds == 0) return l10n.immediately;
    if (seconds < 60) return l10n.delaySecondsFull(seconds);
    return l10n.delayMinutesFull(seconds ~/ 60);
  }

  String _getDelayLabelShort(AppLocalizations l10n, int seconds) {
    if (seconds == 0) return l10n.delayNow;
    if (seconds < 60) return l10n.delaySeconds(seconds);
    return l10n.delayMinutes(seconds ~/ 60);
  }

  void _showPanicDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.emergencyWipeTitle),
        content: Text(l10n.emergencyWipeMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _performPanicProtocol(context, ref),
            child: Text(l10n.deleteEverything),
          ),
        ],
      ),
    );
  }

  Future<void> _performPanicProtocol(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(securityServiceProvider).clearAll();
      final repo = ref.read(xoloRepositoryProvider);
      await repo.wipeAllLocalData();
      await SystemNavigator.pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.panicFailed(e.toString()))));
    }
  }

  Future<void> _clearHistory(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearHistoryConfirmTitle),
        content: Text(l10n.clearHistoryConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(xoloRepositoryProvider);
      await repo.clearAllHistory();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.historyCleared)));
    }
  }
}
