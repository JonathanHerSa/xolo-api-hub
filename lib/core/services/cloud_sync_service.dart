import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:xolo/core/services/app_logger.dart';
import 'package:xolo/core/services/cloud_service.dart';
import 'package:xolo/core/services/encryption_service.dart';
import 'package:xolo/data/local/database.dart';
import 'package:xolo/domain/repositories/xolo_repository.dart';
import 'package:xolo/presentation/providers/database_providers.dart';

final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  return CloudSyncService(
    ref.watch(cloudServiceProvider),
    ref.watch(xoloRepositoryProvider),
    ref.watch(encryptionServiceProvider),
  );
});

/// On-demand Google Drive sync for encrypted workspace backups.
class CloudSyncService {
  CloudSyncService(this._cloud, this._repo, this._encryption);

  final CloudService _cloud;
  final XoloRepository _repo;
  final EncryptionService _encryption;

  static const backupFileName = 'xolo-mobile-backup.xolo.enc';

  Future<GoogleSignInAccount?> signIn() => _cloud.signIn();

  Future<GoogleSignInAccount?> signInSilently() => _cloud.signInSilently();

  Future<void> signOut() => _cloud.signOut();

  GoogleSignInAccount? get currentUser => _cloud.currentUser;

  Future<DateTime?> getLastSyncedAt() async {
    final raw = await _repo.getSetting('cloud_last_synced_at');
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Export local DB snapshot, encrypt, upload to Drive AppData.
  Future<void> syncUpload({
    required AppDatabase db,
    required String password,
  }) async {
    if (_cloud.currentUser == null) {
      throw StateError('Not signed in');
    }

    final tempDir = await getTemporaryDirectory();
    final encPath = p.join(tempDir.path, backupFileName);

    try {
      final exportData = await _exportDatabaseJson(db);
      final encryptedBytes = _encryption.encryptBytes(
        Uint8List.fromList(utf8.encode(exportData)),
        password,
      );
      await File(encPath).writeAsBytes(encryptedBytes);

      await _cloud.uploadBackup(
        File(encPath),
        backupFileName,
        'Xolo mobile backup ${DateTime.now().toIso8601String()}',
      );

      await _repo.setSetting(
        'cloud_last_synced_at',
        DateTime.now().toIso8601String(),
      );
    } finally {
      try {
        final f = File(encPath);
        if (await f.exists()) await f.delete();
      } catch (e) {
        AppLogger.warn('Temp cleanup failed');
      }
    }
  }

  Future<List<int>?> downloadLatestBackup() async {
    if (_cloud.currentUser == null) return null;
    final files = await _cloud.listBackups();
    if (files.isEmpty) return null;
    files.sort((a, b) {
      final at = a.createdTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bt = b.createdTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bt.compareTo(at);
    });
    final latest = files.first;
    if (latest.id == null) return null;
    return _cloud.downloadBackup(latest.id!);
  }

  Future<String> _exportDatabaseJson(AppDatabase db) async {
    final settings = await db.select(db.appSettings).get();
    final payload = {
      'schemaVersion': 8,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': settings.map((s) => {'key': s.key, 'value': s.value}).toList(),
    };
    return jsonEncode(payload);
  }
}
