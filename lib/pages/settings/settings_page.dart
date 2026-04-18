import 'package:flutter/material.dart';
import 'package:phro/pages/settings/model_settings/model_config_page.dart';
import 'package:phro/pages/settings/other_settings/other_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // 关键：给嵌套 Navigator 一个 GlobalKey，方便在主页面控制跳转
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // 路由生成器（所有子页面在这里统一管理）
  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/': // 主设置页面
      return PageRouteBuilder(
        settings: settings,
        transitionDuration: Duration.zero,      // 正向无动画
        reverseTransitionDuration: Duration.zero, // 返回时也无动画
        pageBuilder: (context, animation, secondaryAnimation) => _buildMainSettings(),
      );

    case '/model': // 模型设置子页面
      return PageRouteBuilder(
        settings: settings,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) => const ModelConfigPage(),
      );

    case '/other': // 其他设置子页面
      return PageRouteBuilder(
        settings: settings,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) => const OtherSettings(),
      );

    default:
      return PageRouteBuilder(
        settings: settings,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Center(child: Text('页面不存在')),
      );
  }
}

  // 主设置页面（去掉左侧导航栏后的新首页）
  Widget _buildMainSettings() {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
        centerTitle: true,
        actions: [IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close))],
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('模型配置'),
            onTap: () => _navigatorKey.currentState?.pushNamed('/model'),
          ),
          ListTile(
            title: const Text('其他设置'),
            onTap: () => _navigatorKey.currentState?.pushNamed('/other'),
          ),
          // 如果以后还有更多设置项，直接在这里继续添加 ListTile 即可
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey, // 绑定 key
      initialRoute: '/', // 默认显示主设置列表
      onGenerateRoute: _onGenerateRoute, // 所有跳转走这里
    );
  }
}
