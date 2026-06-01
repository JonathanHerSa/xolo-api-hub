class HistoryEntryEntity {
  const HistoryEntryEntity({
    required this.id,
    this.savedRequestId,
    this.workspaceId,
    required this.method,
    required this.url,
    this.originalUrl,
    this.headersJson,
    this.paramsJson,
    this.body,
    this.authType,
    this.authData,
    this.statusCode,
    this.responseBody,
    this.durationMs,
    required this.executedAt,
  });

  final int id;
  final int? savedRequestId;
  final int? workspaceId;
  final String method;
  final String url;
  final String? originalUrl;
  final String? headersJson;
  final String? paramsJson;
  final String? body;
  final String? authType;
  final String? authData;
  final int? statusCode;
  final String? responseBody;
  final int? durationMs;
  final DateTime executedAt;
}
