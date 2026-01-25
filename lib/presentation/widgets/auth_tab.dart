import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/request_session_provider.dart';

class AuthTab extends ConsumerStatefulWidget {
  final String tabId;
  const AuthTab({super.key, required this.tabId});

  @override
  ConsumerState<AuthTab> createState() => _AuthTabState();
}

class _AuthTabState extends ConsumerState<AuthTab> {
  // Map of Auth Type IDs to Display Names
  final Map<String, String> _authTypes = {
    'none': 'No Auth',
    'bearer': 'Bearer Token',
    'basic': 'Basic Auth',
    'api_key': 'API Key',
    'digest': 'Digest Auth',
    'oauth1': 'OAuth 1.0',
    'oauth2': 'OAuth 2.0',
    'aws': 'AWS Signature',
  };

  void _onTypeChanged(String? type) {
    if (type == null) return;
    ref.read(requestSessionControllerProvider(widget.tabId)).setAuthType(type);
    // Reset data when type changes? Maybe keep it if compatible, but simpler to reset or keep as garbage.
    // Ideally we might want to preserve data per type in a separate storage if switching back and forth,
    // but standard behavior is usually single active auth.
    // For now, we won't clear data immediately to allow "undo" via switching back,
    // but the UI will parse what it can.
  }

  void _onDataChanged(Map<String, dynamic> newData) {
    final jsonStr = jsonEncode(newData);
    ref
        .read(requestSessionControllerProvider(widget.tabId))
        .setAuthData(jsonStr);
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(requestSessionProvider(widget.tabId));
    final session = sessionAsync.asData?.value;

    if (session == null)
      return const Center(child: CircularProgressIndicator());

    final currentType = session.authType ?? 'none';
    Map<String, dynamic> authData = {};
    if (session.authData != null && session.authData!.isNotEmpty) {
      try {
        authData = jsonDecode(session.authData!) as Map<String, dynamic>;
      } catch (_) {}
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Auth Type Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _authTypes.containsKey(currentType)
                    ? currentType
                    : 'none',
                isExpanded: true,
                onChanged: _onTypeChanged,
                items: _authTypes.entries.map((e) {
                  return DropdownMenuItem(value: e.key, child: Text(e.value));
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Dynamic Form
          _AuthForm(
            type: currentType,
            data: authData,
            onChanged: _onDataChanged,
          ),
        ],
      ),
    );
  }
}

class _AuthForm extends StatelessWidget {
  final String type;
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const _AuthForm({
    required this.type,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'none':
        return const Center(
          child: Text(
            'This request does not use any authentication.',
            style: TextStyle(color: Colors.grey),
          ),
        );
      case 'bearer':
        return _BearerForm(data: data, onChanged: onChanged);
      case 'basic':
        return _BasicForm(data: data, onChanged: onChanged);
      case 'api_key':
        return _ApiKeyForm(data: data, onChanged: onChanged);
      // Placeholders for advanced types
      case 'digest':
      case 'oauth1':
      case 'oauth2':
      case 'aws':
        return _GenericJsonForm(type: type, data: data, onChanged: onChanged);
      default:
        return const SizedBox();
    }
  }
}

// --- Specific Forms ---

class _BearerForm extends StatelessWidget {
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const _BearerForm({required this.data, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          initialValue: data['token'] as String?,
          decoration: const InputDecoration(
            labelText: 'Token',
            border: OutlineInputBorder(),
            hintText: 'e.g. eyJhbGciOiJIUzI1Ni...',
          ),
          onChanged: (val) => onChanged({...data, 'token': val}),
        ),
      ],
    );
  }
}

class _BasicForm extends StatelessWidget {
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const _BasicForm({required this.data, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          initialValue: data['username'] as String?,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
          onChanged: (val) => onChanged({...data, 'username': val}),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: data['password'] as String?,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
          onChanged: (val) => onChanged({...data, 'password': val}),
        ),
      ],
    );
  }
}

class _ApiKeyForm extends StatelessWidget {
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const _ApiKeyForm({required this.data, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          initialValue: data['key'] as String?,
          decoration: const InputDecoration(
            labelText: 'Key',
            border: OutlineInputBorder(),
            hintText: 'e.g. X-API-Key',
          ),
          onChanged: (val) => onChanged({...data, 'key': val}),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: data['value'] as String?,
          decoration: const InputDecoration(
            labelText: 'Value',
            border: OutlineInputBorder(),
          ),
          onChanged: (val) => onChanged({...data, 'value': val}),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: (data['in'] as String?) ?? 'header',
          decoration: const InputDecoration(
            labelText: 'Add to',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'header', child: Text('Header')),
            DropdownMenuItem(value: 'query', child: Text('Query Params')),
          ],
          onChanged: (val) => onChanged({...data, 'in': val}),
        ),
      ],
    );
  }
}

class _GenericJsonForm extends StatelessWidget {
  final String type;
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const _GenericJsonForm({
    required this.type,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
            decoration: const InputDecoration(
              labelText: 'Access Token',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => onChanged({...data, 'accessToken': val}),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Trigger OAuth Flow (Future Task)
            },
            icon: const Icon(Icons.key),
            label: const Text('Get New Access Token'),
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
