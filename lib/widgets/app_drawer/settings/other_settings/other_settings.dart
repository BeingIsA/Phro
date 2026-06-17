import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phro/l10n/app_localizations.dart'; // 确保路径正确
import 'package:phro/notifiers/local_notifier.dart';

/// 其他设置组件（语言选择 + 关于信息）
class OtherSettings extends ConsumerWidget {
  const OtherSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. 监听当前语言（异步状态）
    final locale = ref.watch(localeProvider).value;

    // 2. 获取支持的语言列表（从 AppLocalizations 中定义）
    final supportedLocales = AppLocalizations.supportedLocales;
    final items = supportedLocales.map((Locale locale) {
      String label = _getLanguageName(locale);
      return DropdownMenuItem<Locale>(value: locale, child: Text(label));
    }).toList();

    return ListView(
      children: [
        // 语言选择卡片
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '语言',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                DropdownButton<Locale>(
                  value: locale,
                  isExpanded: true,
                  items: items,
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      // 切换语言
                      ref.read(localeProvider.notifier).setLocale(newLocale);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        // 关于信息
        const Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '关于',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                Text('Phro 版本 1.0.0'),
              ],
            ),
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
