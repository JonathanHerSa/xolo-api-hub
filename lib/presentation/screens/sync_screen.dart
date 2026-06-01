import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:xolo/core/services/cloud_sync_service.dart';
import 'package:xolo/core/services/encryption_service.dart';
import 'package:xolo/core/services/security_profile_service.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/data/services/sync_service.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/database_providers.dart';
import 'package:xolo/presentation/widgets/ui/xolo_interactive_card.dart';
import 'package:xolo/presentation/widgets/ui/xolo_section_header.dart';

class SyncScreen extends ConsumerStatefulWidget {
  const SyncScreen({super.key});

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(title: Text(l10n.backupsAndSync)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(XoloSpacing.xl),
              children: [
                Container(
                  padding: const EdgeInsets.all(XoloSpacing.xxl),
                  decoration: XoloSurfaces.panel(
                    colorScheme,
                    borderRadius: XoloRadius.lg,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: XoloRadius.lg,
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Icon(
                          Icons.save_alt_rounded,
                          size: 34,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: XoloSpacing.lg),
                      Text(
                        l10n.secureLocalBackup,
                        style: XoloTypography.cardTitle(colorScheme).copyWith(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: XoloSpacing.sm),
                      Text(
                        l10n.secureBackupDescription,
                        textAlign: TextAlign.center,
                        style: XoloTypography.cardSubtitle(colorScheme),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: XoloSpacing.xxl),
                XoloSectionHeader(
                  title: l10n.actions.toUpperCase(),
                  padding: const EdgeInsets.only(bottom: XoloSpacing.md),
                ),

                _buildActionCard(
                  context,
                  title: l10n.exportBackup,
                  subtitle: l10n.exportBackupSubtitle,
                  icon: Icons.upload_file_outlined,
                  color: colorScheme.primary,
                  onTap: () => _performExport(context, ref),
                ),
                _buildActionCard(
                  context,
                  title: l10n.importBackup,
                  subtitle: l10n.importBackupSubtitle,
                  icon: Icons.download_for_offline_outlined,
                  color: XoloPalette.accentHover,
                  onTap: () => _performImport(context, ref),
                ),

                const SizedBox(height: XoloSpacing.xxl),
                XoloSectionHeader(
                  title: l10n.cloudSync.toUpperCase(),
                  padding: const EdgeInsets.only(bottom: XoloSpacing.md),
                ),
                _CloudSyncSection(
                  onBusyChanged: (busy) => setState(() => _isLoading = busy),
                  askPassword: (title, subtitle) =>
                      _promptPassword(context, title, subtitle),
                ),
              ],
            ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return XoloInteractiveCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: XoloRadius.md,
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: XoloSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: XoloTypography.cardTitle(colorScheme)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: XoloTypography.cardSubtitle(colorScheme),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Future<void> _performExport(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final policy = await ref.read(securityPolicyProvider.future);
    if (!mounted) return;
    if (policy.confirmBeforeExport) {
      if (!context.mounted) return;
      final confirmed = await _confirmHighSecurityExport(context);
      if (confirmed != true) return;
    }

    if (!context.mounted) return;
    final password = await _promptPassword(
      context,
      l10n.createBackupPassword,
      l10n.createBackupPasswordDescription,
    );
    if (password == null || password.isEmpty) return;
    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(l10n.generatingBackup),
          ],
        ),
      ),
    );
    setState(() => _isLoading = true);

    try {
      final syncService = ref.read(syncServiceProvider);
      final db = ref.read(databaseProvider);

      // 1. Export JSON
      final tempDir = await getTemporaryDirectory();
      final file = await syncService.exportFullBackup(
        directoryPath: tempDir.path,
        db: db,
      );

      // 2. Encrypt
      final encryption = ref.read(encryptionServiceProvider);
      final plainBytes = await file.readAsBytes();
      final encryptedBytes = encryption.encryptBytes(plainBytes, password);

      // 3. Save as .xolo file
      final dateStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final filename = 'xolo_backup_$dateStr.xolo';
      final encryptedFile = File(p.join(tempDir.path, filename));
      await encryptedFile.writeAsBytes(encryptedBytes);

      setState(() => _isLoading = false);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.backupCreated)));

      // 4. Share
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(encryptedFile.path)],
          text: l10n.myXoloApiBackup,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        messenger.showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<bool?> _confirmHighSecurityExport(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmSecureExport),
        content: Text(l10n.confirmSecureExportMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.continueAction),
          ),
        ],
      ),
    );
  }

  Future<void> _performImport(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      // 1. Pick File
      final result = await FilePicker.platform.pickFiles();
      if (result == null) return; // User canceled

      final path = result.files.single.path;
      if (path == null) return;

      final file = File(path);

      if (!context.mounted) return;
      final password = await _promptPassword(
        context,
        l10n.enterDecryptionPassword,
        l10n.enterDecryptionPasswordDescription,
      );
      if (password == null || password.isEmpty) return;
      if (!mounted) return;

      setState(() => _isLoading = true);
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(l10n.restoring),
            ],
          ),
        ),
      );

      // 2. Decrypt
      final encryptedBytes = await file.readAsBytes();
      final encryption = ref.read(encryptionServiceProvider);

      // Decrypt Bytes
      final plainBytes = encryption.decryptBytes(encryptedBytes, password);

      final tempDir = await getTemporaryDirectory();
      final tempStartFile = File(p.join(tempDir.path, 'restore_temp.json'));
      await tempStartFile.writeAsBytes(plainBytes);

      // 3. Import
      final syncService = ref.read(syncServiceProvider);
      final db = ref.read(databaseProvider);

      // Safety: This merges/replaces data
      await syncService.importFullBackup(file: tempStartFile, db: db);

      setState(() => _isLoading = false);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.restoreComplete)));
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.restoreFailedInvalidPasswordOrFile),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _promptPassword(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    final l10n = AppLocalizations.of(context)!;
    String val = '';
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.passwordHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => val = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, val),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}

