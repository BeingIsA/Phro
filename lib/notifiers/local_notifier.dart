// lib/providers/locale_provider.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

// 定义一个 AsyncNotifier，它管理的状态是 AsyncValue<Locale>
class LocaleNotifier extends AsyncNotifier<Locale> {
  // 初始化：加载文件或使用系统语言
  @override
  Future<Locale> build() async {
    return await _loadLocale();
  }

  // 加载语言（文件 → 系统语言）
  Future<Locale> _loadLocale() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/locale.txt');
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          return Locale(content);
        }
      }
    } catch (_) {}
    // 无文件或出错 → 系统语言
    return PlatformDispatcher.instance.locale;
  }

  // 切换语言：写入文件并更新状态
  Future<void> setLocale(Locale newLocale) async {
    // 如果相同则跳过
    if (state.hasValue && state.value == newLocale) return;

    // 先保存到文件（异步，不阻塞 UI 可先更新状态，但为了可靠性可等待）
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/locale.txt');
      await file.writeAsString(newLocale.languageCode);
    } catch (_) {}

    state = AsyncValue.data(newLocale);
  }

  Locale? get currentLocale => state.value;
}

// 提供器
final localeProvider = AsyncNotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
