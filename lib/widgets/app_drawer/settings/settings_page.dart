import 'package:flutter/material.dart';
import 'package:phro/widgets/app_drawer/settings/api_settings/language_model_config_page.dart';
import 'package:phro/widgets/app_drawer/settings/other_settings/other_settings.dart';
import 'package:phro/widgets/app_drawer/settings/search_api/search_api_config_page.dart'; // 新增搜索API页面

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
      key: _navigatorKey,
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        Widget body = Column(
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('语言模型'),
              onTap: () =>
                  _navigatorKey.currentState?.pushNamed('/language_model'),
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('视觉模型'),
              onTap: () =>
                  _navigatorKey.currentState?.pushNamed('/vision_model'),
            ),
            ListTile(
              leading: const Icon(Icons.mic),
              title: const Text('语音模型'),
              onTap: () =>
                  _navigatorKey.currentState?.pushNamed('/speech_model'),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('搜索API'),
              onTap: () => _navigatorKey.currentState?.pushNamed('/search_api'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('其他设置'),
              onTap: () => _navigatorKey.currentState?.pushNamed('/other'),
            ),
          ],
        );

        String appBarText = '设置';
        switch (settings.name) {
          case '/language_model':
            body = const LanguageModelConfigPage();
            appBarText = '语言模型';
          case '/vision_model':
            body = const Center(
              child: Text('视觉模型配置\n开发中...', style: TextStyle(fontSize: 18)),
            );
            appBarText = '视觉模型';
          case '/speech_model':
            body = const Center(
              child: Text('语音模型配置\n开发中...', style: TextStyle(fontSize: 18)),
            );
            appBarText = '语音模型';
          case '/search_api':
            body = const SearchApiConfigPage();
            appBarText = '搜索API';
          case '/other':
            body = const OtherSettings();
            appBarText = '其他设置';
        }

        return PageRouteBuilder(
          settings: settings,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (context, animation, secondaryAnimation) =>
              _buildMainSettings(body, appBarText),
        );
      },
    );
  }
}
