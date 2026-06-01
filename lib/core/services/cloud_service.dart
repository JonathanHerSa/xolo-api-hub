import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import 'package:xolo/core/services/app_logger.dart';

class CloudService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;

  GoogleSignInAccount? get currentUser => _currentUser;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser != null) {
        final authHeaders = await _currentUser!.authHeaders;
        final authenticateClient = GoogleAuthClient(authHeaders);
        _driveApi = drive.DriveApi(authenticateClient);
      }
      return _currentUser;
    } catch (e) {
      AppLogger.error('Sign in error', e);
      return null;
    }
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();
      if (_currentUser != null) {
        final authHeaders = await _currentUser!.authHeaders;
        final authenticateClient = GoogleAuthClient(authHeaders);
        _driveApi = drive.DriveApi(authenticateClient);
      }
      return _currentUser;
    } catch (e) {
      AppLogger.error('Silent sign in error', e);
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _driveApi = null;
  }

  Future<String?> uploadBackup(
    File file,
    String filename,
    String description,
  ) async {
    if (_driveApi == null) return null;

    final media = drive.Media(file.openRead(), file.lengthSync());
    final driveFile = drive.File()
      ..name = filename
      ..description = description
      ..parents = ['appDataFolder'];

    try {
      final result = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );
      return result.id;
    } catch (e) {
      AppLogger.error('Upload error', e);
      rethrow;
    }
  }

  Future<List<drive.File>> listBackups() async {
    if (_driveApi == null) return [];

    try {
      final fileList = await _driveApi!.files.list(
        spaces: 'appDataFolder',
        q: "mimeType != 'application/vnd.google-apps.folder'",
        $fields: 'files(id, name, createdTime, size, description)',
      );
      return fileList.files ?? [];
    } catch (e) {
      AppLogger.error('List backups error', e);
      return [];
    }
  }

  Future<List<int>> downloadBackup(String fileId) async {
    if (_driveApi == null) throw Exception('Not signed in');

    try {
      final media =
          await _driveApi!.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final dataStore = <int>[];
      await media.stream.forEach(dataStore.addAll);
      return dataStore;
    } catch (e) {
      AppLogger.error('Download error', e);
      rethrow;
    }
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

final cloudServiceProvider = Provider<CloudService>((ref) {
  return CloudService();
});
