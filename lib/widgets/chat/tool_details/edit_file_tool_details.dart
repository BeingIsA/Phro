import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:phro/l10n/app_localizations.dart';
import 'package:phro/models/message.dart';
import 'package:pretty_diff_text/pretty_diff_text.dart';

class EditFileToolDetails extends StatelessWidget {
  final Message message;

  const EditFileToolDetails({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final argumentMap = jsonDecode(message.argument!);
    final oldString = argumentMap['oldString'];
    final newString = argumentMap['newString'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: SingleChildScrollView(
          child: PrettyDiffText(
            oldText: oldString!,
            newText: newString!,
            diffCleanupType: DiffCleanupType.SEMANTIC,
          ),
        ),
      ),
    );
  }
}
