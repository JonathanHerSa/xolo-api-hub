enum RunStatus {
  running,
  completed,
  cancelled,
  failed,
}

enum RunStepStatus {
  passed,
  failed,
  skipped,
  error,
}

class AssertionResultEntity {
  const AssertionResultEntity({
    required this.ruleType,
    required this.passed,
    required this.message,
  });

  final String ruleType;
  final bool passed;
  final String message;

  Map<String, dynamic> toJson() => {
    'ruleType': ruleType,
    'passed': passed,
    'message': message,
  };

  factory AssertionResultEntity.fromJson(Map<String, dynamic> json) {
    return AssertionResultEntity(
      ruleType: json['ruleType'] as String? ?? '',
      passed: json['passed'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}

class RunStepResultEntity {
  const RunStepResultEntity({
    required this.stepIndex,
    required this.savedRequestId,
    required this.name,
    required this.method,
    required this.url,
    required this.status,
    this.statusCode,
    this.durationMs,
    this.passed = false,
    this.assertionResults = const [],
    this.errorMessage,
    this.responseBodySnippet,
    this.extractedVariables = const {},
  });

  final int stepIndex;
  final int? savedRequestId;
  final String name;
  final String method;
  final String url;
  final RunStepStatus status;
  final int? statusCode;
  final int? durationMs;
  final bool passed;
  final List<AssertionResultEntity> assertionResults;
  final String? errorMessage;
  final String? responseBodySnippet;
  final Map<String, String> extractedVariables;

  RunStepResultEntity copyWith({
    RunStepStatus? status,
    int? statusCode,
    int? durationMs,
    bool? passed,
    List<AssertionResultEntity>? assertionResults,
    String? errorMessage,
    String? responseBodySnippet,
    Map<String, String>? extractedVariables,
  }) {
    return RunStepResultEntity(
      stepIndex: stepIndex,
      savedRequestId: savedRequestId,
      name: name,
      method: method,
      url: url,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      durationMs: durationMs ?? this.durationMs,
      passed: passed ?? this.passed,
      assertionResults: assertionResults ?? this.assertionResults,
      errorMessage: errorMessage ?? this.errorMessage,
      responseBodySnippet: responseBodySnippet ?? this.responseBodySnippet,
      extractedVariables: extractedVariables ?? this.extractedVariables,
    );
  }
}

class CollectionRunEntity {
  const CollectionRunEntity({
    required this.id,
    required this.collectionId,
    this.workspaceId,
    this.environmentId,
    required this.status,
    required this.totalSteps,
    required this.passedSteps,
    required this.failedSteps,
    required this.skippedSteps,
    required this.startedAt,
    this.finishedAt,
    this.stopOnFailure = true,
    this.collectionName,
    this.variablesSnapshotJson,
  });

  final int id;
  final int collectionId;
  final int? workspaceId;
  final int? environmentId;
  final RunStatus status;
  final int totalSteps;
  final int passedSteps;
  final int failedSteps;
  final int skippedSteps;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final bool stopOnFailure;
  final String? collectionName;
  final String? variablesSnapshotJson;

  bool get allPassed => failedSteps == 0 && passedSteps > 0;
}
