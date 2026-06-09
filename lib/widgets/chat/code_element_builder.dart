import 'package:flutter/material.dart' hide Element;
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart';

class CodeElementBuilder extends MarkdownElementBuilder {
  final BuildContext context; // 用于获取 Theme

  CodeElementBuilder(this.context);

  @override
  Widget? visitElementAfter(Element element, TextStyle? preferredStyle) {
    final String language =
        element.attributes['class']?.replaceAll('language-', '') ?? 'plaintext';

    final String codeText = element.textContent;

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: HighlightView(
        codeText,
        language: language,
        theme: githubTheme, // 亮色主题，后面可改成动态
        padding: const EdgeInsets.all(8.0),
        textStyle: const TextStyle(
          fontSize: 15.0,
          fontFamily: 'monospace',
          height: 1.55,
        ),
      ),
    );
  }
}
