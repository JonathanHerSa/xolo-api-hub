import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/form_providers.dart';
import '../providers/request_provider.dart';

import 'key_value_table.dart';
import 'json_viewer.dart';

class RequestTabs extends ConsumerStatefulWidget {
  const RequestTabs({super.key});

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
    final requestState = ref.watch(requestProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Auto-switch to response tab on success
    ref.listen(requestProvider, (previous, next) {
      if ((previous?.isLoading == true) &&
          (next.isLoading == false) &&
          (next.data != null || next.error != null)) {
        _tabController.animateTo(3); // Index 3 = Response
      }
    });

    return Column(
      children: [
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
                  const Text(
                    'Respons',
                  ), // "Respons" para ahorrar espacio? Mejor Response.
                  if (requestState.statusCode != null) ...[
                    const SizedBox(width: 4),
                    _StatusBadge(statusCode: requestState.statusCode!),
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
                provider: paramsProvider,
                keyPlaceholder: 'Query Param',
              ),

              // 2. HEADERS
              KeyValueTable(
                provider: headersProvider,
                keyPlaceholder: 'Header',
              ),

              // 3. BODY
              const _BodyTab(),

              // 4. RESPONSE
              _ResponseTab(state: requestState),
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

class _BodyTab extends ConsumerWidget {
  const _BodyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyContent = ref.watch(bodyContentProvider);
    // Usamos un TextEditingController DESCARTABLE para mostrar el valor actual.
    // Para escribir, usamos onChanged.
    // Esto evita el problema de cursor si mantenemos el provider sync? NO.
    // El cursor salta al final si reconstruimos el controller.
    // Usamos un controller persistente en State si queremos.
    // Para brevedad, TextController.fromValue con selection al final?

    final controller = TextEditingController.fromValue(
      TextEditingValue(
        text: bodyContent,
        selection: TextSelection.collapsed(
          offset: bodyContent.length,
        ), // Cursor al final siempre
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        onChanged: (val) => ref.read(bodyContentProvider.notifier).state = val,
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
  final RequestState state;

  const _ResponseTab({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            // Copy paste enabled
            'Error:\n${state.error}',
            style: const TextStyle(color: Colors.red, fontFamily: 'monospace'),
          ),
        ),
      );
    }

    if (state.data == null) {
      return Center(
        child: Text(
          'Sin respuesta',
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }

    // JSON Viewer correcto
    return JsonViewer(data: state.data);
  }
}
