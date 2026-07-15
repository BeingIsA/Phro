import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:phro/l10n/app_localizations.dart';
import 'package:phro/models/message.dart';
import 'package:phro/services/chat_service.dart';
import 'package:phro/widgets/chat/expantion_tiles/message_expansion_title.dart';
import 'package:phro/widgets/chat/message_list_view.dart';
import 'package:phro/widgets/chat/tool_details/default_tool_details.dart';

/// 新增：内嵌式工具消息卡片组件（免弹窗，直接输入并拒绝）
class SubAgentTile extends StatefulWidget {
  final Message message;
  final ChatService chatService = ChatService.instance;

  SubAgentTile({super.key, required this.message});

  @override
  State<SubAgentTile> createState() => SubAgentTileState();
}

class SubAgentTileState extends State<SubAgentTile> {
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

    IconData iconData = Icons.smart_toy_outlined;
    String titleText = l10n!.subAgentExecuting(message.agentName!);

    switch (message.toolCallStatus!) {
      case ToolCallStatus.rejected:
        iconData = Icons.block_outlined;
        titleText = l10n.subAgentRejected(message.agentName!);

      case ToolCallStatus.canceled:
        iconData = Icons.cancel_outlined;
        titleText = l10n.subAgentCanceled(message.agentName!);

      case ToolCallStatus.pendingConformation:
        iconData = Icons.gpp_maybe_outlined;
        titleText = l10n.subAgentSecurityWarning(message.agentName!);

      case ToolCallStatus.executing:
        iconData = Icons.hourglass_top_outlined;
        titleText = l10n.subAgentExecuting(message.agentName!);

      case ToolCallStatus.finished:
        iconData = Icons.smart_toy_outlined;
        titleText = l10n.subAgentCallFinished(message.agentName!);
    }

    final argumentMap = jsonDecode(message.argument!);
    final String systemPrompt = argumentMap['system_prompt'];
    final String userInput = argumentMap['user_input'];
    final String tools = JsonEncoder.withIndent(
      '  ',
    ).convert(argumentMap['tools']);
    return MessageExpansionTile(
      icon: iconData,
      title: titleText,
      titleColor: statusColor,
      child: [
        // 参数与详情展示
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    l10n.systemPrompt,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
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
                      systemPrompt,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    l10n.availableTools,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
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
                      tools,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    l10n.input,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
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
                      userInput,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    border: Border.all(color: theme.colorScheme.outlineVariant),
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
        // 如果有子 Agent 消息，渲染可折叠的递归列表
        if (message.subAgentMessages != null &&
            message.subAgentMessages!.isNotEmpty) ...[
          const SizedBox(height: 12),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              '子任务详情',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            children: [
              MessageListView(
                messages: message.subAgentMessages!,
                inSubAgent: true,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

@Preview(name: 'SubAgentTile')
Widget previewSubAgentTile() {
  final message = Message(role: 'tool', content: 'Sub Agent 正在执行任务...')
    ..name = 'delegate'
    ..toolCallId = 'preview'
    ..toolCallStatus = ToolCallStatus.executing;

  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SubAgentTile(message: message)),
  );
}
