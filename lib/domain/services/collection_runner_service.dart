import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:json_path/json_path.dart';

import 'package:xolo/core/network/request_pipeline.dart';
import 'package:xolo/core/services/app_logger.dart';
import 'package:xolo/core/services/auth_resolver_service.dart';
import 'package:xolo/core/utils/script_executor.dart';
import 'package:xolo/domain/entities/assertion_rule_entity.dart';
import 'package:xolo/domain/entities/collection_run_entity.dart';
import 'package:xolo/domain/entities/run_plan_item.dart';
import 'package:xolo/domain/repositories/xolo_repository.dart';
import 'package:xolo/domain/services/assertion_evaluator.dart';

/// Orchestrates sequential collection runs with assertions and variable chaining.
class CollectionRunnerService {
  CollectionRunnerService({
    required RequestPipeline pipeline,
    required AuthResolverService authResolver,
    required XoloRepository repository,
  }) : _pipeline = pipeline,
       _authResolver = authResolver,
       _repository = repository;

  final RequestPipeline _pipeline;
  final AuthResolverService _authResolver;
  final XoloRepository _repository;

  static const int responseSnippetMaxLength = 500;

  Future<CollectionRunEntity> execute({
    required int collectionId,
    required String collectionName,
    required List<RunPlanItem> plan,
    required Map<String, String> baseVariables,
    required RunOptions options,
    required int? environmentId,
    required int? workspaceId,
    required void Function(RunStepResultEntity step) onStep,
    CancelToken? cancelToken,
    void Function(int runId)? onRunCreated,
  }) async {
    final token = cancelToken ?? CancelToken();
    final runId = await _repository.createCollectionRun(
      collectionId: collectionId,
      workspaceId: workspaceId,
      environmentId: environmentId,
      totalSteps: plan.length,
      stopOnFailure: options.stopOnFailure,
      runOptionsJson: jsonEncode(options.toJson()),
    );

    onRunCreated?.call(runId);

    var passed = 0;
    var failed = 0;
    var skipped = 0;
    final workingVars = Map<String, String>.from(baseVariables);
    var runStatus = RunStatus.completed;
    var aborted = false;

    for (final item in plan) {
      if (item.stepIndex < options.startFromIndex) continue;
      if (token.isCancelled) {
        runStatus = RunStatus.cancelled;
        break;
      }
      if (aborted) break;

      if (options.delayBetweenStepsMs > 0 && item.stepIndex > 0) {
        await Future<void>.delayed(
          Duration(milliseconds: options.delayBetweenStepsMs),
        );
      }

      final skipReason = _shouldSkip(item, workingVars, options);
      if (skipReason != null) {
        skipped++;
        final skippedStep = RunStepResultEntity(
          stepIndex: item.stepIndex,
          savedRequestId: item.request.id,
          name: item.request.name,
          method: item.request.method,
          url: item.request.url,
          status: RunStepStatus.skipped,
          passed: true,
          errorMessage: skipReason,
        );
        onStep(skippedStep);
        await _repository.insertRunStepResult(
          runId: runId,
          step: skippedStep,
        );
        continue;
      }

      final req = item.request;
      final preVars = ScriptExecutor.executePreScripts(
        req.preScriptsJson,
        workingVars,
      );
      workingVars.addAll(preVars);

      Map<String, dynamic>? headers;
      Map<String, dynamic>? params;
      if (req.headersJson != null && req.headersJson!.isNotEmpty) {
        headers = Map<String, dynamic>.from(
          jsonDecode(req.headersJson!) as Map<String, dynamic>,
        );
      }
      if (req.paramsJson != null && req.paramsJson!.isNotEmpty) {
        params = Map<String, dynamic>.from(
          jsonDecode(req.paramsJson!) as Map<String, dynamic>,
        );
      }

      final output = await _pipeline.send(
        method: req.method,
        url: req.url,
        queryParams: params,
        headers: headers,
        body: req.body,
        authType: req.authType,
        authData: req.authData,
        collectionId: req.collectionId ?? item.collectionId,
        variables: workingVars,
        authResolver: _authResolver,
        cancelToken: token,
      );

      if (output.cancelled) {
        runStatus = RunStatus.cancelled;
        break;
      }

      final rules = AssertionRuleEntity.listFromJson(req.assertionsJson);
      final assertionResults = AssertionEvaluator.evaluate(
        rules: rules,
        statusCode: output.statusCode,
        durationMs: output.durationMs,
        responseData: output.data,
        errorMessage: output.error,
      );

      final stepPassed =
          output.error == null && AssertionEvaluator.allPassed(assertionResults);

      final extracted = await _applyPostScripts(
        scriptsJson: req.scriptsJson,
        responseData: output.data,
        workingVars: workingVars,
        environmentId: environmentId,
        workspaceId: workspaceId,
      );

      final stepStatus = output.error != null
          ? RunStepStatus.error
          : stepPassed
          ? RunStepStatus.passed
          : RunStepStatus.failed;

      if (stepPassed) {
        passed++;
      } else {
        failed++;
        if (options.stopOnFailure) aborted = true;
      }

      final stepResult = RunStepResultEntity(
        stepIndex: item.stepIndex,
        savedRequestId: req.id,
        name: req.name,
        method: req.method,
        url: output.resolvedUrl,
        status: stepStatus,
        statusCode: output.statusCode,
        durationMs: output.durationMs,
        passed: stepPassed,
        assertionResults: assertionResults,
        errorMessage: output.error,
        responseBodySnippet: _snippet(output.data),
        extractedVariables: extracted,
      );

      onStep(stepResult);
      await _repository.insertRunStepResult(runId: runId, step: stepResult);
    }

    if (failed > 0 && runStatus == RunStatus.completed) {
      runStatus = RunStatus.failed;
    }

    final snapshot = jsonEncode(workingVars);
    await _repository.finishCollectionRun(
      runId: runId,
      status: runStatus,
      passedSteps: passed,
      failedSteps: failed,
      skippedSteps: skipped,
      variablesSnapshotJson: snapshot,
    );

    await _repository.setSetting('last_run_collection_id', '$collectionId');

    return CollectionRunEntity(
      id: runId,
      collectionId: collectionId,
      workspaceId: workspaceId,
      environmentId: environmentId,
      status: runStatus,
      totalSteps: plan.length,
      passedSteps: passed,
      failedSteps: failed,
      skippedSteps: skipped,
      startedAt: DateTime.now(),
      finishedAt: DateTime.now(),
      stopOnFailure: options.stopOnFailure,
      collectionName: collectionName,
      variablesSnapshotJson: snapshot,
    );
  }

