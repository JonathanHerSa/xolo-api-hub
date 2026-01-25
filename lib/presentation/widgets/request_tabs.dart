import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/request_provider.dart';
import '../providers/request_session_provider.dart';

import 'key_value_table.dart';
import 'json_viewer.dart';

class RequestTabs extends ConsumerStatefulWidget {
  final String tabId;
  const RequestTabs({super.key, required this.tabId});

  @override
  ConsumerState<RequestTabs> createState() => _RequestTabsState();
}

class _RequestTabsState extends ConsumerState<RequestTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch Request State (Execution)
    final requestAsync = ref.watch(requestProvider(widget.tabId));
    final requestState = requestAsync.asData?.value;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Combined Loading State
    final isLoading =
        requestAsync.isLoading || (requestState?.isLoading ?? false);
    final error = requestAsync.error?.toString() ?? requestState?.error;
    final statusCode = requestState?.statusCode;
    final data = requestState?.data;

    // Auto-switch to response tab on success
    ref.listen(requestProvider(widget.tabId), (previous, next) {
      final prevLoading =
          previous?.isLoading == true ||
          (previous?.asData?.value.isLoading ?? false);
      final nextLoading =
          next.isLoading || (next.asData?.value.isLoading ?? false);

      final nextData = next.asData?.value.data;
      final nextError = next.error ?? next.asData?.value.error;

      if (prevLoading &&
          !nextLoading &&
          (nextData != null || nextError != null)) {
        _tabController.animateTo(3); // Index 3 = Response
      }
    });

    return Column(
      children: [
        if (isLoading) const LinearProgressIndicator(),

        if (error != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.red.withValues(alpha: 0.1),
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),

        TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          labelPadding: EdgeInsets.zero, // Compact tabs
          tabs: [
            const Tab(text: 'Params'),
            const Tab(text: 'Headers'),
            const Tab(text: 'Body'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Response'),
                  if (statusCode != null) ...[
                    const SizedBox(width: 4),
                    _StatusBadge(statusCode: statusCode),
                  ],
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // 1. PARAMS
              KeyValueTable(
                tabId: widget.tabId,
                type: TableType.params,
                keyPlaceholder: 'Query Param',
              ),

              // 2. HEADERS
              KeyValueTable(
                tabId: widget.tabId,
                type: TableType.headers,
                keyPlaceholder: 'Header',
              ),

              // 3. BODY
              _BodyTab(tabId: widget.tabId),

              // 4. RESPONSE
              _ResponseTab(isLoading: isLoading, data: data, error: error),
            ],
          ),
        ),
      ],
    );
  }
}

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

class _BodyTab extends ConsumerStatefulWidget {
  final String tabId;
  const _BodyTab({required this.tabId});

  @override
  ConsumerState<_BodyTab> createState() => _BodyTabState();
}

class _BodyTabState extends ConsumerState<_BodyTab> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initialBody =
        ref.read(requestSessionProvider(widget.tabId)).asData?.value.body ?? '';
    _controller = TextEditingController(text: initialBody);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<RequestSession>>(
      requestSessionProvider(widget.tabId),
      (previous, next) {
        final nextBody = next.asData?.value.body;
        final prevBody = previous?.asData?.value.body;
        
        if (nextBody != null && _controller.text != nextBody) {
             // Sync if it's an external load (previous empty/null)
             if ((prevBody == null || prevBody.isEmpty) && nextBody.isNotEmpty) {
                 _controller.text = nextBody;
             }
             // For now, we avoid overwriting user typing if they differ slightly
             // but if they are drastically different (external reset), we should sync.
             // Relying on previous being empty is a heuristic for "Load Request".
        }
      },
      fireImmediately: true,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _controller,
        onChanged: (val) =>
            ref.read(requestSessionControllerProvider(widget.tabId)).setBody(val),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(
          hintText: '{\n  "key": "value"\n}',
          border: OutlineInputBorder(),
        ),
        style: const TextStyle(fontFamily: 'monospace'),
      ),
    );
  }
}

class _ResponseTab extends StatelessWidget {
  final bool isLoading;
  final dynamic data;
  final String? error;

  const _ResponseTab({required this.isLoading, this.data, this.error});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            // Copy paste enabled
            'Error:\n$error',
            style: const TextStyle(color: Colors.red, fontFamily: 'monospace'),
          ),
        ),
      );
    }

    if (data == null) {
      return Center(
        child: Text(
          'Sin respuesta',
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }

    // JSON Viewer correcto
    return JsonViewer(data: data);
  }
}
