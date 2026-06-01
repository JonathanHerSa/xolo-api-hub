import 'package:flutter/material.dart';
import 'package:xolo/l10n/app_localizations.dart';

class BearerAuthForm extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool hideSensitiveValues;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const BearerAuthForm({
    super.key,
    required this.data,
    required this.hideSensitiveValues,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        TextFormField(
          initialValue: data['token'] as String?,
          decoration: InputDecoration(
            labelText: l10n.authBearerToken,
            border: const OutlineInputBorder(),
            hintText: l10n.bearerTokenHint,
          ),
          obscureText: hideSensitiveValues,
          onChanged: (val) => onChanged({...data, 'token': val}),
        ),
      ],
    );
  }
}
