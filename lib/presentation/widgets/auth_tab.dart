import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/services/security_profile_service.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/request_session_provider.dart';
import 'package:xolo/presentation/widgets/auth/api_key_auth_form.dart';
import 'package:xolo/presentation/widgets/auth/auth_resolved_preview.dart';
import 'package:xolo/presentation/widgets/auth/basic_auth_form.dart';
import 'package:xolo/presentation/widgets/auth/bearer_auth_form.dart';
import 'package:xolo/presentation/widgets/auth/generic_auth_form.dart';
import 'package:xolo/presentation/widgets/auth/oauth2_auth_form.dart';

class AuthTab extends ConsumerStatefulWidget {
  final String tabId;
  const AuthTab({super.key, required this.tabId});

  @override
  ConsumerState<AuthTab> createState() => _AuthTabState();
}

class _AuthTabState extends ConsumerState<AuthTab> {
  Map<String, String> _authTypeLabels(AppLocalizations l10n) => {
    'inherit': l10n.authInheritFromParent,
    'none': l10n.authNone,
    'bearer': l10n.authBearerToken,
    'basic': l10n.authBasicAuth,
    'api_key': l10n.authApiKey,
    'digest': l10n.authDigestAuth,
    'oauth1': l10n.authOAuth1,
    'oauth2': l10n.authOAuth2,
    'aws': l10n.authAwsSignature,
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
    final l10n = AppLocalizations.of(context)!;
    final authTypes = _authTypeLabels(l10n);
    final sessionAsync = ref.watch(requestSessionProvider(widget.tabId));
    final policyAsync = ref.watch(securityPolicyProvider);
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

    final hideSensitiveValues =
        policyAsync.asData?.value.hideSensitiveValues ?? false;

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
                value: authTypes.containsKey(currentType)
                    ? currentType
                    : 'inherit',
                isExpanded: true,
                onChanged: _onTypeChanged,
                items: authTypes.entries.map((e) {
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
            hideSensitiveValues: hideSensitiveValues,
            onChanged: _onDataChanged,
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),

          // 3. Resolved Auth Preview
          AuthResolvedPreview(
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
  final bool hideSensitiveValues;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const _AuthForm({
    required this.type,
    required this.data,
    required this.hideSensitiveValues,
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
        return BearerAuthForm(
          data: data,
          hideSensitiveValues: hideSensitiveValues,
          onChanged: onChanged,
        );
      case 'basic':
        return BasicAuthForm(
          data: data,
          hideSensitiveValues: hideSensitiveValues,
          onChanged: onChanged,
        );
      case 'api_key':
        return ApiKeyAuthForm(
          data: data,
          hideSensitiveValues: hideSensitiveValues,
          onChanged: onChanged,
        );
      // Placeholders for advanced types
      case 'digest':
      case 'oauth1':
      case 'oauth2':
        return OAuth2AuthForm(data: data, onChanged: onChanged);
      case 'aws':
        return GenericAuthForm(type: type, data: data, onChanged: onChanged);
      default:
        return const SizedBox();
    }
  }
}
