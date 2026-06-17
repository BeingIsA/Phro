import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phro/l10n/app_localizations.dart'; // 确保路径正确
import 'package:phro/notifiers/local_notifier.dart';

/// 其他设置组件（语言选择 + 关于信息）
class OtherSettings extends ConsumerWidget {
  const OtherSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!; // ← 获取本地化实例
    final locale = ref.watch(localeProvider).value;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 语言选择行：标签 + 下拉框
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.language,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 120,
              child: DropdownButton<Locale>(
                value: locale,
                isExpanded: true,
                items: AppLocalizations.supportedLocales.map((Locale locale) {
                  String label = _getLanguageName(locale);
                  return DropdownMenuItem<Locale>(
                    value: locale,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    ref.read(localeProvider.notifier).setLocale(newLocale);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 关于信息（小字显示）
        Text(
          'Phro ${l10n.version} 1.0.0',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // 辅助方法：根据 Locale 返回显示名称（你可以根据需要扩展）
  String _getLanguageName(Locale locale) {
    // 简单映射，可根据需要从 AppLocalizations 中获取
    switch (locale.languageCode) {
      case 'zh':
        return '简体中文';
      case 'en':
        return 'English';
      case 'ja':
        return '日本語';
      default:
        return locale.languageCode;
    }
  }
}
