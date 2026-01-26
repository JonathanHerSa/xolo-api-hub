import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/services/encryption_service.dart';
import '../../data/services/sync_service.dart';
import '../providers/database_providers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

class SyncScreen extends ConsumerStatefulWidget {
  const SyncScreen({super.key});

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Backups & Sync'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Info Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.save_alt_rounded,
                        size: 64,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Secure Local Backup',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Export your collections and history to a secure, encrypted file. Share it to your Drive, Email, or other devices.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                const Text(
                  'ACTIONS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                _buildActionCard(
                  context,
                  title: 'Export Backup',
                  subtitle: 'Create an encrypted .xolo file.',
                  icon: Icons.upload_file,
                  color: Colors.blue,
                  onTap: () => _performExport(context, ref),
                ),
                const SizedBox(height: 16),
                _buildActionCard(
                  context,
                  title: 'Import Backup',
                  subtitle: 'Restore from a .xolo file.',
                  icon: Icons.download_for_offline,
                  color: Colors.green,
                  onTap: () => _performImport(context, ref),
                ),

                const SizedBox(height: 48),
                Center(
                  child: Text(
                    "Cloud Sync coming in v1.0",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
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
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performExport(BuildContext context, WidgetRef ref) async {
    final password = await _promptPassword(
      context,
      'Create Backup Password',
      'This password will be required to restore the file.',
    );
    if (password == null || password.isEmpty) return;
    if (!mounted) return;

    _showSnack(context, 'Generating Backup...', isLoading: true);
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
      if (mounted) _showSnack(context, 'Backup Created!');

      // 4. Share
      await Share.shareXFiles([
        XFile(encryptedFile.path),
      ], text: 'My Xolo API Backup');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(context, e.toString());
      }
    }
  }

  Future<void> _performImport(BuildContext context, WidgetRef ref) async {
    try {
      // 1. Pick File
      final result = await FilePicker.platform.pickFiles();
      if (result == null) return; // User canceled

      final path = result.files.single.path;
      if (path == null) return;

      final file = File(path);

      final password = await _promptPassword(
        context,
        'Enter Decryption Password',
        'Enter the password used to create this backup.',
      );
      if (password == null || password.isEmpty) return;
      if (!mounted) return;

      setState(() => _isLoading = true);
      _showSnack(context, 'Restoring...', isLoading: true);

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
      if (mounted) _showSnack(context, 'Restore Complete!');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(context, 'Restore Failed: Invalid Password or File');
      }
    }
  }

  Future<String?> _promptPassword(
    BuildContext context,
    String title,
    String subtitle,
  ) {
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
              decoration: const InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => val = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, val),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String msg, {bool isLoading = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (isLoading) ...[
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Text(msg),
          ],
        ),
      ),
    );
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }
}