class _CloudSyncSection extends ConsumerStatefulWidget {
  const _CloudSyncSection({
    required this.onBusyChanged,
    required this.askPassword,
  });

  final ValueChanged<bool> onBusyChanged;
  final Future<String?> Function(String title, String subtitle) askPassword;

  @override
  ConsumerState<_CloudSyncSection> createState() => _CloudSyncSectionState();
}

class _CloudSyncSectionState extends ConsumerState<_CloudSyncSection> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.read(cloudSyncServiceProvider).signInSilently().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sync = ref.watch(cloudSyncServiceProvider);
    final user = sync.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    return XoloInteractiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.cloudSyncDescription, style: XoloTypography.cardSubtitle(colorScheme)),
          const SizedBox(height: XoloSpacing.md),
          if (user != null)
            Text(l10n.signedInAs(user.email), style: XoloTypography.meta(colorScheme)),
          const SizedBox(height: XoloSpacing.md),
          if (user == null)
            FilledButton(
              onPressed: () async {
                widget.onBusyChanged(true);
                await sync.signIn();
                if (mounted) setState(() {});
                widget.onBusyChanged(false);
              },
              child: Text(l10n.signInGoogle),
            )
          else ...[
            FilledButton(
              onPressed: () async {
                final password = await widget.askPassword(
                  l10n.createBackupPassword,
                  l10n.createBackupPasswordDescription,
                );
                if (password == null || password.isEmpty) return;
                widget.onBusyChanged(true);
                try {
                  final db = ref.read(databaseProvider);
                  await sync.syncUpload(db: db, password: password);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.syncSuccess)),
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.syncFailed)),
                    );
                  }
                } finally {
                  widget.onBusyChanged(false);
                  if (mounted) setState(() {});
                }
              },
              child: Text(l10n.syncNow),
            ),
            TextButton(
              onPressed: () async {
                await sync.signOut();
                if (mounted) setState(() {});
              },
              child: Text(l10n.signOut),
            ),
          ],
        ],
      ),
    );
  }
}
