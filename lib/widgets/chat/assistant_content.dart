import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:phro/models/message.dart';
import 'package:phro/widgets/chat/tool_details/code_element_builder.dart';

class AssistantContent extends StatelessWidget {
  final Message message;

  const AssistantContent({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool hasError = message.error?.trim().isNotEmpty ?? false;
    final String displayText = hasError ? message.error! : message.content;

    if (displayText.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: hasError
          ? SelectableText(
              displayText,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.error,
                fontSize: 16,
                height: 1.5,
              ),
            )
          : SelectionArea(
              child: GptMarkdown(
                displayText,
                codeBuilder: (context, name, code, closed) => CustomCodeBlock(
                  language: name,
                  codeText: code,
                  closed: closed,
                ),
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
            ),
    );
  }
}