  String? _shouldSkip(
    RunPlanItem item,
    Map<String, String> vars,
    RunOptions options,
  ) {
    for (final key in options.skipIfVariableEmpty) {
      final value = vars[key];
      if (value == null || value.isEmpty) {
        return 'Skipped: variable "$key" is empty';
      }
    }
    return null;
  }

  Future<Map<String, String>> _applyPostScripts({
    required String? scriptsJson,
    required dynamic responseData,
    required Map<String, String> workingVars,
    required int? environmentId,
    required int? workspaceId,
  }) async {
    final extracted = <String, String>{};
    if (scriptsJson == null || scriptsJson.isEmpty) return extracted;

    try {
      final rules = jsonDecode(scriptsJson) as List<dynamic>;
      for (final rule in rules) {
        final varName = rule['key'] as String?;
        final pathStr = rule['path'] as String?;
        if (varName == null || pathStr == null || pathStr.isEmpty) continue;

        try {
          final matches = JsonPath(pathStr).read(responseData);
          if (matches.isNotEmpty) {
            final value = matches.first.value?.toString();
            if (value != null) {
              extracted[varName] = value;
              workingVars[varName] = value;
              await _repository.upsertVariable(
                key: varName,
                value: value,
                environmentId: environmentId,
                workspaceId: workspaceId,
              );
            }
          }
        } catch (e) {
          AppLogger.warn('Run post-script JSONPath error');
        }
      }
    } catch (e) {
      AppLogger.warn('Run post-script parse error');
    }
    return extracted;
  }

  String? _snippet(dynamic data) {
    if (data == null) return null;
    final str = data is String ? data : jsonEncode(data);
    if (str.length <= responseSnippetMaxLength) return str;
    return '${str.substring(0, responseSnippetMaxLength)}…';
  }
}
