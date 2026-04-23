import 'package:flutter/material.dart';
import 'package:phro/services/chat_service.dart';

class MessageInput extends StatefulWidget {
  final void Function(String) onSend; // 回调函数，父页面决定

  const MessageInput({super.key, required this.onSend});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {

  final TextEditingController _controller = TextEditingController();
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

  // 清空输入框，执行发送
  void _send() {
    if (_hasText) {
      final String text = _controller.text.trim();
      widget.onSend(text); // 通知父页面
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
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '请输入内容...',
                border: InputBorder.none, // 去掉内部边框
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 0,
                ),
              ),
              onSubmitted: (_) => _send(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: _hasText ? Colors.blue : Colors.grey,
                ),
                onPressed: _send,
                splashRadius: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
