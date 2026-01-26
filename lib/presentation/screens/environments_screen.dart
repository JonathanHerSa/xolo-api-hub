import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/xolo_theme.dart';
import '../../data/local/database.dart';
import '../providers/database_providers.dart';
import '../providers/environment_provider.dart';
import '../providers/workspace_provider.dart';

class EnvironmentsScreen extends ConsumerStatefulWidget {
  const EnvironmentsScreen({super.key});

  @override
  ConsumerState<EnvironmentsScreen> createState() => _EnvironmentsScreenState();
}

class _EnvironmentsScreenState extends ConsumerState<EnvironmentsScreen> {
  Environment? _selectedEnv;
  bool _isSidebarVisible = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final environmentsAsync = ref.watch(environmentsListProvider);
    final activeEnvIdAsync = ref.watch(activeEnvironmentIdProvider);
    final workspaceId = ref.watch(
      activeWorkspaceIdProvider,
    ); // Leemos workspace
    // También obtener nombre del workspace para mostrar en UI si se desea

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entornos y Variables'),
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
                                  _selectedEnv?.name ?? 'Variables Globales',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _selectedEnv == null
                                      ? 'Disponibles en todo este Workspace'
                                      : 'Sobreescriben las variables globales',
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
                                        .read(databaseProvider)
                                        .setActiveEnvironment(
                                          _selectedEnv!.id,
                                          workspaceId,
                                        ),
                              icon: const Icon(Icons.check_circle_outline),
                              label: Text(
                                activeEnvIdAsync.value == _selectedEnv!.id
                                    ? 'Activo'
                                    : 'Activar',
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
                        title: const Text('Globales'),
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
                                    ? XoloTheme.statusSuccess
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
                                  final db = ref.read(databaseProvider);
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
                                    const PopupMenuItem(
                                      value: 'activate',
                                      child: Text('Activar'),
                                    ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      'Eliminar',
                                      style: TextStyle(color: Colors.red),
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
                            label: const Text('Nuevo Entorno'),
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
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showAddEnvDialog(
    BuildContext context,
    WidgetRef ref,
    int? workspaceId,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Entorno'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nombre (ej: Dev)'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ref
                    .read(databaseProvider)
                    .createEnvironment(controller.text, workspaceId);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteEnv(BuildContext context, Environment env) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminar "${env.name}"?'),
        content: const Text('Se borrará el entorno y sus variables.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (_selectedEnv?.id == env.id) {
                setState(() => _selectedEnv = null);
              }
              await ref.read(databaseProvider).deleteEnvironment(env.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
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
    final db = ref.watch(databaseProvider);
    final workspaceId = ref.watch(activeWorkspaceIdProvider);

    // Usamos watchVariables con la nueva firma
    return StreamBuilder<List<EnvVariable>>(
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
                    'No hay variables definidas.\nAgrega "baseUrl", "token", etc.',
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
                label: const Text('Agregar Variable'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditVariableDialog(
    BuildContext context,
    EnvVariable? existingVar,
    int? workspaceId,
  ) {
    final keyCtrl = TextEditingController(text: existingVar?.key ?? '');
    final valueCtrl = TextEditingController(text: existingVar?.value ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingVar == null ? 'Nueva Variable' : 'Editar Variable'),
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
              child: const Text(
                'Solo escribe el nombre. Ej: "host".\nLuego úsalo como {{host}}',
                style: TextStyle(fontSize: 12),
              ),
            ),
            TextField(
              controller: keyCtrl,
              readOnly: existingVar?.key == 'baseUrl', // BLOQUEADO
              decoration: const InputDecoration(
                labelText: 'Clave',
                hintText: 'host',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueCtrl,
              decoration: const InputDecoration(labelText: 'Valor'),
              maxLines: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (keyCtrl.text.isNotEmpty) {
                await ref
                    .read(databaseProvider)
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
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
