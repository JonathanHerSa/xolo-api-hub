import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/services/auth_secret_service.dart';
import 'package:xolo/domain/repositories/xolo_repository.dart';
import 'package:xolo/presentation/providers/database_providers.dart';

class ResolvedAuth {
  final String? type;
  final String? data;
  final String source; // 'request', 'folder', 'project', 'none'

  ResolvedAuth({this.type, this.data, required this.source});
}

class AuthResolverService {
  final XoloRepository _repo;
  final AuthSecretService _authSecretService;

  AuthResolverService(this._repo, this._authSecretService);

  /// Resolves the effective authentication for a given request or context.
  ///
  /// [requestAuthType]: The auth type defined specifically on the request (or 'inherit').
  /// [requestAuthData]: The auth data defined on the request.
  /// [collectionId]: The ID of the collection (folder/project) the request belongs to.
  Future<ResolvedAuth> resolveAuth({
    String? requestAuthType,
    String? requestAuthData,
    int? collectionId,
  }) async {
    // 1. Direct Auth (if not Inherit and not null)
    if (requestAuthType != null &&
        requestAuthType != 'inherit' &&
        requestAuthType != 'none') {
      return ResolvedAuth(
        type: requestAuthType,
        data: await _authSecretService.resolveAuthData(requestAuthData),
        source: 'request',
      );
    }

    // Explicit 'none' means no auth
    if (requestAuthType == 'none') {
      return ResolvedAuth(type: null, data: null, source: 'none');
    }

    // 2. Inherit - Construct Path Upwards
    if (collectionId == null) {
      // No parent, so no auth
      return ResolvedAuth(type: null, data: null, source: 'none');
    }

    final path = await _repo.getCollectionPath(collectionId);
    // path is [Root, Child, Grandchild]
    // We want to search closest parent first -> Reverse
    final reversedPath = path.reversed.toList();

    for (final col in reversedPath) {
      final type = col.authType;
      // If collection has valid auth (not inherit, not null, not none? Or maybe collections can also inherit?)
      // For now, assume Collections define auth or nothing.
      // If a Folder has 'inherit' (conceptually), it means look at parent.
      // But our DB schema just has authType. Let's assume nullable = inherit/none.
      // If we want multiple levels of inheritance, we check if type is valid.

      if (type != null &&
          type != 'inherit' &&
          type.isNotEmpty &&
          type != 'none') {
        return ResolvedAuth(
          type: type,
          data: await _authSecretService.resolveAuthData(col.authData),
          source: col.parentId == null ? 'project' : 'folder',
        );
      }

      if (type == 'none') {
        return ResolvedAuth(type: null, data: null, source: 'none');
      }
    }

    return ResolvedAuth(type: null, data: null, source: 'none');
  }
}

final authResolverServiceProvider = Provider<AuthResolverService>((ref) {
  final repo = ref.watch(xoloRepositoryProvider);
  return AuthResolverService(repo, ref.read(authSecretServiceProvider));
});
