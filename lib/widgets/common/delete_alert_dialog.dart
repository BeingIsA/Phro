import 'package:flutter/material.dart';
import 'package:phro/l10n/app_localizations.dart'; // ← 新增导入

class DeleteAlertDialog extends StatelessWidget {
  final String content;

  const DeleteAlertDialog({
    super.key,
    required this.colorScheme,
    required this.content,
  });

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // ← 获取本地化实例

    return AlertDialog(
      title: Text(l10n.deleteConfirmationTitle),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
          child: Text(l10n.delete),
        ),
      ],
    );
  }
}
