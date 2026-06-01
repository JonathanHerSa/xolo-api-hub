import 'package:flutter/material.dart';
import 'package:xolo/l10n/app_localizations.dart';

class ApiKeyAuthForm extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool hideSensitiveValues;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const ApiKeyAuthForm({
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
          initialValue: data['key'] as String?,
          decoration: InputDecoration(
            labelText: l10n.keyLabel,
            border: const OutlineInputBorder(),
            hintText: l10n.apiKeyHint,
          ),
          onChanged: (val) => onChanged({...data, 'key': val}),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: data['value'] as String?,
          decoration: InputDecoration(
            labelText: l10n.valueLabel,
            border: const OutlineInputBorder(),
          ),
          obscureText: hideSensitiveValues,
          onChanged: (val) => onChanged({...data, 'value': val}),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: (data['in'] as String?) ?? 'header',
          decoration: InputDecoration(
            labelText: l10n.addToLabel,
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(value: 'header', child: Text(l10n.header)),
            DropdownMenuItem(value: 'query', child: Text(l10n.queryParams)),
          ],
          onChanged: (val) => onChanged({...data, 'in': val}),
        ),
      ],
    );
  }
}
