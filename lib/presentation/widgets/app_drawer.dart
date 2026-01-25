import 'package:flutter/material.dart';
import '../screens/saved_requests_screen.dart';
import '../screens/history_screen.dart';
import '../screens/environments_screen.dart';
import 'import_collection_dialog.dart';
import 'command_palette.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hub, size: 48, color: colorScheme.primary),
                  const SizedBox(height: 12),
                  Text('Xolo API Hub', style: theme.textTheme.titleLarge),
                ],
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.folder_special),
            title: const Text('Mis Proyectos / Requests'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedRequestsScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historial'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.layers),
            title: const Text('Entornos y Variables'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EnvironmentsScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.cloud_download),
            title: const Text('Importar Colección'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => const ImportCollectionDialog(),
              );
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca de'),
            onTap: () {
              // Show about dialog
              showAboutDialog(
                context: context,
                applicationName: 'Xolo',
                applicationVersion: '0.3.5-alpha',
              );
            },
          ),
        ],
      ),
    );
  }
}
