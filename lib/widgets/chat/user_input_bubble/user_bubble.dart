import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phro/models/message.dart';

class UserBubble extends ConsumerStatefulWidget {
  final Message message;

  const UserBubble({super.key, required this.message});

  @override
  ConsumerState<UserBubble> createState() => _EditableUserBubbleState();
}

class _EditableUserBubbleState extends ConsumerState<UserBubble> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.75,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.zero,
            ),
          ),
          child: SelectableText(
            widget.message.content,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontSize: 16,
            ),
            selectionColor: colorScheme.primary,
            cursorColor: colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
