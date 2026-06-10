import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:phro/widgets/home_page.dart';
import 'package:phro/repositories/chat_repository.dart';

Future<void> main() async {
  await Hive.initFlutter();
  await ChatRepository.instance.initHiveBox();

  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'Phro',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.light(
            // 品牌主色
            primary: Colors.blue, // 主色 - AppBar、主要按钮、主题强调色
            onPrimary: Colors.white, // 主色上的文字/图标颜色
            // 次要色
            secondary: Colors.blue.shade700, // 次要色 - 次要按钮、Tab选中、辅助强调
            onSecondary: Colors.white, // 次要色上的文字/图标颜色
            // 容器颜色
            primaryContainer: Colors.blue.shade50, // 气泡和滑动开关背景
            onPrimaryContainer: Colors.blue.shade900, // 气泡上的文字
            // 强调/功能色
            tertiary: Colors.orange.shade700, // 三级色 - 警告、重要标签、特殊操作
            error: Colors.red, // 错误色 - 错误提示、删除按钮等
            onError: Colors.white, // 错误色上的文字/图标颜色
            // 表面与背景
            surface: Colors.white, // 主要表面颜色 - 卡片、对话框背景
            surfaceContainerHighest:
                Colors.grey.shade100, // 较高层次表面 - 列表项、卡片轻微区分
            onSurface: Colors.black87, // 表面上的主要文字颜色（正文、标题）
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
            titleTextStyle: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          scaffoldBackgroundColor: Colors.white,
          cardColor: Colors.white,
        ),
        home: const HomePage(),
      ),
    ),
  );
}
// Theme.of(context). 可以获取到的各种预设样式以及使用场景
// displayLarge,57,w400 (regular),超大展示标题（如欢迎页主标题）
// displayMedium,45,w400,大展示标题
// displaySmall,36,w400,中等展示标题
// headlineLarge,32,w400,大标题（页面主标题）
// headlineMedium,28,w400,中标题
// headlineSmall,24,w400,小标题
// titleLarge,22,w400,卡片/对话框大标题
// titleMedium,16,w500 (medium),卡片标题、AppBar 标题（最常用标题之一）
// titleSmall,14,w500,小标题、辅助标题
// bodyLarge,16,w400,主要正文文字（最常用正文）
// bodyMedium,14,w400,普通正文、列表内容
// bodySmall,12,w400,辅助文字、描述、次要信息
// labelLarge,14,w500,较大标签（按钮文字、大 Chip）
// labelMedium,12,w500,普通标签、中等按钮文字
// labelSmall,11,w500,小标签、徽章、输入提示