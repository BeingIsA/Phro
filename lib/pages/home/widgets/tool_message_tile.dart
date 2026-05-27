import 'package:flutter/material.dart';
import 'package:phro/models/message.dart';
import 'package:phro/services/chat_service.dart';

/// 新增：内嵌式工具消息卡片组件（免弹窗，直接输入并拒绝）
class ToolMessageTile extends StatefulWidget {
  final Message message;
  final ChatService chatService;

  const ToolMessageTile({
    super.key,
    required this.message,
    required this.chatService,
  });

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
    final message = widget.message;
    final bool isPending = message.isPendingConfirmation;
    final bool isRejected = message.isRejected;

    // 根据高危工具的不同拦截状态动态定制图标和主题色
    IconData iconData = Icons.build;
    Color statusColor = Colors.grey;
    String titleText = '工具 ${message.name} 调用结果';

    if (isPending) {
      iconData = Icons.gpp_maybe_outlined;
      statusColor = Colors.orange;
      titleText = '安全警告：工具 ${message.name} 请求授权';
    } else if (isRejected) {
      iconData = Icons.block;
      statusColor = Colors.red;
      titleText = '工具 ${message.name} 已被拒绝';
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 4.0),
      child: ExpansionTile(
        initiallyExpanded: isPending, // 如果处于高危拦截等待状态，默认直接展开
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: Icon(iconData, size: 20, color: statusColor),
        title: Text(
          titleText,
          style: TextStyle(
            fontSize: 13,
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        children: [
          // 参数与详情展示
          Align(
            alignment: Alignment.centerLeft,
            child: SelectableText(
              "参数：${message.argument}\n\n"
              "${isPending ? '状态：等待安全授权...' : (isRejected ? '拒绝详情：\n' : '调用结果：\n')}${message.content}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),

          // 如果是高危工具且正在等待确认，直接在下方展示输入行，无需弹窗
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                // 输入框吃满左侧剩余空间
                Expanded(
                  child: TextField(
                    controller: _reasonController,
                    decoration: const InputDecoration(
                      hintText: '输入拒绝原因或修正反馈（可选）...',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                // 拒绝按钮紧贴输入框右侧
                TextButton.icon(
                  onPressed: () {
                    widget.chatService.confirmToolCall(
                      message.toolCallId!,
                      approved: false,
                      reason: _reasonController.text.trim(),
                    );
                  },
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('拒绝'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                const SizedBox(width: 4),
                // 允许按钮放在最后
                ElevatedButton.icon(
                  onPressed: () {
                    widget.chatService.confirmToolCall(
                      message.toolCallId!,
                      approved: true,
                    );
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('允许'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
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
