import 'package:xolo/domain/entities/saved_request_entity.dart';

/// A single request step in a collection run plan.
class RunPlanItem {
  const RunPlanItem({
    required this.stepIndex,
    required this.request,
    required this.collectionId,
  });

  final int stepIndex;
  final SavedRequestEntity request;
  final int? collectionId;
}

/// Options controlling collection run behavior.
class RunOptions {
  const RunOptions({
    this.stopOnFailure = true,
    this.skipIfVariableEmpty = const [],
    this.delayBetweenStepsMs = 0,
    this.startFromIndex = 0,
  });

  final bool stopOnFailure;
  final List<String> skipIfVariableEmpty;
  final int delayBetweenStepsMs;
  final int startFromIndex;

  Map<String, dynamic> toJson() => {
    'stopOnFailure': stopOnFailure,
    'skipIfVariableEmpty': skipIfVariableEmpty,
    'delayBetweenStepsMs': delayBetweenStepsMs,
    'startFromIndex': startFromIndex,
  };

  factory RunOptions.fromJson(Map<String, dynamic> json) {
    return RunOptions(
      stopOnFailure: json['stopOnFailure'] as bool? ?? true,
      skipIfVariableEmpty: (json['skipIfVariableEmpty'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      delayBetweenStepsMs: json['delayBetweenStepsMs'] as int? ?? 0,
      startFromIndex: json['startFromIndex'] as int? ?? 0,
    );
  }
}
