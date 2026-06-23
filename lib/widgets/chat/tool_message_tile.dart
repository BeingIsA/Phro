import 'package:flutter/material.dart';
import 'package:phro/l10n/app_localizations.dart';
import 'package:phro/models/message.dart';
import 'package:phro/services/chat_service.dart';
import 'package:phro/widgets/chat/tool_details/default_tool_details.dart';
import 'package:phro/widgets/chat/tool_details/edit_file_tool_details.dart';

/// 新增：内嵌式工具消息卡片组件（免弹窗，直接输入并拒绝）
class ToolMessageTile extends StatefulWidget {
  final Message message;
  final ChatService chatService = ChatService.instance;

  ToolMessageTile({super.key, required this.message});

  Widget buildToolDetails() {
    if (message.name == 'edit_file') {
      return EditFileToolDetails(message: message);
    }
    return DefaultToolDetails(message: message);
  }

  @override
  State<ToolMessageTile> createState() => ToolMessageTileState();
}

class ToolMessageTileState extends State<ToolMessageTile> {
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final message = widget.message;
    final bool isPending =
        message.toolCallStatus == ToolCallStatus.pendingConformation;

    // 根据状态动态选择颜色
    final Color statusColor = isPending
        ? colorScheme.tertiary
        : colorScheme.onSurfaceVariant;

    IconData iconData = Icons.build;
    String titleText = l10n!.toolExecuting(message.name!);

    switch (message.toolCallStatus!) {
      case ToolCallStatus.rejected:
        iconData = Icons.block;
        titleText = l10n.toolRejected(message.name!);

      case ToolCallStatus.canceled:
        iconData = Icons.cancel_outlined;
        titleText = l10n.toolCanceled(message.name!);

      case ToolCallStatus.pendingConformation:
        iconData = Icons.gpp_maybe_outlined;
        titleText = l10n.toolSecurityWarning(message.name!);

      case ToolCallStatus.executing:
        iconData = Icons.hourglass_top_outlined;
        titleText = l10n.toolExecuting(message.name!);

      case ToolCallStatus.finished:
        iconData = Icons.build;
        titleText = l10n.toolCallFinished(message.name!);
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 4.0),
      child: ExpansionTile(
        initiallyExpanded: isPending,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: Icon(iconData, size: 20, color: colorScheme.primary),
        title: Text(
          titleText,
          style: theme.textTheme.labelLarge?.copyWith(color: statusColor),
        ),
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        children: [
          // 参数与详情展示
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.buildToolDetails(),
                if (message.toolCallStatus != ToolCallStatus.canceled)
                  SelectableText(
                    switch (message.toolCallStatus!) {
                      ToolCallStatus.rejected => l10n.toolStatusRejected,
                      ToolCallStatus.pendingConformation =>
                        l10n.toolStatusPending,
                      ToolCallStatus.executing => l10n.toolStatusExecuting,
                      ToolCallStatus.finished => l10n.toolStatusfinished,
                      ToolCallStatus.canceled => throw UnimplementedError(),
                    },

                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                const SizedBox(height: 6),
                if (message.content.trim().isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: SelectableText(
                      message.content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 如果是高危工具且正在等待确认，直接在下方展示输入行
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                // 输入框
                Expanded(
                  child: TextField(
                    controller: _reasonController,
                    decoration: InputDecoration(
                      hintText: l10n.toolReasonHint,
                      hintStyle: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 8),

                // 拒绝按钮
                TextButton.icon(
                  onPressed: () {
                    widget.chatService.confirmToolCall(
                      message.toolCallId!,
                      approved: false,
                      reason: _reasonController.text.trim(),
                    );
                  },
                  icon: Icon(Icons.close, size: 16, color: colorScheme.error),
                  label: Text(l10n.rejectButton),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                const SizedBox(width: 4),

                // 允许按钮
                ElevatedButton.icon(
                  onPressed: () {
                    widget.chatService.confirmToolCall(
                      message.toolCallId!,
                      approved: true,
                    );
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(l10n.allowButton),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
