// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get deleteConfirmationTitle => 'Delete Confirmation';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get language => 'Language';

  @override
  String get version => 'version';

  @override
  String currentChatAgent(String agentName) {
    return 'Current chat agent: $agentName';
  }

  @override
  String get newChatPrefix => 'New chat (';

  @override
  String get newChatSuffix => ')';

  @override
  String get settings => 'Settings';
}
