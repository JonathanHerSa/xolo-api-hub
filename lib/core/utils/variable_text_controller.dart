import 'package:flutter/material.dart';

class VariableTextController extends TextEditingController {
  final Color variableColor;
  final Color paramColor;

  VariableTextController({
    super.text,
    this.variableColor = Colors.blue,
    this.paramColor = Colors.orange,
  });

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> children = [];

    // Regex for {{variable}}, :path_param and {:path_param}
    // Group 1: {{...}}
    // Group 2: :param
    // Group 3: {:param}
    final RegExp regExp = RegExp(
      r'(\{\{[^}]+\}\})|(:[a-zA-Z0-9_]+)|(\{:[a-zA-Z0-9_]+\})',
    );

    text.splitMapJoin(
      regExp,
      onMatch: (Match match) {
        final bool isVar = match.group(1) != null;
        final bool isParam = match.group(2) != null || match.group(3) != null;

        children.add(
          TextSpan(
            text: match.group(0),
            style: style?.copyWith(
              color: isVar ? variableColor : (isParam ? paramColor : null),
              fontWeight: (isVar || isParam) ? FontWeight.bold : null,
            ),
          ),
        );
        return '';
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
        return '';
      },
    );

    return TextSpan(style: style, children: children);
  }
}
