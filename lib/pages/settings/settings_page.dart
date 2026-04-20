import 'package:flutter/material.dart';
import 'package:phro/pages/settings/model_settings/model_config_page.dart';
import 'package:phro/pages/settings/other_settings/other_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // 这个千万不能改写成类实例，一定要是函数。会影响Scaffold初始化的时机
  Widget _buildMainSettings(Widget body, String appBarText) {
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarText),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        body: body,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey, // 绑定 key
      initialRoute: '/', // 默认显示主设置列表
      onGenerateRoute: (RouteSettings settings) {
        Widget body = Column(
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
        );
        String appBarText = '设置';
        switch (settings.name) {
          case '/model': // 模型设置子页面
            body = const ModelConfigPage();
            appBarText = '模型配置';
          case '/other': // 其他设置子页面
            body = const OtherSettings();
            appBarText = '其他设置';
        }
        return PageRouteBuilder(
          settings: settings,
          transitionDuration: Duration.zero, // 正向无动画
          reverseTransitionDuration: Duration.zero, // 返回时也无动画
          pageBuilder: (context, animation, secondaryAnimation) =>
              _buildMainSettings(body, appBarText),
        );
      }, // 所有跳转走这里
    );
  }
}
