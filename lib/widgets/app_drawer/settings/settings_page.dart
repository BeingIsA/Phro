import 'package:flutter/material.dart';
import 'package:phro/l10n/app_localizations.dart';
import 'package:phro/widgets/app_drawer/settings/api_settings/language_model_config_page.dart';
import 'package:phro/widgets/app_drawer/settings/other_settings/other_settings.dart';
import 'package:phro/widgets/app_drawer/settings/search_api/search_api_config_page.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Navigator(
      key: _navigatorKey,
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        Widget body = Column(
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.languageModelMenu),
              onTap: () =>
                  _navigatorKey.currentState?.pushNamed('/language_model'),
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: Text(l10n.visionModelMenu),
              onTap: () =>
                  _navigatorKey.currentState?.pushNamed('/vision_model'),
            ),
            ListTile(
              leading: const Icon(Icons.mic),
              title: Text(l10n.speechModelMenu),
              onTap: () =>
                  _navigatorKey.currentState?.pushNamed('/speech_model'),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: Text(l10n.searchApiMenu),
              onTap: () => _navigatorKey.currentState?.pushNamed('/search_api'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(l10n.otherSettingsMenu),
              onTap: () => _navigatorKey.currentState?.pushNamed('/other'),
            ),
          ],
        );

        String appBarText = l10n.settingsTitle;
        switch (settings.name) {
          case '/language_model':
            body = const LanguageModelConfigPage();
            appBarText = l10n.languageModelAppBar;
          case '/vision_model':
            body = const Center(
              child: Text('视觉模型配置\n开发中...', style: TextStyle(fontSize: 18)),
            );
            appBarText = l10n.visionModelAppBar;
          case '/speech_model':
            body = const Center(
              child: Text('语音模型配置\n开发中...', style: TextStyle(fontSize: 18)),
            );
            appBarText = l10n.speechModelAppBar;
          case '/search_api':
            body = const SearchApiConfigPage();
            appBarText = l10n.searchApiAppBar;
          case '/other':
            body = const OtherSettings();
            appBarText = l10n.otherSettingsAppBar;
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
