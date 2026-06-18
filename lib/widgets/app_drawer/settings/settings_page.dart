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

enum _SettingsPageType {
  menu,
  languageModel,
  visionModel,
  speechModel,
  searchApi,
  other,
}

class _SettingsPageState extends State<SettingsPage> {
  _SettingsPageType _selectedPage = _SettingsPageType.menu;

  // 杩欎釜鍗冧竾涓嶈兘鏀瑰啓鎴愮被瀹炰緥锛屼竴瀹氳鏄嚱鏁般€備細褰卞搷Scaffold鍒濆鍖栫殑鏃舵満
  Widget _buildMainSettings(Widget body, String appBarText) {
    final isMenuPage = _selectedPage == _SettingsPageType.menu;

    return PopScope(
      // PipScope是为了实现移动设备点击返回键回到上一层的效果。
      canPop: isMenuPage,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || isMenuPage) return;

        setState(() => _selectedPage = _SettingsPageType.menu);
      },
      child: ScaffoldMessenger(
        child: Scaffold(
          appBar: AppBar(
            leading: isMenuPage
                ? null
                : IconButton(
                    onPressed: () =>
                        setState(() => _selectedPage = _SettingsPageType.menu),
                    icon: const Icon(Icons.arrow_back),
                  ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (_selectedPage) {
      case _SettingsPageType.menu:
        return _buildMainSettings(
          Column(
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.languageModelMenu),
                onTap: () => setState(
                  () => _selectedPage = _SettingsPageType.languageModel,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: Text(l10n.visionModelMenu),
                onTap: () => setState(
                  () => _selectedPage = _SettingsPageType.visionModel,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.mic),
                title: Text(l10n.speechModelMenu),
                onTap: () => setState(
                  () => _selectedPage = _SettingsPageType.speechModel,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: Text(l10n.searchApiMenu),
                onTap: () =>
                    setState(() => _selectedPage = _SettingsPageType.searchApi),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(l10n.otherSettingsMenu),
                onTap: () =>
                    setState(() => _selectedPage = _SettingsPageType.other),
              ),
            ],
          ),
          l10n.settingsTitle,
        );
      case _SettingsPageType.languageModel:
        return _buildMainSettings(
          const LanguageModelConfigPage(),
          l10n.languageModelAppBar,
        );
      case _SettingsPageType.visionModel:
        return _buildMainSettings(
          const Center(
            child: Text('视觉模型配置\n开发中...', style: TextStyle(fontSize: 18)),
          ),
          l10n.visionModelAppBar,
        );
      case _SettingsPageType.speechModel:
        return _buildMainSettings(
          const Center(
            child: Text('语音模型配置\n开发中...', style: TextStyle(fontSize: 18)),
          ),
          l10n.speechModelAppBar,
        );
      case _SettingsPageType.searchApi:
        return _buildMainSettings(
          const SearchApiConfigPage(),
          l10n.searchApiAppBar,
        );
      case _SettingsPageType.other:
        return _buildMainSettings(
          const OtherSettings(),
          l10n.otherSettingsAppBar,
        );
    }
  }
}
