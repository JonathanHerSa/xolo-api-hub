import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/request_provider.dart';
import 'package:xolo/presentation/widgets/auth_tab.dart';
import 'package:xolo/presentation/widgets/code_snippet_dialog.dart';
import 'package:xolo/presentation/widgets/key_value_table.dart';
import 'package:xolo/presentation/widgets/request/assertions_tab.dart';
import 'package:xolo/presentation/widgets/request/request_body_tab.dart';
import 'package:xolo/presentation/widgets/request/request_response_tab.dart';
import 'package:xolo/presentation/widgets/request/request_scripts_tab.dart';
import 'package:xolo/presentation/widgets/request_section_tabs.dart';

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
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final requestAsync = ref.watch(requestProvider(widget.tabId));
    final requestState = requestAsync.asData?.value;
    final colorScheme = Theme.of(context).colorScheme;

    final isLoading =
        requestAsync.isLoading || (requestState?.isLoading ?? false);
    final error = requestAsync.error?.toString() ?? requestState?.error;
    final statusCode = requestState?.statusCode;
    final data = requestState?.data;

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
        _tabController.animateTo(6);
      }
    });

    return Column(
      children: [
        if (isLoading)
          LinearProgressIndicator(
            minHeight: 2,
            color: colorScheme.primary,
            backgroundColor: colorScheme.outline.withValues(alpha: 0.25),
          ),
        if (error != null)
          Material(
            color: colorScheme.errorContainer.withValues(alpha: 0.35),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: XoloSpacing.lg,
                vertical: XoloSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 18, color: colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.errorMessage(error),
                      style: TextStyle(color: colorScheme.error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        RequestSectionTabs(
          controller: _tabController,
          labels: RequestSectionTabs.labelsFor(l10n),
          statusCode: statusCode,
          trailing: IconButton(
            icon: const Icon(Icons.code_rounded, size: 20),
            tooltip: l10n.showCode,
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => CodeSnippetDialog(tabId: widget.tabId),
              );
            },
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              KeyValueTable(
                tabId: widget.tabId,
                type: TableType.params,
                keyPlaceholder: 'Query Param',
              ),
              AuthTab(tabId: widget.tabId),
              KeyValueTable(
                tabId: widget.tabId,
                type: TableType.headers,
                keyPlaceholder: 'Header',
              ),
              RequestBodyTab(tabId: widget.tabId),
              ScriptsTab(tabId: widget.tabId),
              AssertionsTab(tabId: widget.tabId),
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
