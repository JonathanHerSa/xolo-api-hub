import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xolo/domain/entities/env_variable_entity.dart';
import 'package:xolo/domain/entities/environment_entity.dart';
import 'package:xolo/presentation/providers/database_providers.dart';
import 'package:xolo/presentation/providers/workspace_provider.dart';

final environmentsListProvider = StreamProvider<List<EnvironmentEntity>>((ref) {
  final repo = ref.watch(xoloRepositoryProvider);
  final workspaceId = ref.watch(activeWorkspaceIdProvider);
  return repo.watchEnvironments(workspaceId);
});

final activeEnvironmentIdProvider = StreamProvider<int?>((ref) {
  final repo = ref.watch(xoloRepositoryProvider);
  final workspaceId = ref.watch(activeWorkspaceIdProvider);
  return repo.watchActiveEnvironmentId(workspaceId);
});

final rawVariablesProvider = StreamProvider<List<EnvVariableEntity>>((ref) {
  final repo = ref.watch(xoloRepositoryProvider);
  final activeEnvId = ref.watch(activeEnvironmentIdProvider).value;
  final workspaceId = ref.watch(activeWorkspaceIdProvider);

  return repo.watchVariables(workspaceId, activeEnvId);
});

class _ResolvedVarsArgs {
  final int? workspaceId;
  final int? envId;
  _ResolvedVarsArgs(this.workspaceId, this.envId);

  @override
  bool operator ==(Object other) =>
      other is _ResolvedVarsArgs &&
      other.workspaceId == workspaceId &&
      other.envId == envId;
  @override
  int get hashCode => Object.hash(workspaceId, envId);
}

final _resolvedVarsStreamProvider =
    StreamProvider.family<List<EnvVariableEntity>, _ResolvedVarsArgs>((
      ref,
      args,
    ) {
      return ref
          .watch(xoloRepositoryProvider)
          .watchResolvedVariables(args.workspaceId, args.envId);
    });

final resolvedVariablesProvider = Provider<Map<String, String>>((ref) {
  final workspaceId = ref.watch(activeWorkspaceIdProvider);
  final activeEnvId = ref.watch(activeEnvironmentIdProvider).value;

  final variablesAsync = ref.watch(
    _resolvedVarsStreamProvider(_ResolvedVarsArgs(workspaceId, activeEnvId)),
  );

  return variablesAsync.when(
    data: (vars) {
      final globalVars = <String, String>{};
      final envVars = <String, String>{};

      for (final v in vars) {
        if (v.environmentId == null) {
          globalVars[v.key] = v.value;
        } else {
          envVars[v.key] = v.value;
        }
      }

      return {...globalVars, ...envVars};
    },
    loading: () => const {},
    error: (_, _) => const {}, // coverage:ignore-line
  );
});
