import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:phro/widgets/home_page.dart';
import 'package:phro/repositories/chat_repository.dart';

Future<void> main() async {
  await Hive.initFlutter();
  await ChatRepository.instance.initHiveBox();

  runApp(
    MaterialApp(
      title: 'Phro',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          // 品牌主色
          primary: Colors.blue, // 主色 - AppBar、主要按钮、主题强调色
          onPrimary: Colors.white, // 主色上的文字/图标颜色
          primaryContainer: Colors.blue.shade50, // 主色容器 - 卡片、输入框等浅背景
          onPrimaryContainer: Colors.blue.shade900, // 主色容器上的文字/图标（深色）
          // 次要色
          secondary: Colors.blue.shade700, // 次要色 - 次要按钮、Tab选中、辅助强调
          onSecondary: Colors.white, // 次要色上的文字/图标颜色
          // 强调/功能色
          tertiary: Colors.orange.shade700, // 三级色 - 警告、重要标签、特殊操作
          error: Colors.red, // 错误色 - 错误提示、删除按钮等
          onError: Colors.white, // 错误色上的文字/图标颜色
          // 表面与背景
          surface: Colors.white, // 主要表面颜色 - 卡片、对话框背景
          onSurface: Colors.black87, // 表面上的主要文字颜色（正文、标题）
          surfaceContainerHighest: Colors.grey.shade100, // 较高层次表面 - 列表项、卡片轻微区分
          onSurfaceVariant: Colors.grey.shade700, // 次要文字、提示文本、图标颜色
          // 边框与分割线
          outline: Colors.grey[400]!, // 常规边框、分隔线、输入框边框
          outlineVariant: Colors.grey.shade200, // 较弱边框 - 表格边框、极弱分隔线
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
      ),
      home: const HomePage(),
    ),
  );
}
