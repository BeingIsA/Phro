import 'package:flutter/material.dart';
import 'package:phro/l10n/app_localizations.dart';
import 'package:phro/models/message.dart';
import 'package:phro/widgets/chat/expantion_tiles/message_expansion_title.dart';

class ReasoningContentTile extends StatelessWidget {
  final Message message;

  const ReasoningContentTile({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MessageExpansionTile(
      icon: Icons.psychology_outlined,
      title: l10n.thinkingProcessTitle,
      child: [
        SelectableText(
          message.reasoningContent!,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
