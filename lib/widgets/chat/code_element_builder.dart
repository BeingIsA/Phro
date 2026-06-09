import 'package:flutter/material.dart' hide Element;
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' hide Text;

class CodeElementBuilder extends MarkdownElementBuilder {
  final BuildContext context; // 用于获取 Theme

  CodeElementBuilder(this.context);

  @override
  Widget? visitElementAfter(Element element, TextStyle? preferredStyle) {
    final String language =
        element.attributes['class']?.replaceAll('language-', '') ?? 'plaintext';

    final String codeText = element.textContent;

    final colorScheme = Theme.of(context).colorScheme;

    return IntrinsicWidth(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              child: Row(
                children: [
                  Text(language.toUpperCase()),
                  const Spacer(),
                  _CopyButton(codeText: codeText),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: HighlightView(
                codeText,
                language: language,
                theme: githubTheme,
                padding: const EdgeInsets.all(8.0),
                textStyle: const TextStyle(
                  fontSize: 15.0,
                  fontFamily: 'monospace',
                  height: 1.55,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 独立的复制按钮组件（带复制成功动画）
class _CopyButton extends StatefulWidget {
  final String codeText;

  const _CopyButton({required this.codeText});

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: widget.codeText));

    setState(() => _copied = true);

    // 1.5秒后恢复复制图标
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _copied
            ? const Icon(Icons.check_rounded, size: 18)
            : const Icon(Icons.copy_rounded, size: 18),
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onPressed: _copyCode,
    );
  }
}
