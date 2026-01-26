import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class CloudService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveAppdataScope,
      // drive.DriveApi.driveFileScope, // If we want to see files created by us outside appData
    ],
  );

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;

  GoogleSignInAccount? get currentUser => _currentUser;

  /// Initiate Sign In
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
      print('Sign in error: $e');
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
      print('Silent Sign in error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _driveApi = null;
  }

  /// Uploads a file to the App Data Folder
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
      ..parents = ['appDataFolder']; // Special folder for app data

    try {
      final result = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );
      return result.id;
    } catch (e) {
      print('Upload error: $e');
      rethrow;
    }
  }

  /// Lists backups in App Data Folder
  Future<List<drive.File>> listBackups() async {
    if (_driveApi == null) return [];

    try {
      final fileList = await _driveApi!.files.list(
        spaces: 'appDataFolder',
        q: "mimeType != 'application/vnd.google-apps.folder'", // Filter folders if any
        $fields: 'files(id, name, createdTime, size, description)',
      );
      return fileList.files ?? [];
    } catch (e) {
      print('List error: $e');
      return [];
    }
  }

  /// Downloads a file content
  Future<List<int>> downloadBackup(String fileId) async {
    if (_driveApi == null) throw Exception('Not signed in');

    try {
      final media =
          await _driveApi!.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final List<int> dataStore = [];
      await media.stream.forEach((element) {
        dataStore.addAll(element);
      });
      return dataStore;
    } catch (e) {
      print('Download error: $e');
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
