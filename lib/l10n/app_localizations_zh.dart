// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get deleteConfirmationTitle => '删除确认';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get language => '语言';

  @override
  String get version => '版本';

  @override
  String currentChatAgent(String agentName) {
    return '当前对话Agent：$agentName';
  }
}
