import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/request_provider.dart';
import 'package:xolo/presentation/widgets/auth_tab.dart';
import 'package:xolo/presentation/widgets/code_snippet_dialog.dart';
import 'package:xolo/presentation/widgets/key_value_table.dart';
import 'package:xolo/presentation/widgets/request/request_body_tab.dart';
import 'package:xolo/presentation/widgets/request/request_response_tab.dart';
import 'package:xolo/presentation/widgets/request/request_scripts_tab.dart';

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
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        _tabController.animateTo(5); // Index 5 = Response
      }
    });

    return Column(
      children: [
        if (isLoading) const LinearProgressIndicator(),

        if (error != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            padding: const EdgeInsets.all(XoloSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: XoloRadius.sm,
            ),
            child: Text(
              l10n.errorMessage(error),
              style: const TextStyle(color: Colors.red),
            ),
          ),

        Container(
          margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: XoloSurfaces.panel(colorScheme),
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  indicatorColor: colorScheme.primary,
                  indicatorWeight: 2.5,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  tabs: [
                    Tab(text: l10n.tabParams),
                    Tab(text: l10n.tabAuth),
                    Tab(text: l10n.tabHeaders),
                    Tab(text: l10n.tabBody),
                    Tab(text: l10n.tabScripts),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.tabResponse),
                          if (statusCode != null) ...[
                            const SizedBox(width: 4),
                            RequestStatusBadge(statusCode: statusCode),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.code),
                tooltip: l10n.showCode,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => CodeSnippetDialog(tabId: widget.tabId),
                  );
                },
              ),
            ],
          ),
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

              // 2. AUTH
              AuthTab(tabId: widget.tabId),

              // 3. HEADERS
              KeyValueTable(
                tabId: widget.tabId,
                type: TableType.headers,
                keyPlaceholder: 'Header',
              ),

              // 4. BODY
              RequestBodyTab(tabId: widget.tabId),

              // 5. SCRIPTS
              ScriptsTab(tabId: widget.tabId),

              // 6. RESPONSE
              RequestResponseTab(
                isLoading: isLoading,
                data: data,
                error: error,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
