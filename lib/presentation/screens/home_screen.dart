import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/xolo_theme.dart';
import '../providers/request_provider.dart';
import '../providers/form_providers.dart';
import '../providers/theme_provider.dart';
import '../widgets/url_input_bar.dart';
import '../widgets/key_value_table.dart';
import '../widgets/json_viewer.dart';
import 'history_screen.dart';
import 'saved_requests_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isRequestPanelExpanded = true;

  @override
  Widget build(BuildContext context) {
    final requestState = ref.watch(requestProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Xolo'),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            // Guardar Request
            IconButton(
              icon: const Icon(Icons.bookmark_add_outlined),
              tooltip: 'Guardar Request',
              onPressed: () =>
                  showSaveRequestDialog(context: context, ref: ref),
            ),
            // Duración
            if (requestState.durationMs != null)
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: XoloTheme.statusSuccess.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${requestState.durationMs}ms',
                  style: TextStyle(
                    color: XoloTheme.statusSuccess,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        drawer: _buildDrawer(context, colorScheme),
        body: Column(
          children: [
            // URL Input (siempre visible)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: const UrlInputBar(),
            ),

            // Request Panel (colapsable)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _isRequestPanelExpanded ? 200 : 0,
              child: _isRequestPanelExpanded
                  ? Column(
                      children: [
                        // Tabs
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colorScheme.outline),
                          ),
                          child: const TabBar(
                            dividerHeight: 0,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorPadding: EdgeInsets.all(4),
                            indicator: BoxDecoration(
                              color: Color(0xFFB91C1C),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            labelColor: Colors.white,
                            tabs: [
                              Tab(text: 'Params'),
                              Tab(text: 'Headers'),
                              Tab(text: 'Body'),
                            ],
                          ),
                        ),

                        // Tab Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colorScheme.outline),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: TabBarView(
                                  children: [
                                    KeyValueTable(
                                      provider: paramsProvider,
                                      keyPlaceholder: 'Key',
                                      valuePlaceholder: 'Value',
                                    ),
                                    KeyValueTable(
                                      provider: headersProvider,
                                      keyPlaceholder: 'Header',
                                      valuePlaceholder: 'Value',
                                    ),
                                    _buildBodyInput(context),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),

            // Toggle button para colapsar/expandir
            GestureDetector(
              onTap: () => setState(
                () => _isRequestPanelExpanded = !_isRequestPanelExpanded,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isRequestPanelExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isRequestPanelExpanded
                          ? 'Ocultar request'
                          : 'Mostrar request',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Response Section (ocupa el resto)
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    children: [
                      // Response header
                      _buildResponseHeader(requestState, colorScheme),
                      // Response content
                      Expanded(
                        child: _buildResponseArea(context, requestState),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseHeader(
    RequestState requestState,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outline)),
      ),
      child: Row(
        children: [
          Text(
            'Response',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          if (requestState.statusCode != null)
            _buildStatusBadge(requestState.statusCode!),
          const SizedBox(width: 8),
          if (requestState.data != null)
            IconButton(
              icon: Icon(
                Icons.copy_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () => _copyResponse(requestState),
              tooltip: 'Copiar',
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(int statusCode) {
    final color = XoloTheme.getStatusColor(statusCode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$statusCode',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildBodyInput(BuildContext context) {
    return TextField(
      maxLines: null,
      expands: true,
      style: TextStyle(
        fontFamily: 'JetBrains Mono',
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: '{\n  "key": "value"\n}',
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(16),
        hintStyle: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
      onChanged: (val) => ref.read(bodyContentProvider.notifier).state = val,
    );
  }

  Widget _buildResponseArea(BuildContext context, RequestState state) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
          strokeWidth: 2,
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 40,
                color: XoloTheme.statusClientError,
              ),
              const SizedBox(height: 12),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.data == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.send_outlined, size: 40, color: colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              'Envía un request',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // JSON Viewer con syntax highlighting
    return JsonViewer(data: state.data);
  }

  void _copyResponse(RequestState state) {
    final formatted = const JsonEncoder.withIndent('  ').convert(state.data);
    Clipboard.setData(ClipboardData(text: formatted));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copiado al portapapeles'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, ColorScheme colorScheme) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header del drawer
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: colorScheme.outline)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.api,
                      size: 32,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Xolo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'API Client',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Menu items
            const SizedBox(height: 8),

            _DrawerItem(
              icon: Icons.history_outlined,
              label: 'Historial',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
            ),

            _DrawerItem(
              icon: Icons.folder_outlined,
              label: 'Mis Requests',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SavedRequestsScreen(),
                  ),
                );
              },
            ),

            const Divider(indent: 16, endIndent: 16),

            _DrawerItem(
              icon: ref.watch(isDarkModeProvider)
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              label: ref.watch(isDarkModeProvider)
                  ? 'Tema claro'
                  : 'Tema oscuro',
              onTap: () {
                final current = ref.read(themeModeProvider);
                ref
                    .read(themeModeProvider.notifier)
                    .state = current == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
              },
            ),

            const Spacer(),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'v1.0.0',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.onSurfaceVariant),
      title: Text(
        label,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
