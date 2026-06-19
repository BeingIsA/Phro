import 'package:flutter/material.dart';
import 'package:phro/l10n/app_localizations.dart';
import 'package:phro/models/message.dart';

class ToolDetails extends StatelessWidget {
  final Message message;

  const ToolDetails({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SelectableText(
      '${l10n.toolArgumentsPrefix}${message.argument}\n\n',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        height: 1.4,
      ),
    );
  }
}
