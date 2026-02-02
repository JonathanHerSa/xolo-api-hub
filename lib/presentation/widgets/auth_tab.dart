import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_resolver_service.dart';
import '../../core/services/oauth2_service.dart';
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
    'inherit': 'Inherit from Parent',
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

    if (session == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentType = session.authType ?? 'inherit';
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
                    : 'inherit',
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
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),

          // 3. Resolved Auth Preview
          _ResolvedAuthPreview(
            requestAuthType: session.authType,
            requestAuthData: session.authData,
            collectionId: session.collectionId,
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
      case 'inherit':
        return const Center(
          child: Text(
            'This request will inherit authentication from its parent folder or project.',
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        );
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
        return _OAuth2Form(data: data, onChanged: onChanged);
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

class _OAuth2Form extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const _OAuth2Form({required this.data, required this.onChanged});

  @override
  ConsumerState<_OAuth2Form> createState() => _OAuth2FormState();
}

class _OAuth2FormState extends ConsumerState<_OAuth2Form> {
  bool _isLoading = false;

  Future<void> _getToken() async {
    final tokenUrl = widget.data['tokenUrl'] as String?;
    final clientId = widget.data['clientId'] as String?;
    final clientSecret = widget.data['clientSecret'] as String?;
    final grantType = widget.data['grantType'] as String?;

    if (tokenUrl == null ||
        tokenUrl.isEmpty ||
        clientId == null ||
        clientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa Token URL y Client ID'),
        ),
      );
      return;
    }

    if (grantType == 'authorization_code') {
      final authUrl = widget.data['authUrl'] as String?;
      if (authUrl == null || authUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor completa Auth URL')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(oauth2ServiceProvider);
      String token;

      if (grantType == 'authorization_code') {
        token = await service.authorizeAndGetToken(
          authUrl: widget.data['authUrl'],
          tokenUrl: tokenUrl,
          clientId: clientId,
          clientSecret: clientSecret ?? '',
          scope: widget.data['scope'] ?? '',
        );
      } else {
        token = await service.getAccessToken(
          tokenUrl: tokenUrl,
          clientId: clientId,
          clientSecret: clientSecret ?? '',
          grantType: grantType,
          username: widget.data['username'] as String?,
          password: widget.data['password'] as String?,
          scope: widget.data['scope'] as String?,
        );
      }

      widget.onChanged({...widget.data, 'accessToken': token});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token obtenido con éxito'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue:
              (widget.data['grantType'] as String?) ?? 'client_credentials',
          decoration: const InputDecoration(
            labelText: 'Grant Type',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'client_credentials',
              child: Text('Client Credentials'),
            ),
            DropdownMenuItem(value: 'password', child: Text('Password')),
            DropdownMenuItem(
              value: 'authorization_code',
              child: Text('Authorization Code'),
            ),
          ],
          onChanged: (val) =>
              widget.onChanged({...widget.data, 'grantType': val}),
        ),
        if (widget.data['grantType'] == 'authorization_code') ...[
          const SizedBox(height: 16),
          TextFormField(
            initialValue: widget.data['authUrl'] as String?,
            decoration: const InputDecoration(
              labelText: 'Authorization URL',
              border: OutlineInputBorder(),
              hintText: 'https://example.com/oauth/authorize',
            ),
            onChanged: (val) =>
                widget.onChanged({...widget.data, 'authUrl': val}),
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          initialValue: widget.data['tokenUrl'] as String?,
          decoration: const InputDecoration(
            labelText: 'Access Token URL',
            border: OutlineInputBorder(),
            hintText: 'https://example.com/oauth/token',
          ),
          onChanged: (val) =>
              widget.onChanged({...widget.data, 'tokenUrl': val}),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: widget.data['clientId'] as String?,
                decoration: const InputDecoration(
                  labelText: 'Client ID',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) =>
                    widget.onChanged({...widget.data, 'clientId': val}),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                initialValue: widget.data['clientSecret'] as String?,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Client Secret',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) =>
                    widget.onChanged({...widget.data, 'clientSecret': val}),
              ),
            ),
          ],
        ),
        if (widget.data['grantType'] == 'password') ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: widget.data['username'] as String?,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) =>
                      widget.onChanged({...widget.data, 'username': val}),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: widget.data['password'] as String?,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) =>
                      widget.onChanged({...widget.data, 'password': val}),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          initialValue: widget.data['scope'] as String?,
          decoration: const InputDecoration(
            labelText: 'Scope',
            border: OutlineInputBorder(),
          ),
          onChanged: (val) => widget.onChanged({...widget.data, 'scope': val}),
        ),
        const SizedBox(height: 24),
        if (_isLoading && widget.data['grantType'] == 'authorization_code')
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                CircularProgressIndicator(strokeWidth: 2),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Esperando autenticación en el navegador...\nRedirige a http://localhost:54321 después del login.',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        const Divider(),
        const SizedBox(height: 24),
        TextFormField(
          key: ValueKey(widget.data['accessToken']),
          initialValue: widget.data['accessToken'] as String?,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Access Token',
            helperText:
                'Este token se inyectará automáticamente en el header Authorization',
            border: const OutlineInputBorder(),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _getToken,
                    tooltip: 'Obtener nuevo token',
                  ),
          ),
          onChanged: (val) =>
              widget.onChanged({...widget.data, 'accessToken': val}),
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

class _ResolvedAuthPreview extends ConsumerWidget {
  final String? requestAuthType;
  final String? requestAuthData;
  final int? collectionId;

  const _ResolvedAuthPreview({
    this.requestAuthType,
    this.requestAuthData,
    this.collectionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authResolver = ref.watch(authResolverServiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.visibility_outlined,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Resolved Authorization',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<ResolvedAuth>(
          future: authResolver.resolveAuth(
            requestAuthType: requestAuthType,
            requestAuthData: requestAuthData,
            collectionId: collectionId,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 2,
                child: LinearProgressIndicator(),
              );
            }

            final resolved = snapshot.data;
            if (resolved == null || resolved.type == null) {
              return _buildInfoCard(
                context,
                'No Authentication',
                'This request will be sent without any authorization headers.',
                Icons.no_accounts_outlined,
              );
            }

            String sourceText = 'Directly set on request';
            if (resolved.source == 'folder') {
              sourceText = 'Inherited from Folder';
            } else if (resolved.source == 'project') {
              sourceText = 'Inherited from Project';
            }

            String typeText = resolved.type!.toUpperCase();
            IconData icon = Icons.key;
            if (resolved.type == 'bearer') icon = Icons.badge_outlined;
            if (resolved.type == 'basic') icon = Icons.lock_person_outlined;

            return _buildInfoCard(
              context,
              '$typeText ($sourceText)',
              'Authentication active. Credentials will be correctly injected into the request.',
              icon,
              isHighlighted: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? theme.colorScheme.primaryContainer.withOpacity(0.1)
            : theme.dividerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted
              ? theme.colorScheme.primary.withOpacity(0.3)
              : theme.dividerColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isHighlighted ? theme.colorScheme.primary : null),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
