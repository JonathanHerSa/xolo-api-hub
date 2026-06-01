import 'package:flutter/material.dart';
import 'package:xolo/l10n/app_localizations.dart';

class BasicAuthForm extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool hideSensitiveValues;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const BasicAuthForm({
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
          initialValue: data['username'] as String?,
          decoration: InputDecoration(
            labelText: l10n.username,
            border: const OutlineInputBorder(),
          ),
          onChanged: (val) => onChanged({...data, 'username': val}),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: data['password'] as String?,
          obscureText: hideSensitiveValues,
          decoration: InputDecoration(
            labelText: l10n.password,
            border: const OutlineInputBorder(),
          ),
          onChanged: (val) => onChanged({...data, 'password': val}),
        ),
      ],
    );
  }
}
