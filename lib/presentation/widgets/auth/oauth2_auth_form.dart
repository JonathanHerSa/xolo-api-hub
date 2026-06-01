import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/services/oauth2_service.dart';
import 'package:xolo/l10n/app_localizations.dart';

class OAuth2AuthForm extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const OAuth2AuthForm({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  ConsumerState<OAuth2AuthForm> createState() => _OAuth2AuthFormState();
}

class _OAuth2AuthFormState extends ConsumerState<OAuth2AuthForm> {
  bool _isLoading = false;

  Future<void> _getToken() async {
    final l10n = AppLocalizations.of(context)!;
    final tokenUrl = widget.data['tokenUrl'] as String?;
    final clientId = widget.data['clientId'] as String?;
    final clientSecret = widget.data['clientSecret'] as String?;
    final grantType = widget.data['grantType'] as String?;

    if (tokenUrl == null ||
        tokenUrl.isEmpty ||
        clientId == null ||
        clientId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.oauthCompleteTokenUrl)));
      return;
    }

    if (grantType == 'authorization_code') {
      final authUrl = widget.data['authUrl'] as String?;
      if (authUrl == null || authUrl.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.oauthCompleteAuthUrl)));
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

      if (!context.mounted) return;
      widget.onChanged({...widget.data, 'accessToken': token});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.oauthTokenSuccess),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authError(e.toString())),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          items: [
            DropdownMenuItem(
              value: 'client_credentials',
              child: Text(l10n.oauthClientCredentials),
            ),
            DropdownMenuItem(
              value: 'password',
              child: Text(l10n.oauthPasswordGrant),
            ),
            DropdownMenuItem(
              value: 'authorization_code',
              child: Text(l10n.oauthAuthorizationCode),
            ),
          ],
          onChanged: (val) =>
              widget.onChanged({...widget.data, 'grantType': val}),
        ),
        if (widget.data['grantType'] == 'authorization_code') ...[
          const SizedBox(height: 16),
          TextFormField(
            initialValue: widget.data['authUrl'] as String?,
            decoration: InputDecoration(
              labelText: 'Authorization URL',
              border: const OutlineInputBorder(),
              hintText: l10n.oauthAuthUrlHint,
            ),
            onChanged: (val) =>
                widget.onChanged({...widget.data, 'authUrl': val}),
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          initialValue: widget.data['tokenUrl'] as String?,
          decoration: InputDecoration(
            labelText: 'Access Token URL',
            border: const OutlineInputBorder(),
            hintText: l10n.oauthTokenUrlHint,
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
                  decoration: InputDecoration(
                    labelText: l10n.username,
                    border: const OutlineInputBorder(),
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
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    border: const OutlineInputBorder(),
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
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
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
            labelText: l10n.authBearerToken,
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
                    tooltip: l10n.obtainNewToken,
                  ),
          ),
          onChanged: (val) =>
              widget.onChanged({...widget.data, 'accessToken': val}),
        ),
      ],
    );
  }
}
