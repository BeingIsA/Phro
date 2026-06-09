import 'package:flutter/material.dart';

class DeleteAlertDialog extends StatelessWidget {
  final String title = '删除确认';
  final String content;

  const DeleteAlertDialog({
    super.key,
    required this.colorScheme,
    required this.content,
  });

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
          child: const Text('删除'),
        ),
      ],
    );
  }
}
