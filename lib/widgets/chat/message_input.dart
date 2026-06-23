import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phro/l10n/app_localizations.dart';
import 'package:phro/notifiers/active_chat_notifier.dart';
import 'package:phro/services/chat_service.dart';
import 'package:flutter/foundation.dart';
// 请确保导入包含 activeChatNotifierProvider 的文件
// import 'package:phro/providers/xxx_provider.dart';

class MessageInput extends ConsumerStatefulWidget {
  final void Function(String) onSend;

  const MessageInput({super.key, required this.onSend});

  @override
  ConsumerState<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends ConsumerState<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService.instance;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  void _send() {
    if (_hasText) {
      final String text = _controller.text.trim();
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDesktop =
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;

    // 1. 监视 currentChat 状态
    // 假设 currentChat 可能为 null，这里做个安全调用
    final currentChat = ref.watch(activeChatNotifierProvider);
    final bool isGenerating = currentChat?.isGenerating ?? false;

    var textField = TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: l10n.messageInputHint,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      style: theme.textTheme.bodyLarge,
      minLines: 1,
      maxLines: 10, // 达到10行后，内部滚动，不再撑大容器
      // 移动端多行输入，回车换行
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 桌面端回车发送，shift+回车换行；移动端回车换行
            isDesktop
                ? CallbackShortcuts(
                    bindings: {
                      const SingleActivator(LogicalKeyboardKey.enter): () {
                        if (!isGenerating) {
                          _send();
                        }
                      },
                    },
                    child: textField,
                  )
                : textField,

            Align(
              alignment: Alignment.centerRight,

              child: IconButton(
                // 根据 isGenerating 切换提示文本
                tooltip: isGenerating
                    ? l10n.stopGenerationTooltip
                    : l10n.sendTooltip,
                // 2. 根据 isGenerating 切换图标
                icon: Icon(
                  isGenerating ? Icons.stop_rounded : Icons.send,
                  color: isGenerating || _hasText
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                // 3. 根据 isGenerating 切换点击逻辑
                onPressed: isGenerating
                    ? () {
                        _chatService.cancelGeneration();
                      }
                    : _send,
                splashRadius: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
