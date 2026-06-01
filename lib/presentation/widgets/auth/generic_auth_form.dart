import 'package:flutter/material.dart';
import 'package:xolo/l10n/app_localizations.dart';

class GenericAuthForm extends StatelessWidget {
  final String type;
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const GenericAuthForm({
    super.key,
    required this.type,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuration for $type',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Advanced configuration UI coming soon. For now, edit raw properties:',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
        // Simple Key-Value list for ad-hoc properties?
        // Or just a reminder.
        // Let's implement specific fields for OAuth2 at least since user asked.
        if (type == 'oauth2') ...[
          TextFormField(
            initialValue: data['accessToken'] as String?,
            decoration: InputDecoration(
              labelText: l10n.authBearerToken,
              border: const OutlineInputBorder(),
            ),
            onChanged: (val) => onChanged({...data, 'accessToken': val}),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Trigger OAuth Flow (Future Task)
            },
            icon: const Icon(Icons.key),
            label: Text(l10n.getNewAccessToken),
          ),
        ],
        if (type == 'aws') ...[
          TextFormField(
            initialValue: data['accessKey'] as String?,
            decoration: const InputDecoration(
              labelText: 'Access Key',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => onChanged({...data, 'accessKey': val}),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: data['secretKey'] as String?,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Secret Key',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => onChanged({...data, 'secretKey': val}),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: data['region'] as String?,
            decoration: const InputDecoration(
              labelText: 'Region',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => onChanged({...data, 'region': val}),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: data['service'] as String?,
            decoration: const InputDecoration(
              labelText: 'Service Name',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => onChanged({...data, 'service': val}),
          ),
        ],
      ],
    );
  }
}
