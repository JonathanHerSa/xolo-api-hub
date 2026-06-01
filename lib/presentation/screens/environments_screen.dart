import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/domain/entities/env_variable_entity.dart';
import 'package:xolo/domain/entities/environment_entity.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/database_providers.dart';
import 'package:xolo/presentation/providers/environment_provider.dart';
import 'package:xolo/presentation/providers/workspace_provider.dart';

class EnvironmentsScreen extends ConsumerStatefulWidget {
  const EnvironmentsScreen({super.key});

  @override
  ConsumerState<EnvironmentsScreen> createState() => _EnvironmentsScreenState();
}

class _EnvironmentsScreenState extends ConsumerState<EnvironmentsScreen> {
  EnvironmentEntity? _selectedEnv;
  bool _isSidebarVisible = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final environmentsAsync = ref.watch(environmentsListProvider);
    final activeEnvIdAsync = ref.watch(activeEnvironmentIdProvider);
    final workspaceId = ref.watch(
      activeWorkspaceIdProvider,
    ); // Leemos workspace
    // También obtener nombre del workspace para mostrar en UI si se desea

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.environmentsAndVariables),
        leading: IconButton(
          icon: Icon(_isSidebarVisible ? Icons.menu_open : Icons.menu),
          onPressed: () =>
              setState(() => _isSidebarVisible = !_isSidebarVisible),
        ),
      ),
      body: environmentsAsync.when(
        data: (environments) {
          return Stack(
            children: [
              // 1. CONTENIDO PRINCIPAL (Variables)
              Positioned.fill(
                child: Column(
                  children: [
                    // Header del panel derecho
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: colorScheme.outline),
                        ),
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedEnv == null ? Icons.public : Icons.layers,
                            color: colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedEnv?.name ?? l10n.globalVariables,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _selectedEnv == null
                                      ? l10n.globalVariablesSubtitle
                                      : l10n.environmentOverridesSubtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedEnv != null)
                            OutlinedButton.icon(
                              onPressed:
                                  activeEnvIdAsync.value == _selectedEnv!.id
                                  ? null // Ya activo
                                  : () => ref
                                        .read(xoloRepositoryProvider)
                                        .setActiveEnvironment(
                                          _selectedEnv!.id,
                                          workspaceId,
                                        ),
                              icon: const Icon(Icons.check_circle_outline),
                              label: Text(
                                activeEnvIdAsync.value == _selectedEnv!.id
                                    ? l10n.active
                                    : l10n.activate,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Lista de Variables
                    Expanded(child: _VariablesList(envId: _selectedEnv?.id)),
                  ],
                ),
              ),

              // 2. SCRIM
              if (_isSidebarVisible)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _isSidebarVisible = false),
                    child: Container(color: Colors.black54),
                  ),
                ),

              // 3. SIDEBAR
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: _isSidebarVisible ? 0 : -280,
                top: 0,
                bottom: 0,
                width: 280,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: [
                      if (_isSidebarVisible)
                        const BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(4, 0),
                        ),
                    ],
                    border: Border(
                      right: BorderSide(color: colorScheme.outline),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.public,
                          color: colorScheme.secondary,
                        ),
                        title: Text(l10n.globals),
                        selected: _selectedEnv == null,
                        onTap: () {
                          setState(() {
                            _selectedEnv = null;
                            _isSidebarVisible = false;
                          });
                        },
                      ),
                      const Divider(height: 1),

                      Expanded(
                        child: ListView.builder(
                          itemCount: environments.length,
                          itemBuilder: (context, index) {
                            final env = environments[index];
                            final isActive = activeEnvIdAsync.value == env.id;
                            final isSelected = _selectedEnv?.id == env.id;

                            return ListTile(
                              leading: Icon(
                                isActive
                                    ? Icons.check_circle
                                    : Icons.layers_outlined,
                                color: isActive
                                    ? Colors.green
                                    : colorScheme.onSurfaceVariant,
                              ),
                              title: Text(
                                env.name,
                                style: TextStyle(
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              onTap: () {
                                setState(() {
                                  _selectedEnv = env;
                                  _isSidebarVisible = false;
                                });
                              },
                              trailing: PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, size: 20),
                                onSelected: (value) async {
                                  final db = ref.read(xoloRepositoryProvider);
                                  if (value == 'activate') {
                                    await db.setActiveEnvironment(
                                      env.id,
                                      workspaceId,
                                    );
                                  } else if (value == 'delete') {
                                    _confirmDeleteEnv(context, env);
                                  }
                                },
                                itemBuilder: (context) => [
                                  if (!isActive)
                                    PopupMenuItem(
                                      value: 'activate',
                                      child: Text(l10n.activate),
                                    ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      l10n.delete,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _showAddEnvDialog(context, ref, workspaceId),
                            icon: const Icon(Icons.add),
                            label: Text(l10n.newEnvironment),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text(l10n.errorMessage(err.toString()))),
      ),
    );
  }

  void _showAddEnvDialog(
    BuildContext context,
    WidgetRef ref,
    int? workspaceId,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.newEnvironment),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: l10n.environmentNameHint),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ref
                    .read(xoloRepositoryProvider)
                    .createEnvironment(controller.text, workspaceId);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteEnv(BuildContext context, EnvironmentEntity env) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteEnvironmentTitle(env.name)),
        content: Text(l10n.deleteEnvironmentMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (_selectedEnv?.id == env.id) {
                setState(() => _selectedEnv = null);
              }
              await ref.read(xoloRepositoryProvider).deleteEnvironment(env.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _VariablesList extends ConsumerStatefulWidget {
  final int? envId; // Si null, son globales DEL WORKSPACE

  const _VariablesList({required this.envId});

  @override
  ConsumerState<_VariablesList> createState() => _VariablesListState();
}

class _VariablesListState extends ConsumerState<_VariablesList> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.watch(xoloRepositoryProvider);
    final workspaceId = ref.watch(activeWorkspaceIdProvider);

    // Usamos watchVariables con la nueva firma
    return StreamBuilder<List<EnvVariableEntity>>(
      stream: db.watchVariables(workspaceId, widget.envId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final variables = snapshot.data!;
        final colorScheme = Theme.of(context).colorScheme;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (variables.isNotEmpty)
              Card(
                child: Column(
                  children: [
                    for (var i = 0; i < variables.length; i++)
                      Container(
                        decoration: i < variables.length - 1
                            ? BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: colorScheme.outline.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                        child: ListTile(
                          title: Text(
                            variables[i].key,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(variables[i].value),
                          trailing: variables[i].key == 'baseUrl'
                              ? null
                              : IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      db.deleteVariable(variables[i].id),
                                ),
                          onTap: () => _showEditVariableDialog(
                            context,
                            variables[i],
                            workspaceId,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.noVariablesDefined,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),

            const SizedBox(height: 20),
            Center(
              child: FilledButton.tonalIcon(
                onPressed: () =>
                    _showEditVariableDialog(context, null, workspaceId),
                icon: const Icon(Icons.add),
                label: Text(l10n.addVariable),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditVariableDialog(
    BuildContext context,
    EnvVariableEntity? existingVar,
    int? workspaceId,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final keyCtrl = TextEditingController(text: existingVar?.key ?? '');
    final valueCtrl = TextEditingController(text: existingVar?.value ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingVar == null ? l10n.newVariable : l10n.editVariable),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.variableUsageHint('{{host}}'),
                style: const TextStyle(fontSize: 12),
              ),
            ),
            TextField(
              controller: keyCtrl,
              readOnly: existingVar?.key == 'baseUrl', // BLOQUEADO
              decoration: InputDecoration(
                labelText: l10n.keyLabel,
                hintText: l10n.hostHint,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueCtrl,
              decoration: InputDecoration(labelText: l10n.valueLabel),
              maxLines: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (keyCtrl.text.isNotEmpty) {
                await ref
                    .read(xoloRepositoryProvider)
                    .upsertVariable(
                      id: existingVar?.id,
                      key: keyCtrl.text.trim(),
                      value: valueCtrl.text,
                      environmentId: widget.envId, // Scope entorno
                      workspaceId:
                          workspaceId, // Scope workspace (si envId es null)
                    );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
