import 'package:flutter/material.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/widgets/json_viewer.dart';

class _StatusBadge extends StatelessWidget {
  final int statusCode;
  const _StatusBadge({required this.statusCode});

  @override
  Widget build(BuildContext context) {
    final isSuccess = statusCode >= 200 && statusCode < 300;
    final color = isSuccess ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        statusCode.toString(),
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class RequestStatusBadge extends StatelessWidget {
  final int statusCode;
  const RequestStatusBadge({super.key, required this.statusCode});

  @override
  Widget build(BuildContext context) {
    return _StatusBadge(statusCode: statusCode);
  }
}

class RequestResponseTab extends StatelessWidget {
  final bool isLoading;
  final dynamic data;
  final String? error;

  const RequestResponseTab({
    super.key,
    required this.isLoading,
    this.data,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            l10n.responseErrorPrefix(error!),
            style: const TextStyle(color: Colors.red, fontFamily: 'monospace'),
          ),
        ),
      );
    }

    if (data == null) {
      return Center(
        child: Text(
          l10n.noResponse,
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }

    // JSON Viewer correcto
    return JsonViewer(data: data);
  }
}
