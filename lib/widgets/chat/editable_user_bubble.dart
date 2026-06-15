import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phro/models/message.dart';
import 'package:phro/notifiers/active_chat_notifier.dart';

class EditableUserBubble extends ConsumerStatefulWidget {
  final Message message;

  const EditableUserBubble({super.key, required this.message});

  @override
  ConsumerState<EditableUserBubble> createState() => _EditableUserBubbleState();
}

class _EditableUserBubbleState extends ConsumerState<EditableUserBubble> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.message.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveEdit() async {
    final newContent = _controller.text.trim();
    if (newContent.isEmpty || newContent == widget.message.content) {
      _cancelEdit();
      return;
    }

    setState(() => _isEditing = false); // 乐观退出编辑模式

    // 通过 Notifier 调用
    await ref
        .read(activeChatNotifierProvider.notifier)
        .editMessageAndContinue(
          messageId: widget.message.id,
          newContent: newContent,
        );
  }

  void _cancelEdit() {
    _controller.text = widget.message.content;
    setState(() => _isEditing = false);
  }

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
          child: _isEditing
              ? TextField(
                  controller: _controller,
                  maxLines: null,
                  autofocus: true,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                )
              : SelectableText(
                  widget.message.content,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                  ),
                  selectionColor: colorScheme.primary,
                  cursorColor: colorScheme.primary,
                ),
        ),

        if (!_isEditing)
          Padding(
            padding: const EdgeInsets.only(right: 12.0, bottom: 4.0),
            child: IconButton(
              icon: const Icon(Icons.edit, size: 18),
              color: colorScheme.primary,
              onPressed: () => setState(() => _isEditing = true),
              tooltip: '编辑消息',
            ),
          ),

        if (_isEditing)
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 4.0, bottom: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(onPressed: _cancelEdit, child: const Text('取消')),
                const SizedBox(width: 8),
                FilledButton(onPressed: _saveEdit, child: const Text('重新发送')),
              ],
            ),
          ),
      ],
    );
  }
}
