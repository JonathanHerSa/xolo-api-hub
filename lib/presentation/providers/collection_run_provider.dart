import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xolo/core/network/request_pipeline.dart';
import 'package:xolo/core/services/auth_resolver_service.dart';
import 'package:xolo/core/services/home_widget_service.dart';
import 'package:xolo/domain/entities/collection_run_entity.dart';
import 'package:xolo/domain/entities/run_plan_item.dart';
import 'package:xolo/domain/services/collection_runner_service.dart';
import 'package:xolo/domain/services/run_plan_builder.dart';
import 'package:xolo/presentation/providers/database_providers.dart';
import 'package:xolo/presentation/providers/environment_provider.dart';
import 'package:xolo/presentation/providers/workspace_provider.dart';

enum CollectionRunUiState { idle, running, completed, cancelled, error }

class CollectionRunState {
  const CollectionRunState({
    this.uiState = CollectionRunUiState.idle,
    this.steps = const [],
    this.currentStepIndex = 0,
    this.totalSteps = 0,
    this.runId,
    this.errorMessage,
    this.lastRun,
  });

  final CollectionRunUiState uiState;
  final List<RunStepResultEntity> steps;
  final int currentStepIndex;
  final int totalSteps;
  final int? runId;
  final String? errorMessage;
  final CollectionRunEntity? lastRun;

  CollectionRunState copyWith({
    CollectionRunUiState? uiState,
    List<RunStepResultEntity>? steps,
    int? currentStepIndex,
    int? totalSteps,
    int? runId,
    String? errorMessage,
    CollectionRunEntity? lastRun,
  }) {
    return CollectionRunState(
      uiState: uiState ?? this.uiState,
      steps: steps ?? this.steps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      totalSteps: totalSteps ?? this.totalSteps,
      runId: runId ?? this.runId,
      errorMessage: errorMessage,
      lastRun: lastRun ?? this.lastRun,
    );
  }
}

final collectionRunnerServiceProvider = Provider<CollectionRunnerService>((
  ref,
) {
  return CollectionRunnerService(
    pipeline: ref.watch(requestPipelineProvider),
    authResolver: ref.watch(authResolverServiceProvider),
    repository: ref.watch(xoloRepositoryProvider),
  );
});

final runPlanBuilderProvider = Provider<RunPlanBuilder>((ref) {
  return RunPlanBuilder(ref.watch(xoloRepositoryProvider));
});

class CollectionRunNotifier extends Notifier<CollectionRunState> {
  CancelToken? _cancelToken;

  @override
  CollectionRunState build() => const CollectionRunState();

  Future<int?> startRun({
    required int collectionId,
    required String collectionName,
    RunOptions options = const RunOptions(),
  }) async {
    if (state.uiState == CollectionRunUiState.running) return null;

    final runner = ref.read(collectionRunnerServiceProvider);
    final planBuilder = ref.read(runPlanBuilderProvider);
    final variables = ref.read(resolvedVariablesProvider);
    final workspaceId = ref.read(activeWorkspaceIdProvider);
    final environmentId = ref.read(activeEnvironmentIdProvider).value;

    final plan = await planBuilder.build(collectionId);
    if (plan.isEmpty) {
      state = state.copyWith(
        uiState: CollectionRunUiState.error,
        errorMessage: 'No requests in collection',
      );
      return null;
    }

    _cancelToken = CancelToken();
    state = CollectionRunState(
      uiState: CollectionRunUiState.running,
      totalSteps: plan.length,
      steps: const [],
    );

    try {
      final result = await runner.execute(
        collectionId: collectionId,
        collectionName: collectionName,
        plan: plan,
        baseVariables: variables,
        options: options,
        environmentId: environmentId,
        workspaceId: workspaceId,
        cancelToken: _cancelToken,
        onRunCreated: (runId) {
          state = state.copyWith(runId: runId);
        },
        onStep: (step) {
          state = state.copyWith(
            steps: [...state.steps, step],
            currentStepIndex: step.stepIndex + 1,
            runId: state.runId,
          );
        },
      );

      final uiState = result.status == RunStatus.cancelled
          ? CollectionRunUiState.cancelled
          : CollectionRunUiState.completed;

      state = state.copyWith(
        uiState: uiState,
        lastRun: result,
        runId: result.id,
      );

      ref.read(homeWidgetServiceProvider).updateLastRunCollection(
        collectionId,
        collectionName,
      );

      return result.id;
    } catch (e) {
      state = state.copyWith(
        uiState: CollectionRunUiState.error,
        errorMessage: e.toString(),
      );
      return null;
    } finally {
      _cancelToken = null;
    }
  }

  Future<int?> resumeRun({
    required int collectionId,
    required String collectionName,
    required int fromStepIndex,
    RunOptions baseOptions = const RunOptions(),
  }) {
    return startRun(
      collectionId: collectionId,
      collectionName: collectionName,
      options: RunOptions(
        stopOnFailure: baseOptions.stopOnFailure,
        skipIfVariableEmpty: baseOptions.skipIfVariableEmpty,
        delayBetweenStepsMs: baseOptions.delayBetweenStepsMs,
        startFromIndex: fromStepIndex,
      ),
    );
  }

  void cancelRun() {
    _cancelToken?.cancel('User cancelled');
    state = state.copyWith(uiState: CollectionRunUiState.cancelled);
  }

  void reset() {
    _cancelToken?.cancel('Reset');
    state = const CollectionRunState();
  }
}

final collectionRunProvider =
    NotifierProvider<CollectionRunNotifier, CollectionRunState>(
      CollectionRunNotifier.new,
    );

final collectionRunsHistoryProvider =
    StreamProvider<List<CollectionRunEntity>>((ref) {
      final workspaceId = ref.watch(activeWorkspaceIdProvider);
      return ref
          .watch(xoloRepositoryProvider)
          .watchCollectionRuns(workspaceId: workspaceId);
    });

final runDetailProvider = FutureProvider.family<
    (CollectionRunEntity?, List<RunStepResultEntity>),
    int
>((ref, runId) async {
  final repo = ref.watch(xoloRepositoryProvider);
  final run = await repo.getCollectionRunById(runId);
  final steps = await repo.getRunStepResults(runId);
  return (run, steps);
});

final lastRunCollectionIdProvider = FutureProvider<int?>((ref) async {
  final value = await ref
      .watch(xoloRepositoryProvider)
      .getSetting('last_run_collection_id');
  return int.tryParse(value ?? '');
});
